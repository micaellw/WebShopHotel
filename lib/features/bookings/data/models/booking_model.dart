import '../../domain/entities/booking_entity.dart';

class BookingModel {
  final int id;
  final String bookingCode;
  final int userId;
  final int restaurantId;
  final int tableId;
  final String bookingDate;
  final String bookingTime;
  final String period;
  final int guestCount;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? occasion;
  final List<String> dietaryRestrictions;
  final String? specialRequest;
  final double totalAmount;
  final String createdAt;

  final String? restaurantName;
  final String? tableNumber;
  final String? tableName;
  final String? zoneId;
  final int? seatCount;
  final String? userName;
  final List<BookingItemEntity> items;

  BookingModel({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.restaurantId,
    required this.tableId,
    required this.bookingDate,
    required this.bookingTime,
    this.period = 'lunch',
    required this.guestCount,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.occasion = 'general',
    this.dietaryRestrictions = const [],
    this.specialRequest,
    this.totalAmount = 0.0,
    required this.createdAt,
    this.restaurantName,
    this.tableNumber,
    this.tableName,
    this.zoneId,
    this.seatCount,
    this.userName,
    this.items = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, [List<BookingItemEntity> items = const []]) {
    List<String> parsedDietary = [];
    final dVal = json['dietary_restrictions'];
    if (dVal is String && dVal.isNotEmpty) {
      parsedDietary = dVal.split(',').map((e) => e.trim()).toList();
    }

    return BookingModel(
      id: json['id'] as int,
      bookingCode: (json['booking_code'] as String?) ?? 'KDK-${json['id']}',
      userId: json['user_id'] as int,
      restaurantId: json['restaurant_id'] as int,
      tableId: json['table_id'] as int,
      bookingDate: json['booking_date'] as String,
      bookingTime: json['booking_time'] as String,
      period: (json['period'] as String?) ?? 'lunch',
      guestCount: json['guest_count'] as int,
      status: (json['status'] as String?) ?? 'confirmed',
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      occasion: (json['occasion'] as String?) ?? 'general',
      dietaryRestrictions: parsedDietary,
      specialRequest: json['special_request'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      restaurantName: json['restaurant_name'] as String?,
      tableNumber: json['table_number'] as String?,
      tableName: json['table_name'] as String?,
      zoneId: json['zone_id'] as String?,
      seatCount: json['seat_count'] as int?,
      userName: json['user_name'] as String?,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'table_id': tableId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'period': period,
      'guest_count': guestCount,
      'status': status,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'occasion': occasion,
      'dietary_restrictions': dietaryRestrictions.join(', '),
      'special_request': specialRequest,
      'total_amount': totalAmount,
      'created_at': createdAt,
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      bookingCode: bookingCode,
      userId: userId,
      restaurantId: restaurantId,
      tableId: tableId,
      bookingDate: DateTime.parse(bookingDate),
      bookingTime: bookingTime,
      period: period,
      guestCount: guestCount,
      status: status,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      occasion: occasion,
      dietaryRestrictions: dietaryRestrictions,
      specialRequest: specialRequest,
      totalAmount: totalAmount,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      restaurantName: restaurantName,
      tableNumber: tableNumber,
      tableName: tableName,
      zoneId: zoneId,
      seatCount: seatCount,
      userName: userName,
      items: items,
    );
  }
}
