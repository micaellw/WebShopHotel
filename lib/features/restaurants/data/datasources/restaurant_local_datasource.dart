import '../../../../../core/database/database_helper.dart';
import '../models/restaurant_model.dart';

class RestaurantLocalDatasource {
  final DatabaseHelper dbHelper;

  RestaurantLocalDatasource(this.dbHelper);

  Future<List<RestaurantModel>> getAll({String? search}) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result;
    if (search != null && search.trim().isNotEmpty) {
      result = await db.query(
        'restaurants',
        where: 'name LIKE ? OR cuisine LIKE ? OR address LIKE ?',
        whereArgs: [
          '%${search.trim()}%',
          '%${search.trim()}%',
          '%${search.trim()}%'
        ],
        orderBy: 'rating DESC',
      );
    } else {
      result = await db.query('restaurants', orderBy: 'rating DESC');
    }
    return result.map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<RestaurantModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'restaurants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return RestaurantModel.fromJson(result.first);
  }
}
