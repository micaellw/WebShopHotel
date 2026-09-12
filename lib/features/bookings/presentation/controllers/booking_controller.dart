import 'package:intl/intl.dart';

import '../../../../core/base/base_controller.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/create_booking_request.dart';
import '../../domain/usecases/booking_usecases.dart';

class BookingController extends BaseController {
  final CreateBookingUseCase createUseCase;
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelBookingUseCase cancelUseCase;

  List<BookingEntity> _myBookings = [];
  List<BookingEntity> get myBookings => _myBookings;

  BookingEntity? _lastCreated;
  BookingEntity? get lastCreated => _lastCreated;

  BookingEntity? _activeReservation;
  BookingEntity? get activeReservation => _activeReservation;

  BookingController({
    required this.createUseCase,
    required this.getMyBookingsUseCase,
    required this.cancelUseCase,
  });

  void setActiveReservation(BookingEntity? r) {
    _activeReservation = r;
    notifyListeners();
  }

  void setLastCreated(BookingEntity? b) {
    _lastCreated = b;
    notifyListeners();
  }

  Future<bool> createBooking({
    required int userId,
    required int restaurantId,
    required int tableId,
    required DateTime date,
    required String time,
    String period = 'lunch',
    required int guestCount,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String occasion = 'general',
    List<String> dietaryRestrictions = const [],
    String? specialRequest,
    double totalAmount = 0.0,
    List<CreateBookingItemRequest> items = const [],
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    bool success = false;
    await runWithLoading(() async {
      final entity = await createUseCase.execute(CreateBookingRequest(
        userId: userId,
        restaurantId: restaurantId,
        tableId: tableId,
        bookingDate: dateStr,
        bookingTime: time,
        period: period,
        guestCount: guestCount,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        occasion: occasion,
        dietaryRestrictions: dietaryRestrictions,
        specialRequest: specialRequest,
        totalAmount: totalAmount,
        items: items,
      ));
      _lastCreated = entity;
      _activeReservation = entity;
      success = true;
    });
    return success;
  }

  Future<void> loadMyBookings(int userId) async {
    await runWithLoading(() async {
      _myBookings = await getMyBookingsUseCase.execute(userId);
    });
  }

  Future<bool> cancelBooking(int bookingId, int userId) async {
    bool success = false;
    await runWithLoading(() async {
      await cancelUseCase.execute(bookingId);
      success = true;
      await loadMyBookings(userId);
    });
    return success;
  }
}
