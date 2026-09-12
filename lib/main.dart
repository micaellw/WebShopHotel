import 'package:flutter/material.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/di/injection_container.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('th', null);
    await initializeDateFormatting('th_TH', null);
  } catch (_) {}
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = getIt<AuthController>();
    final router = buildRouter(authController);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
