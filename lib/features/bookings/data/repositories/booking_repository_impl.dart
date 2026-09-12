import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/create_booking_request.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDatasource datasource;

  BookingRepositoryImpl(this.datasource);

  @override
  Future<BookingEntity> createBooking(CreateBookingRequest request) async {
    final result = await datasource.createBooking(request);
    return result.toEntity();
  }

  @override
  Future<List<BookingEntity>> getMyBookings(int userId) async {
    final result = await datasource.getByUser(userId);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<BookingEntity>> getRestaurantBookings({
    required int restaurantId,
    required String date,
  }) async {
    final result = await datasource.getByRestaurantAndDate(
      restaurantId: restaurantId,
      date: date,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) {
    return datasource.cancelBooking(bookingId);
  }
}
