import '../../../../core/base/base_usecase.dart';
import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

class GetTablesByRestaurantParams {
  final int restaurantId;
  const GetTablesByRestaurantParams(this.restaurantId);
}

class GetTablesByRestaurantUseCase
    extends BaseUseCase<List<TableEntity>, GetTablesByRestaurantParams> {
  final TableRepository repository;
  GetTablesByRestaurantUseCase(this.repository);

  @override
  Future<List<TableEntity>> execute(GetTablesByRestaurantParams params) {
    return repository.getByRestaurant(params.restaurantId);
  }
}

class GetTablesWithStatusParams {
  final int restaurantId;
  final String date;
  final String time;

  const GetTablesWithStatusParams({
    required this.restaurantId,
    required this.date,
    required this.time,
  });
}

class GetTablesWithStatusUseCase
    extends BaseUseCase<List<TableEntity>, GetTablesWithStatusParams> {
  final TableRepository repository;
  GetTablesWithStatusUseCase(this.repository);

  @override
  Future<List<TableEntity>> execute(GetTablesWithStatusParams params) {
    return repository.getTablesWithStatus(
      restaurantId: params.restaurantId,
      date: params.date,
      time: params.time,
    );
  }
}

class GetAvailableTablesParams {
  final int restaurantId;
  final String date;
  final String time;
  final int? minSeats;

  const GetAvailableTablesParams({
    required this.restaurantId,
    required this.date,
    required this.time,
    this.minSeats,
  });
}

class GetAvailableTablesUseCase
    extends BaseUseCase<List<TableEntity>, GetAvailableTablesParams> {
  final TableRepository repository;
  GetAvailableTablesUseCase(this.repository);

  @override
  Future<List<TableEntity>> execute(GetAvailableTablesParams params) {
    return repository.getAvailable(
      restaurantId: params.restaurantId,
      date: params.date,
      time: params.time,
      minSeats: params.minSeats,
    );
  }
}
