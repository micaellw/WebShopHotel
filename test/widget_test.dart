import 'package:flutter_test/flutter_test.dart';
import 'package:workshop/features/menu/domain/entities/menu_item_entity.dart';
import 'package:workshop/features/menu/presentation/controllers/menu_controller.dart';
import 'package:workshop/features/tables/domain/entities/table_entity.dart';
import 'package:workshop/features/bookings/domain/entities/create_booking_request.dart';
import 'package:workshop/features/bookings/domain/entities/booking_entity.dart';
import 'package:workshop/core/utils/date_utils.dart';

import 'package:workshop/features/menu/domain/repositories/menu_repository.dart';
import 'package:workshop/features/menu/domain/usecases/menu_usecases.dart';

class FakeMenuRepository implements MenuRepository {
  @override
  Future<List<MenuItemEntity>> getByRestaurant(int restaurantId) async => [];

  @override
  Future<List<MenuItemEntity>> getByCategory(int restaurantId, String category) async => [];
}

void main() {
  group('TableEntity & TableModel Tests', () {
    test('TableEntity properties and availability calculation', () {
      const availableTable = TableEntity(
        id: 1,
        restaurantId: 1,
        tableNumber: 'GH-01',
        name: 'โต๊ะ GH-01 (ริมสระบัว)',
        zoneId: 'glasshouse',
        seatCount: 2,
        status: 'available',
        shape: 'round',
      );

      expect(availableTable.isAvailable, isTrue);
      expect(availableTable.isReserved, isFalse);
      expect(availableTable.shape, 'round');
      expect(availableTable.seatCount, 2);

      const reservedTable = TableEntity(
        id: 3,
        restaurantId: 1,
        tableNumber: 'GH-03',
        name: 'โต๊ะ GH-03 (บูธโซฟาเขียว)',
        zoneId: 'glasshouse',
        seatCount: 4,
        status: 'reserved',
        shape: 'booth',
      );

      expect(reservedTable.isAvailable, isFalse);
      expect(reservedTable.isReserved, isTrue);
    });
  });

  group('WellnessMenu & PreOrders Tests', () {
    test('PreOrderItemEntity totalPrice calculation', () {
      const item = MenuItemEntity(
        id: 'M-01',
        restaurantId: 1,
        name: 'แกงเลียงผักหวานกุ้งสดปลาย่างรมควัน',
        category: 'soup',
        price: 320.0,
      );

      const preOrder = PreOrderItemEntity(menuItem: item, quantity: 3);
      expect(preOrder.totalPrice, 960.0);
    });

    test('WellnessMenuController cart operations', () {
      final controller = WellnessMenuController(
        getMenuItemsUseCase: GetMenuItemsByRestaurantUseCase(FakeMenuRepository()),
      );

      const item1 = MenuItemEntity(
        id: 'M-01',
        restaurantId: 1,
        name: 'แกงเลียงผักหวาน',
        category: 'soup',
        price: 320.0,
      );

      const item2 = MenuItemEntity(
        id: 'M-06',
        restaurantId: 1,
        name: 'ชาหมักคอมบูชะ',
        category: 'drink',
        price: 160.0,
      );

      // Add item 1 twice
      controller.addItem(item1);
      controller.addItem(item1);
      expect(controller.getItemQuantity('M-01'), 2);
      expect(controller.totalItemCount, 2);
      expect(controller.totalPreOrderPrice, 640.0);

      // Add item 2 once
      controller.addItem(item2);
      expect(controller.getItemQuantity('M-06'), 1);
      expect(controller.totalItemCount, 3);
      expect(controller.totalPreOrderPrice, 800.0);

      // Remove item 1 once
      controller.removeItem('M-01');
      expect(controller.getItemQuantity('M-01'), 1);
      expect(controller.totalPreOrderPrice, 480.0);

      // Clear cart
      controller.clearCart();
      expect(controller.totalItemCount, 0);
      expect(controller.totalPreOrderPrice, 0.0);
    });
  });

  group('CreateBookingRequest & BookingEntity Tests', () {
    test('CreateBookingRequest serializes correctly with JSON', () {
      const request = CreateBookingRequest(
        userId: 1,
        restaurantId: 1,
        tableId: 2,
        bookingDate: '2026-09-13',
        bookingTime: '18:30',
        period: 'dinner',
        guestCount: 4,
        customerName: 'คุณสุทัศน์ พิทักษ์ธรรม',
        customerPhone: '081-234-5678',
        customerEmail: 'sutas@example.com',
        occasion: 'family',
        dietaryRestrictions: ['ไม่ใส่ผงชูรส', 'อาหารเจ'],
        totalAmount: 600.0,
      );

      final json = request.toJson();
      expect(json['user_id'], 1);
      expect(json['restaurant_id'], 1);
      expect(json['table_id'], 2);
      expect(json['booking_date'], '2026-09-13');
      expect(json['booking_time'], '18:30');
      expect(json['period'], 'dinner');
      expect(json['guest_count'], 4);
      expect(json['customer_name'], 'คุณสุทัศน์ พิทักษ์ธรรม');
      expect(json['dietary_restrictions'], 'ไม่ใส่ผงชูรส, อาหารเจ');
      expect(json['total_amount'], 600.0);
    });

    test('BookingEntity status getters and helpers', () {
      final booking = BookingEntity(
        id: 1,
        bookingCode: 'KDK-2026-8801',
        userId: 1,
        restaurantId: 1,
        tableId: 2,
        bookingDate: DateTime(2026, 9, 13),
        bookingTime: '18:30',
        guestCount: 4,
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      expect(booking.isConfirmed, isTrue);
      expect(booking.isCancelled, isFalse);
      expect(booking.bookingCode, 'KDK-2026-8801');
    });
  });

  group('DateUtilsApp & Future Booking Time Validation Tests', () {
    test('isBookingTimeInPast correctly identifies past and future times', () {
      final now = DateTime.now();

      // Yesterday is always past
      final yesterday = now.subtract(const Duration(days: 1));
      expect(DateUtilsApp.isBookingTimeInPast(yesterday, '18:00'), isTrue);

      // Tomorrow is always future
      final tomorrow = now.add(const Duration(days: 1));
      expect(DateUtilsApp.isBookingTimeInPast(tomorrow, '11:30'), isFalse);

      // Next year is always future
      final nextYear = DateTime(now.year + 1, 1, 1);
      expect(DateUtilsApp.isBookingTimeInPast(nextYear, '12:00'), isFalse);

      // Today 00:01 is always past (unless tested at exactly midnight 00:00)
      if (now.hour > 0) {
        expect(DateUtilsApp.isBookingTimeInPast(now, '00:01'), isTrue);
      }

      // Today 23:59 is future (unless tested at 23:59)
      if (now.hour < 23) {
        expect(DateUtilsApp.isBookingTimeInPast(now, '23:59'), isFalse);
      }
    });

    test('Thai date formatters produce correct Buddhist Era (พ.ศ.) strings', () {
      final sampleDate = DateTime(2026, 9, 13); // Sunday 13 Sep 2026 -> 2569
      final fullThai = DateUtilsApp.formatThaiDateFull(sampleDate);
      expect(fullThai, contains('2569'));
      expect(fullThai, contains('กันยายน'));
      expect(fullThai, contains('วันอาทิตย์'));

      final shortThai = DateUtilsApp.formatThaiDateShort(sampleDate);
      expect(shortThai, '13 ก.ย. 2569');

      final mediumThai = DateUtilsApp.formatThaiDateMedium(sampleDate);
      expect(mediumThai, 'อา. 13 ก.ย. 2569');
    });
  });
}
