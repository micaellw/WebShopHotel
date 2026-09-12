import '../entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantEntity>> getAll({String? search});
  Future<RestaurantEntity?> getById(int id);
}
