import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_local_datasource.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantLocalDatasource datasource;

  RestaurantRepositoryImpl(this.datasource);

  @override
  Future<List<RestaurantEntity>> getAll({String? search}) async {
    final result = await datasource.getAll(search: search);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<RestaurantEntity?> getById(int id) async {
    final result = await datasource.getById(id);
    return result?.toEntity();
  }
}
