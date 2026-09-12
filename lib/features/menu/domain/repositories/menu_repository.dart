import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<List<MenuItemEntity>> getByRestaurant(int restaurantId);
  Future<List<MenuItemEntity>> getByCategory(int restaurantId, String category);
}
