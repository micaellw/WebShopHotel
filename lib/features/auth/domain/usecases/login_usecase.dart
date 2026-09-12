import '../../../../core/base/base_usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase extends BaseUseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<UserEntity> execute(LoginParams params) async {
    final email = params.email.trim();
    final password = params.password;

    if (email.isEmpty) throw Exception('กรุณากรอกอีเมล');
    if (!email.contains('@')) throw Exception('รูปแบบอีเมลไม่ถูกต้อง');
    if (password.isEmpty) throw Exception('กรุณากรอกรหัสผ่าน');
    if (password.length < 6) throw Exception('รหัสผ่านต้องมีอย่างน้อย 6 ตัว');

    return repository.login(email, password);
  }
}
