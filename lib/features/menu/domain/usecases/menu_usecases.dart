import '../../../../core/base/base_usecase.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class GetMenuItemsByRestaurantParams {
  final int restaurantId;
  const GetMenuItemsByRestaurantParams(this.restaurantId);
}

class GetMenuItemsByRestaurantUseCase
    extends BaseUseCase<List<MenuItemEntity>, GetMenuItemsByRestaurantParams> {
  final MenuRepository repository;
  GetMenuItemsByRestaurantUseCase(this.repository);

  @override
  Future<List<MenuItemEntity>> execute(GetMenuItemsByRestaurantParams params) {
    return repository.getByRestaurant(params.restaurantId);
  }
}
