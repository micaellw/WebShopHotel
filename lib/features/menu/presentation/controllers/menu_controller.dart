import '../../../../core/base/base_controller.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/menu_usecases.dart';

class WellnessMenuController extends BaseController {
  final GetMenuItemsByRestaurantUseCase getMenuItemsUseCase;

  List<MenuItemEntity> _items = [];
  List<MenuItemEntity> get items => _items;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  final Map<String, PreOrderItemEntity> _preOrders = {};
  List<PreOrderItemEntity> get preOrders => _preOrders.values.toList();

  WellnessMenuController({required this.getMenuItemsUseCase});

  List<MenuItemEntity> get filteredItems {
    if (_selectedCategory == 'all') return _items;
    return _items.where((i) => i.category == _selectedCategory).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadMenu(int restaurantId) async {
    await runWithLoading(() async {
      _items = await getMenuItemsUseCase.execute(
        GetMenuItemsByRestaurantParams(restaurantId),
      );
    });
  }

  int getItemQuantity(String itemId) {
    return _preOrders[itemId]?.quantity ?? 0;
  }

  void addItem(MenuItemEntity item) {
    if (_preOrders.containsKey(item.id)) {
      final current = _preOrders[item.id]!;
      _preOrders[item.id] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _preOrders[item.id] = PreOrderItemEntity(menuItem: item, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    if (!_preOrders.containsKey(itemId)) return;
    final current = _preOrders[itemId]!;
    if (current.quantity > 1) {
      _preOrders[itemId] = current.copyWith(quantity: current.quantity - 1);
    } else {
      _preOrders.remove(itemId);
    }
    notifyListeners();
  }

  void clearCart() {
    _preOrders.clear();
    notifyListeners();
  }

  double get totalPreOrderPrice {
    return _preOrders.values.fold(0.0, (sum, p) => sum + p.totalPrice);
  }

  int get totalItemCount {
    return _preOrders.values.fold(0, (sum, p) => sum + p.quantity);
  }
}
