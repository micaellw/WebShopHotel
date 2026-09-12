import '../../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  final DatabaseHelper dbHelper;

  AuthLocalDatasource(this.dbHelper);

  Future<UserModel?> login(String email, String password) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromJson(result.first);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final db = await dbHelper.database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('อีเมลนี้ถูกใช้งานแล้ว');
    }

    final now = DateTime.now().toIso8601String();
    final id = await db.insert('users', {
      'email': email.trim(),
      'password': password,
      'name': name.trim(),
      'phone': phone?.trim(),
      'role': 'user',
      'created_at': now,
    });

    return UserModel(
      id: id,
      email: email.trim(),
      password: password,
      name: name.trim(),
      phone: phone?.trim(),
      role: 'user',
      createdAt: now,
    );
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromJson(result.first);
  }
}
