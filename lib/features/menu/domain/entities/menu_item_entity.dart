class MenuItemEntity {
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

  const MenuItemEntity({
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
}

class PreOrderItemEntity {
  final MenuItemEntity menuItem;
  final int quantity;
  final String? note;

  const PreOrderItemEntity({
    required this.menuItem,
    required this.quantity,
    this.note,
  });

  PreOrderItemEntity copyWith({
    MenuItemEntity? menuItem,
    int? quantity,
    String? note,
  }) {
    return PreOrderItemEntity(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  double get totalPrice => menuItem.price * quantity;
}
