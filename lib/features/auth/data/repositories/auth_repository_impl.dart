import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await datasource.login(email, password);
    if (result == null) {
      throw Exception('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    }
    return result.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final result = await datasource.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
    return result.toEntity();
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    final result = await datasource.getUserById(id);
    return result?.toEntity();
  }
}
