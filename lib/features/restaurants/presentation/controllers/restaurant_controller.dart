import '../../../../core/base/base_controller.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/usecases/restaurant_usecases.dart';

class RestaurantController extends BaseController {
  final GetAllRestaurantsUseCase getAllUseCase;
  final GetRestaurantByIdUseCase getByIdUseCase;

  List<RestaurantEntity> _restaurants = [];
  List<RestaurantEntity> get restaurants => _restaurants;

  RestaurantEntity? _selected;
  RestaurantEntity? get selected => _selected;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  RestaurantController({
    required this.getAllUseCase,
    required this.getByIdUseCase,
  });

  Future<void> loadRestaurants({String? search}) async {
    _searchQuery = search ?? '';
    await runWithLoading(() async {
      _restaurants = await getAllUseCase.execute(search);
    });
  }

  Future<void> loadDetail(int id) async {
    await runWithLoading(() async {
      _selected = await getByIdUseCase.execute(id);
    });
  }

  void clearSelected() {
    _selected = null;
  }
}
