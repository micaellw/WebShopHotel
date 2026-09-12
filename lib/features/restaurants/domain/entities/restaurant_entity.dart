class RestaurantEntity {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final String? cuisine;
  final double rating;
  final int priceLevel;
  final String openTime;
  final String closeTime;
  final DateTime createdAt;

  const RestaurantEntity({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.imageUrl,
    this.cuisine,
    required this.rating,
    required this.priceLevel,
    required this.openTime,
    required this.closeTime,
    required this.createdAt,
  });

  String get priceLabel =>
      List.generate(priceLevel, (_) => '฿').join() +
      List.generate(4 - priceLevel, (_) => '').join();
}
