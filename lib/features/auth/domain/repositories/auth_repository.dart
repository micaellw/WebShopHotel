import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  Future<UserEntity?> getUserById(int id);
}
