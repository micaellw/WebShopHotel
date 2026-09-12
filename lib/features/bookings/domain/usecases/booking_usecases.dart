import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/booking_entity.dart';
import '../entities/create_booking_request.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase
    extends BaseUseCase<BookingEntity, CreateBookingRequest> {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  @override
  Future<BookingEntity> execute(CreateBookingRequest request) async {
    if (request.userId <= 0) {
      throw Exception('กรุณาเข้าสู่ระบบก่อนจอง');
    }
    if (request.restaurantId <= 0) {
      throw Exception('ไม่พบร้านอาหาร');
    }
    if (request.tableId <= 0) {
      throw Exception('กรุณาเลือกโต๊ะ');
    }
    if (request.guestCount <= 0) {
      throw Exception('จำนวนผู้เข้าร่วมต้องมากกว่า 0');
    }
    if (request.guestCount > 20) {
      throw Exception('จำนวนผู้เข้าร่วมเกินกว่าที่รองรับ (สูงสุด 20 คน)');
    }
    if (request.bookingDate.isEmpty) {
      throw Exception('กรุณาเลือกวันที่จอง');
    }
    if (request.bookingTime.isEmpty) {
      throw Exception('กรุณาเลือกเวลาจอง');
    }
    final date = DateTime.tryParse(request.bookingDate);
    if (date == null) {
      throw Exception('รูปแบบวันที่ไม่ถูกต้อง');
    }
    if (DateUtilsApp.isDateInPast(date)) {
      throw Exception('ไม่สามารถจองวันที่ผ่านมาแล้ว');
    }
    return repository.createBooking(request);
  }
}

class GetMyBookingsUseCase
    extends BaseUseCase<List<BookingEntity>, int> {
  final BookingRepository repository;
  GetMyBookingsUseCase(this.repository);

  @override
  Future<List<BookingEntity>> execute(int params) {
    return repository.getMyBookings(params);
  }
}

class GetRestaurantBookingsParams {
  final int restaurantId;
  final String date;
  const GetRestaurantBookingsParams(
      {required this.restaurantId, required this.date});
}

class GetRestaurantBookingsUseCase
    extends BaseUseCase<List<BookingEntity>, GetRestaurantBookingsParams> {
  final BookingRepository repository;
  GetRestaurantBookingsUseCase(this.repository);

  @override
  Future<List<BookingEntity>> execute(GetRestaurantBookingsParams params) {
    return repository.getRestaurantBookings(
      restaurantId: params.restaurantId,
      date: params.date,
    );
  }
}

class CancelBookingUseCase extends BaseUseCase<void, int> {
  final BookingRepository repository;
  CancelBookingUseCase(this.repository);

  @override
  Future<void> execute(int params) {
    if (params <= 0) throw Exception('ไม่พบรายการจองที่จะยกเลิก');
    return repository.cancelBooking(params);
  }
}
