import '../entities/table_entity.dart';

abstract class TableRepository {
  Future<List<TableEntity>> getByRestaurant(int restaurantId);
  Future<List<TableEntity>> getTablesWithStatus({
    required int restaurantId,
    required String date,
    required String time,
  });
  Future<List<TableEntity>> getAvailable({
    required int restaurantId,
    required String date,
    required String time,
    int? minSeats,
  });
  Future<TableEntity?> getById(int id);
}
