import '../../domain/entities/table_entity.dart';

class TableModel {
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

  TableModel({
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

  factory TableModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFeatures = [];
    final featVal = json['features'];
    if (featVal is String && featVal.isNotEmpty) {
      parsedFeatures = featVal.split(',').map((e) => e.trim()).toList();
    }

    return TableModel(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      tableNumber: json['table_number'] as String,
      name: (json['name'] as String?) ?? json['table_number'] as String,
      zoneId: (json['zone_id'] as String?) ?? (json['zone'] as String?) ?? 'glasshouse',
      seatCount: json['seat_count'] as int,
      shape: (json['shape'] as String?) ?? 'rect',
      status: (json['status'] as String?) ?? 'available',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 18,
      height: (json['height'] as num?)?.toDouble() ?? 14,
      features: parsedFeatures,
      photoUrl: json['photo_url'] as String?,
      minSpend: (json['min_spend'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'table_number': tableNumber,
      'name': name,
      'zone_id': zoneId,
      'seat_count': seatCount,
      'shape': shape,
      'status': status,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'features': features.join(','),
      'photo_url': photoUrl,
      'min_spend': minSpend,
      'description': description,
    };
  }

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      restaurantId: restaurantId,
      tableNumber: tableNumber,
      name: name,
      zoneId: zoneId,
      seatCount: seatCount,
      shape: shape,
      status: status,
      x: x,
      y: y,
      width: width,
      height: height,
      features: features,
      photoUrl: photoUrl,
      minSpend: minSpend,
      description: description,
    );
  }
}
