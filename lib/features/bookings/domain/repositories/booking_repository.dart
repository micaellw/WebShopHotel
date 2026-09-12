import '../entities/booking_entity.dart';
import '../entities/create_booking_request.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking(CreateBookingRequest request);
  Future<List<BookingEntity>> getMyBookings(int userId);
  Future<List<BookingEntity>> getRestaurantBookings({
    required int restaurantId,
    required String date,
  });
  Future<void> cancelBooking(int bookingId);
}
