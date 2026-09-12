import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel {
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
  final String createdAt;

  RestaurantModel({
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

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      cuisine: json['cuisine'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      priceLevel: (json['price_level'] as int?) ?? 2,
      openTime: (json['open_time'] as String?) ?? '10:00',
      closeTime: (json['close_time'] as String?) ?? '22:00',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'image_url': imageUrl,
      'cuisine': cuisine,
      'rating': rating,
      'price_level': priceLevel,
      'open_time': openTime,
      'close_time': closeTime,
      'created_at': createdAt,
    };
  }

  RestaurantEntity toEntity() {
    return RestaurantEntity(
      id: id,
      name: name,
      description: description,
      address: address,
      phone: phone,
      imageUrl: imageUrl,
      cuisine: cuisine,
      rating: rating,
      priceLevel: priceLevel,
      openTime: openTime,
      closeTime: closeTime,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
