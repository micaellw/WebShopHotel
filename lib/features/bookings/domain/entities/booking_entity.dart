class BookingItemEntity {
  final int id;
  final int bookingId;
  final String menuId;
  final String name;
  final int quantity;
  final double price;
  final String? note;

  const BookingItemEntity({
    required this.id,
    required this.bookingId,
    required this.menuId,
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  double get totalPrice => price * quantity;
}

class BookingEntity {
  final int id;
  final String bookingCode;
  final int userId;
  final int restaurantId;
  final int tableId;
  final DateTime bookingDate;
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
  final DateTime createdAt;

  final String? restaurantName;
  final String? tableNumber;
  final String? tableName;
  final String? zoneId;
  final int? seatCount;
  final String? userName;
  final List<BookingItemEntity> items;

  const BookingEntity({
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

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isPast {
    final now = DateTime.now();
    return bookingDate.isBefore(DateTime(now.year, now.month, now.day));
  }
}
