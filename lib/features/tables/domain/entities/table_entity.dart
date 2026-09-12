class TableEntity {
  final int id;
  final int restaurantId;
  final String tableNumber;
  final String name;
  final String zoneId;
  final int seatCount;
  final String shape;
  final String status;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<String> features;
  final String? photoUrl;
  final double? minSpend;
  final String? description;

  const TableEntity({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.name,
    required this.zoneId,
    required this.seatCount,
    this.shape = 'rect',
    required this.status,
    this.x = 0,
    this.y = 0,
    this.width = 18,
    this.height = 14,
    this.features = const [],
    this.photoUrl,
    this.minSpend,
    this.description,
  });

  bool get isAvailable => status == 'available';
  bool get isReserved => status == 'reserved';
}
