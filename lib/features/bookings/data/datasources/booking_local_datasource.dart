import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/database_helper.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/create_booking_request.dart';
import '../models/booking_model.dart';

class BookingLocalDatasource {
  final DatabaseHelper dbHelper;

  BookingLocalDatasource(this.dbHelper);

  Future<BookingModel> createBooking(CreateBookingRequest request) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    try {
      final createdBooking = await db.transaction((txn) async {
        // 0. Validate booking date & time must be in the future
        try {
          final dateParts = request.bookingDate.split('-');
          final timeParts = request.bookingTime.split(':');
          final bookingDateTime = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (bookingDateTime.isBefore(DateTime.now())) {
            throw const ValidationFailure(
                'วันและเวลาที่จองต้องเป็นเวลาล่วงหน้าในอนาคตเท่านั้น (มากกว่าเวลาปัจจุบัน)');
          }
        } catch (e) {
          if (e is Failure) rethrow;
        }

        // 1. Conflict Check: Check if table is already booked at that date & time
        final existing = await txn.query(
          'bookings',
          where:
              'table_id = ? AND booking_date = ? AND booking_time = ? AND status != ?',
          whereArgs: [
            request.tableId,
            request.bookingDate,
            request.bookingTime,
            'cancelled'
          ],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          throw const BookingConflictFailure(
              'โต๊ะนี้ถูกจองแล้วในช่วงเวลานี้ กรุณาเลือกโต๊ะหรือเวลาอื่น');
        }

        // 2. Validate table & capacity
        final tableInfo = await txn.query(
          'restaurant_tables',
          where: 'id = ?',
          whereArgs: [request.tableId],
          limit: 1,
        );
        if (tableInfo.isEmpty) {
          throw const NotFoundFailure('ไม่พบโต๊ะที่ระบุ');
        }
        final seatCount = tableInfo.first['seat_count'] as int;
        if (request.guestCount > seatCount) {
          throw ValidationFailure(
              'จำนวนแขกเกินความจุของโต๊ะ (สูงสุด $seatCount ที่นั่ง)');
        }

        final tableName = tableInfo.first['name'] as String?;
        final tableNumber = tableInfo.first['table_number'] as String?;
        final zoneId = tableInfo.first['zone_id'] as String?;

        // 3. Generate booking code: KDK-2026-XXXX
        final randomSuffix = (1000 + DateTime.now().millisecondsSinceEpoch % 8999).toString();
        final bookingCode = 'KDK-2026-$randomSuffix';

        // 4. Insert booking
        final bookingId = await txn.insert('bookings', {
          'booking_code': bookingCode,
          'user_id': request.userId,
          'restaurant_id': request.restaurantId,
          'table_id': request.tableId,
          'booking_date': request.bookingDate,
          'booking_time': request.bookingTime,
          'period': request.period,
          'guest_count': request.guestCount,
          'customer_name': request.customerName,
          'customer_phone': request.customerPhone,
          'customer_email': request.customerEmail,
          'occasion': request.occasion,
          'dietary_restrictions': request.dietaryRestrictions.join(', '),
          'special_request': request.specialRequest,
          'total_amount': request.totalAmount,
          'status': 'confirmed',
          'created_at': now,
        });

        // 5. Insert booking items (Pre-orders)
        final List<BookingItemEntity> createdItems = [];
        for (var item in request.items) {
          final itemId = await txn.insert('booking_items', {
            'booking_id': bookingId,
            'menu_id': item.menuId,
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price,
            'note': item.note,
          });
          createdItems.add(BookingItemEntity(
            id: itemId,
            bookingId: bookingId,
            menuId: item.menuId,
            name: item.name,
            quantity: item.quantity,
            price: item.price,
            note: item.note,
          ));
        }

        // 6. Get restaurant name
        final restInfo = await txn.query(
          'restaurants',
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [request.restaurantId],
          limit: 1,
        );
        final restaurantName = restInfo.isNotEmpty ? restInfo.first['name'] as String? : null;

        return BookingModel(
          id: bookingId,
          bookingCode: bookingCode,
          userId: request.userId,
          restaurantId: request.restaurantId,
          tableId: request.tableId,
          bookingDate: request.bookingDate,
          bookingTime: request.bookingTime,
          period: request.period,
          guestCount: request.guestCount,
          status: 'confirmed',
          customerName: request.customerName,
          customerPhone: request.customerPhone,
          customerEmail: request.customerEmail,
          occasion: request.occasion,
          dietaryRestrictions: request.dietaryRestrictions,
          specialRequest: request.specialRequest,
          totalAmount: request.totalAmount,
          createdAt: now,
          restaurantName: restaurantName,
          tableNumber: tableNumber,
          tableName: tableName,
          zoneId: zoneId,
          seatCount: seatCount,
          items: createdItems,
        );
      });

      return createdBooking;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const BookingConflictFailure(
            'โต๊ะนี้ถูกจองซ้อนไปแล้วในช่วงเวลานี้ กรุณาเลือกใหม่');
      }
      rethrow;
    }
  }

  Future<List<BookingModel>> getByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT b.*,
             r.name AS restaurant_name,
             t.table_number,
             t.name AS table_name,
             t.zone_id,
             t.seat_count,
             u.name AS user_name
      FROM bookings b
      LEFT JOIN restaurants r ON r.id = b.restaurant_id
      LEFT JOIN restaurant_tables t ON t.id = b.table_id
      LEFT JOIN users u ON u.id = b.user_id
      WHERE b.user_id = ?
      ORDER BY b.booking_date DESC, b.booking_time DESC
    ''', [userId]);

    final List<BookingModel> bookings = [];
    for (var row in result) {
      final bookingId = row['id'] as int;
      final itemsResult = await db.query(
        'booking_items',
        where: 'booking_id = ?',
        whereArgs: [bookingId],
      );
      final items = itemsResult.map((i) => BookingItemEntity(
        id: i['id'] as int,
        bookingId: i['booking_id'] as int,
        menuId: i['menu_id'] as String,
        name: i['name'] as String,
        quantity: i['quantity'] as int,
        price: (i['price'] as num).toDouble(),
        note: i['note'] as String?,
      )).toList();

      bookings.add(BookingModel.fromJson(row, items));
    }

    return bookings;
  }

  Future<List<BookingModel>> getByRestaurantAndDate({
    required int restaurantId,
    required String date,
  }) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT b.*,
             r.name AS restaurant_name,
             t.table_number,
             t.name AS table_name,
             t.zone_id,
             t.seat_count,
             u.name AS user_name
      FROM bookings b
      LEFT JOIN restaurants r ON r.id = b.restaurant_id
      LEFT JOIN restaurant_tables t ON t.id = b.table_id
      LEFT JOIN users u ON u.id = b.user_id
      WHERE b.restaurant_id = ? AND b.booking_date = ? AND b.status != ?
      ORDER BY b.booking_time ASC
    ''', [restaurantId, date, 'cancelled']);

    return result.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<void> cancelBooking(int bookingId) async {
    final db = await dbHelper.database;
    final count = await db.update(
      'bookings',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
    if (count == 0) {
      throw const NotFoundFailure('ไม่พบรายการจองที่จะยกเลิก');
    }
  }
}
