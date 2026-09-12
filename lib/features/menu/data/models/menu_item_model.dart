import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel {
  final String id;
  final int restaurantId;
  final String name;
  final String? nameEn;
  final String category;
  final double price;
  final int calories;
  final String? description;
  final String? digestiveBenefit;
  final String? image;
  final List<String> tags;
  final bool isRecommended;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.nameEn,
    required this.category,
    required this.price,
    this.calories = 0,
    this.description,
    this.digestiveBenefit,
    this.image,
    this.tags = const [],
    this.isRecommended = false,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    final tVal = json['tags'];
    if (tVal is String && tVal.isNotEmpty) {
      parsedTags = tVal.split(',').map((e) => e.trim()).toList();
    }

    return MenuItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      digestiveBenefit: json['digestive_benefit'] as String?,
      image: json['image'] as String?,
      tags: parsedTags,
      isRecommended: (json['is_recommended'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'name_en': nameEn,
      'category': category,
      'price': price,
      'calories': calories,
      'description': description,
      'digestive_benefit': digestiveBenefit,
      'image': image,
      'tags': tags.join(','),
      'is_recommended': isRecommended ? 1 : 0,
    };
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      nameEn: nameEn,
      category: category,
      price: price,
      calories: calories,
      description: description,
      digestiveBenefit: digestiveBenefit,
      image: image,
      tags: tags,
      isRecommended: isRecommended,
    );
  }
}
