import '../../../../core/base/base_controller.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/usecases/table_usecases.dart';

class TableController extends BaseController {
  final GetTablesByRestaurantUseCase getByRestaurantUseCase;
  final GetTablesWithStatusUseCase getTablesWithStatusUseCase;
  final GetAvailableTablesUseCase getAvailableUseCase;

  List<TableEntity> _tables = [];
  List<TableEntity> get tables => _tables;

  List<TableEntity> _availableTables = [];
  List<TableEntity> get availableTables => _availableTables;

  String _activeZoneId = 'glasshouse';
  String get activeZoneId => _activeZoneId;

  TableEntity? _selected;
  TableEntity? get selected => _selected;
  bool get hasSelected => _selected != null;

  TableEntity? _inspectingTable;
  TableEntity? get inspectingTable => _inspectingTable;

  TableController({
    required this.getByRestaurantUseCase,
    required this.getTablesWithStatusUseCase,
    required this.getAvailableUseCase,
  });

  void setZone(String zoneId) {
    _activeZoneId = zoneId;
    notifyListeners();
  }

  void selectTable(TableEntity? t) {
    _selected = t;
    notifyListeners();
  }

  void setInspectingTable(TableEntity? t) {
    _inspectingTable = t;
    notifyListeners();
  }

  Future<void> loadByRestaurant(int restaurantId) async {
    await runWithLoading(() async {
      _tables = await getByRestaurantUseCase
          .execute(GetTablesByRestaurantParams(restaurantId));
    });
  }

  Future<void> loadTablesWithStatus({
    required int restaurantId,
    required String date,
    required String time,
  }) async {
    await runWithLoading(() async {
      _tables = await getTablesWithStatusUseCase.execute(
        GetTablesWithStatusParams(
          restaurantId: restaurantId,
          date: date,
          time: time,
        ),
      );
      // Also update available
      _availableTables = _tables.where((t) => t.isAvailable).toList();
      if (_selected != null) {
        // If selected is now reserved, reset it
        final match = _tables.firstWhere(
          (t) => t.id == _selected!.id,
          orElse: () => _selected!,
        );
        if (match.isReserved) {
          _selected = null;
        } else {
          _selected = match;
        }
      }
    });
  }

  Future<void> loadAvailable({
    required int restaurantId,
    required String date,
    required String time,
    int? minSeats,
  }) async {
    _selected = null;
    await runWithLoading(() async {
      _availableTables = await getAvailableUseCase.execute(
        GetAvailableTablesParams(
          restaurantId: restaurantId,
          date: date,
          time: time,
          minSeats: minSeats,
        ),
      );
    });
  }
}
