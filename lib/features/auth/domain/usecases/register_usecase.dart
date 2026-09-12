import '../../../../core/base/base_usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String? phone;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.name,
    this.phone,
  });
}

class RegisterUseCase extends BaseUseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> execute(RegisterParams params) async {
    final email = params.email.trim();
    final name = params.name.trim();
    final password = params.password;
    final confirm = params.confirmPassword;

    if (name.isEmpty) throw Exception('กรุณากรอกชื่อ');
    if (email.isEmpty) throw Exception('กรุณากรอกอีเมล');
    if (!email.contains('@')) throw Exception('รูปแบบอีเมลไม่ถูกต้อง');
    if (password.isEmpty) throw Exception('กรุณากรอกรหัสผ่าน');
    if (password.length < 6) throw Exception('รหัสผ่านต้องมีอย่างน้อย 6 ตัว');
    if (password != confirm) throw Exception('รหัสผ่านไม่ตรงกัน');

    return repository.register(
      email: email,
      password: password,
      name: name,
      phone: params.phone?.trim(),
    );
  }
}
