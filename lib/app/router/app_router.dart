import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/restaurants/domain/entities/restaurant_entity.dart';
import '../../features/restaurants/presentation/controllers/restaurant_controller.dart';
import '../../features/restaurants/presentation/pages/restaurants_page.dart';
import '../../features/restaurants/presentation/pages/restaurant_detail_page.dart';
import '../../features/tables/presentation/controllers/table_controller.dart';
import '../../features/bookings/presentation/controllers/booking_controller.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/bookings/presentation/pages/booking_success_page.dart';
import '../../features/bookings/presentation/pages/booking_history_page.dart';
import '../../features/bookings/domain/entities/booking_entity.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'scaffold_with_nav.dart';

class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  static const String restaurants = '/restaurants';
  static const String restaurantDetail = '/restaurant/:id';
  static const String booking = '/booking/:restaurantId';
  static const String bookingSuccess = '/booking-success';
  static const String bookings = '/bookings';
  static const String home = '/';
}

final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthController authController) {
  return GoRouter(
    navigatorKey: rootNavKey,
    initialLocation: '/',
    refreshListenable: authController,
    redirect: (ctx, state) {
      final loggedIn = authController.isLoggedIn;
      final path = state.uri.toString();
      final isAuth = path.startsWith('/login') || path.startsWith('/register');
      final isHome = path == '/';

      // Home page is public - never redirect to login!
      if (isHome) return null;

      // Protected routes require login
      if (!loggedIn && !isAuth) return '/login';

      // Logged in users visiting login/register go to Home
      if (loggedIn && isAuth) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (_, s) => NoTransitionPage(
          child: LoginPage(controller: authController),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, s) => NoTransitionPage(
          child: RegisterPage(controller: authController),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavKey,
        builder: (_, state, child) => ScaffoldWithNav(
          state: state,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, s) => NoTransitionPage(
              child: HomePage(authController: authController),
            ),
          ),
          GoRoute(
            path: '/restaurants',
            redirect: (_, _) => '/booking/1',
          ),
          GoRoute(
            path: '/restaurant-list',
            pageBuilder: (_, s) => NoTransitionPage(
              child: RestaurantsPage(
                  controller: getIt<RestaurantController>()),
            ),
          ),
          GoRoute(
            path: '/restaurant/:id',
            pageBuilder: (_, s) {
              final id = int.parse(s.pathParameters['id']!);
              return MaterialPage(
                child: RestaurantDetailPage(
                  controller: getIt<RestaurantController>(),
                  restaurantId: id,
                ),
              );
            },
          ),
          GoRoute(
            path: '/booking/:restaurantId',
            pageBuilder: (_, s) {
              final rid = int.parse(s.pathParameters['restaurantId']!);
              final r = s.extra as RestaurantEntity?;
              return MaterialPage(
                child: BookingPage(
                  restaurantId: rid,
                  restaurant: r,
                  restaurantController: getIt<RestaurantController>(),
                  tableController: getIt<TableController>(),
                  bookingController: getIt<BookingController>(),
                  authController: authController,
                ),
              );
            },
          ),
          GoRoute(
            path: '/booking-success',
            pageBuilder: (_, s) {
              final b = s.extra as BookingEntity?;
              return MaterialPage(
                child: BookingSuccessPage(booking: b),
              );
            },
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (_, s) => NoTransitionPage(
              child: BookingHistoryPage(
                bookingController: getIt<BookingController>(),
                authController: authController,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
