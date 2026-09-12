import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_local_datasource.dart';

class TableRepositoryImpl implements TableRepository {
  final TableLocalDatasource datasource;

  TableRepositoryImpl(this.datasource);

  @override
  Future<List<TableEntity>> getByRestaurant(int restaurantId) async {
    final result = await datasource.getByRestaurant(restaurantId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<TableEntity>> getTablesWithStatus({
    required int restaurantId,
    required String date,
    required String time,
  }) async {
    final result = await datasource.getTablesWithStatus(
      restaurantId: restaurantId,
      date: date,
      time: time,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<TableEntity>> getAvailable({
    required int restaurantId,
    required String date,
    required String time,
    int? minSeats,
  }) async {
    final result = await datasource.getAvailable(
      restaurantId: restaurantId,
      date: date,
      time: time,
      minSeats: minSeats,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<TableEntity?> getById(int id) async {
    final result = await datasource.getById(id);
    return result?.toEntity();
  }
}
