class CreateBookingItemRequest {
  final String menuId;
  final String name;
  final int quantity;
  final double price;
  final String? note;

  const CreateBookingItemRequest({
    required this.menuId,
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'note': note,
    };
  }
}

class CreateBookingRequest {
  final int userId;
  final int restaurantId;
  final int tableId;
  final String bookingDate;
  final String bookingTime;
  final String period;
  final int guestCount;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String occasion;
  final List<String> dietaryRestrictions;
  final String? specialRequest;
  final double totalAmount;
  final List<CreateBookingItemRequest> items;

  const CreateBookingRequest({
    required this.userId,
    required this.restaurantId,
    required this.tableId,
    required this.bookingDate,
    required this.bookingTime,
    this.period = 'lunch',
    required this.guestCount,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.occasion = 'general',
    this.dietaryRestrictions = const [],
    this.specialRequest,
    this.totalAmount = 0.0,
    this.items = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'restaurant_id': restaurantId,
      'table_id': tableId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'period': period,
      'guest_count': guestCount,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'occasion': occasion,
      'dietary_restrictions': dietaryRestrictions.join(', '),
      'special_request': specialRequest,
      'total_amount': totalAmount,
      'status': 'confirmed',
    };
  }
}
