import '../../../../core/base/base_usecase.dart';
import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetAllRestaurantsUseCase
    extends BaseUseCase<List<RestaurantEntity>, String?> {
  final RestaurantRepository repository;

  GetAllRestaurantsUseCase(this.repository);

  @override
  Future<List<RestaurantEntity>> execute(String? params) {
    return repository.getAll(search: params);
  }
}

class GetRestaurantByIdUseCase
    extends BaseUseCase<RestaurantEntity?, int> {
  final RestaurantRepository repository;

  GetRestaurantByIdUseCase(this.repository);

  @override
  Future<RestaurantEntity?> execute(int params) {
    return repository.getById(params);
  }
}
