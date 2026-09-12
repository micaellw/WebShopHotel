import '../../../../../core/database/database_helper.dart';
import '../models/menu_item_model.dart';

class MenuLocalDatasource {
  final DatabaseHelper dbHelper;

  MenuLocalDatasource(this.dbHelper);

  Future<List<MenuItemModel>> getByRestaurant(int restaurantId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'menu_items',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
      orderBy: 'is_recommended DESC, id ASC',
    );
    return result.map((e) => MenuItemModel.fromJson(e)).toList();
  }

  Future<List<MenuItemModel>> getByCategory(int restaurantId, String category) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'menu_items',
      where: 'restaurant_id = ? AND category = ?',
      whereArgs: [restaurantId, category],
      orderBy: 'id ASC',
    );
    return result.map((e) => MenuItemModel.fromJson(e)).toList();
  }
}
