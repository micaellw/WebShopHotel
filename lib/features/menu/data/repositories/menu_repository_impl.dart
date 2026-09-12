import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_local_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuLocalDatasource datasource;

  MenuRepositoryImpl(this.datasource);

  @override
  Future<List<MenuItemEntity>> getByRestaurant(int restaurantId) async {
    final result = await datasource.getByRestaurant(restaurantId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<MenuItemEntity>> getByCategory(int restaurantId, String category) async {
    final result = await datasource.getByCategory(restaurantId, category);
    return result.map((e) => e.toEntity()).toList();
  }
}
