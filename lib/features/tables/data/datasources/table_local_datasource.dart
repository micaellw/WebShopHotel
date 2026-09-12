import '../../../../../core/database/database_helper.dart';
import '../models/table_model.dart';

class TableLocalDatasource {
  final DatabaseHelper dbHelper;

  TableLocalDatasource(this.dbHelper);

  Future<List<TableModel>> getByRestaurant(int restaurantId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'restaurant_tables',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
      orderBy: 'table_number ASC',
    );
    return result.map((e) => TableModel.fromJson(e)).toList();
  }

  Future<List<TableModel>> getTablesWithStatus({
    required int restaurantId,
    required String date,
    required String time,
  }) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT t.*,
             CASE
               WHEN b.id IS NOT NULL THEN 'reserved'
               ELSE t.status
             END AS dynamic_status
      FROM restaurant_tables t
      LEFT JOIN bookings b ON b.table_id = t.id
                          AND b.restaurant_id = t.restaurant_id
                          AND b.booking_date = ?
                          AND b.booking_time = ?
                          AND b.status != 'cancelled'
      WHERE t.restaurant_id = ?
      ORDER BY t.table_number ASC
    ''', [date, time, restaurantId]);

    return result.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['status'] = map['dynamic_status'] ?? map['status'] ?? 'available';
      return TableModel.fromJson(map);
    }).toList();
  }

  Future<List<TableModel>> getAvailable({
    required int restaurantId,
    required String date,
    required String time,
    int? minSeats,
  }) async {
    final db = await dbHelper.database;
    String where = 't.restaurant_id = ?';
    List<dynamic> args = [restaurantId];
    if (minSeats != null && minSeats > 0) {
      where += ' AND t.seat_count >= ?';
      args.add(minSeats);
    }
    final result = await db.rawQuery('''
      SELECT t.* FROM restaurant_tables t
      WHERE $where
      AND t.id NOT IN (
        SELECT b.table_id FROM bookings b
        WHERE b.restaurant_id = ?
          AND b.booking_date = ?
          AND b.booking_time = ?
          AND b.status != 'cancelled'
      )
      ORDER BY t.seat_count ASC, t.table_number ASC
    ''', [...args, restaurantId, date, time]);
    return result.map((e) => TableModel.fromJson(e)).toList();
  }

  Future<TableModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'restaurant_tables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return TableModel.fromJson(result.first);
  }
}
