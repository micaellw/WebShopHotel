import 'package:get_it/get_it.dart';

import '../../core/database/database_helper.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

import '../../features/restaurants/data/datasources/restaurant_local_datasource.dart';
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurants/domain/repositories/restaurant_repository.dart';
import '../../features/restaurants/domain/usecases/restaurant_usecases.dart';
import '../../features/restaurants/presentation/controllers/restaurant_controller.dart';

import '../../features/tables/data/datasources/table_local_datasource.dart';
import '../../features/tables/data/repositories/table_repository_impl.dart';
import '../../features/tables/domain/repositories/table_repository.dart';
import '../../features/tables/domain/usecases/table_usecases.dart';
import '../../features/tables/presentation/controllers/table_controller.dart';

import '../../features/menu/data/datasources/menu_local_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/menu_usecases.dart';
import '../../features/menu/presentation/controllers/menu_controller.dart';

import '../../features/bookings/data/datasources/booking_local_datasource.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/booking_usecases.dart';
import '../../features/bookings/presentation/controllers/booking_controller.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  final dbHelper = getIt<DatabaseHelper>();
  await dbHelper.database;

  _setupAuth(dbHelper);
  _setupRestaurants(dbHelper);
  _setupTables(dbHelper);
  _setupMenu(dbHelper);
  _setupBookings(dbHelper);
}

void _setupAuth(DatabaseHelper dbHelper) {
  getIt.registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasource(dbHelper));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthLocalDatasource>()));
  getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<AuthController>(() => AuthController(
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
      ));
}

void _setupRestaurants(DatabaseHelper dbHelper) {
  getIt.registerLazySingleton<RestaurantLocalDatasource>(
      () => RestaurantLocalDatasource(dbHelper));
  getIt.registerLazySingleton<RestaurantRepository>(
      () => RestaurantRepositoryImpl(getIt<RestaurantLocalDatasource>()));
  getIt.registerLazySingleton<GetAllRestaurantsUseCase>(
      () => GetAllRestaurantsUseCase(getIt<RestaurantRepository>()));
  getIt.registerLazySingleton<GetRestaurantByIdUseCase>(
      () => GetRestaurantByIdUseCase(getIt<RestaurantRepository>()));
  getIt.registerLazySingleton<RestaurantController>(() => RestaurantController(
        getAllUseCase: getIt<GetAllRestaurantsUseCase>(),
        getByIdUseCase: getIt<GetRestaurantByIdUseCase>(),
      ));
}

void _setupTables(DatabaseHelper dbHelper) {
  getIt.registerLazySingleton<TableLocalDatasource>(
      () => TableLocalDatasource(dbHelper));
  getIt.registerLazySingleton<TableRepository>(
      () => TableRepositoryImpl(getIt<TableLocalDatasource>()));
  getIt.registerLazySingleton<GetTablesByRestaurantUseCase>(
      () => GetTablesByRestaurantUseCase(getIt<TableRepository>()));
  getIt.registerLazySingleton<GetTablesWithStatusUseCase>(
      () => GetTablesWithStatusUseCase(getIt<TableRepository>()));
  getIt.registerLazySingleton<GetAvailableTablesUseCase>(
      () => GetAvailableTablesUseCase(getIt<TableRepository>()));
  getIt.registerLazySingleton<TableController>(() => TableController(
        getByRestaurantUseCase: getIt<GetTablesByRestaurantUseCase>(),
        getTablesWithStatusUseCase: getIt<GetTablesWithStatusUseCase>(),
        getAvailableUseCase: getIt<GetAvailableTablesUseCase>(),
      ));
}

void _setupMenu(DatabaseHelper dbHelper) {
  getIt.registerLazySingleton<MenuLocalDatasource>(
      () => MenuLocalDatasource(dbHelper));
  getIt.registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(getIt<MenuLocalDatasource>()));
  getIt.registerLazySingleton<GetMenuItemsByRestaurantUseCase>(
      () => GetMenuItemsByRestaurantUseCase(getIt<MenuRepository>()));
  getIt.registerLazySingleton<WellnessMenuController>(() => WellnessMenuController(
        getMenuItemsUseCase: getIt<GetMenuItemsByRestaurantUseCase>(),
      ));
}

void _setupBookings(DatabaseHelper dbHelper) {
  getIt.registerLazySingleton<BookingLocalDatasource>(
      () => BookingLocalDatasource(dbHelper));
  getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt<BookingLocalDatasource>()));
  getIt.registerLazySingleton<CreateBookingUseCase>(
      () => CreateBookingUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<GetMyBookingsUseCase>(
      () => GetMyBookingsUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<CancelBookingUseCase>(
      () => CancelBookingUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<BookingController>(() => BookingController(
        createUseCase: getIt<CreateBookingUseCase>(),
        getMyBookingsUseCase: getIt<GetMyBookingsUseCase>(),
        cancelUseCase: getIt<CancelBookingUseCase>(),
      ));
}
