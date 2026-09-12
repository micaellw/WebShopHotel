import '../../../../core/base/base_controller.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthController extends BaseController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  UserEntity? _currentUser;

  UserEntity? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
  });

  Future<bool> login(String email, String password) async {
    bool success = false;
    await runWithLoading(() async {
      final user = await loginUseCase.execute(LoginParams(
        email: email,
        password: password,
      ));
      _currentUser = user;
      success = true;
    });
    return success;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    String? phone,
  }) async {
    bool success = false;
    await runWithLoading(() async {
      final user = await registerUseCase.execute(RegisterParams(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        name: name,
        phone: phone,
      ));
      _currentUser = user;
      success = true;
    });
    return success;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
