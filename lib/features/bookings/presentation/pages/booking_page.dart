import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart';

import '../../../../app/di/injection_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/presentation/widgets/header_app_bar.dart';
import '../../../menu/presentation/controllers/menu_controller.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/presentation/controllers/restaurant_controller.dart';
import '../../../tables/presentation/controllers/table_controller.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/create_booking_request.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_progress_bar.dart';
import '../widgets/booking_ticket_view_widget.dart';
import '../widgets/customer_form_widget.dart';
import '../widgets/date_time_selector_widget.dart';
import '../widgets/flutter_code_modal.dart';
import '../widgets/interactive_floor_plan_widget.dart';
import '../widgets/my_bookings_modal.dart';
import '../widgets/pre_order_menu_widget.dart';

class BookingPage extends StatefulWidget {
  final int restaurantId;
  final RestaurantEntity? restaurant;
  final RestaurantController restaurantController;
  final TableController tableController;
  final BookingController bookingController;
  final AuthController authController;

  const BookingPage({
    super.key,
    required this.restaurantId,
    this.restaurant,
    required this.restaurantController,
    required this.tableController,
    required this.bookingController,
    required this.authController,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final WellnessMenuController _menuController;

  // Step Management
  int _currentStep = 1;
  int _maxReachedStep = 1;

  // Step 1: Date & Time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '12:00';
  String _period = 'lunch';
  int _guestCount = 2;

  // Submitting flag
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _menuController = getIt<WellnessMenuController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load restaurant details
      await widget.restaurantController.loadDetail(widget.restaurantId);

      // Load tables with availability status
      await _refreshTables();

      // Load healthy menu items
      await _menuController.loadMenu(widget.restaurantId);

      // Load user's bookings if logged in
      final user = widget.authController.currentUser;
      if (user != null) {
        await widget.bookingController.loadMyBookings(user.id);
      }
    });
  }

  Future<void> _refreshTables() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await widget.tableController.loadTablesWithStatus(
      restaurantId: widget.restaurantId,
      date: dateStr,
      time: _selectedTime,
    );
  }

  void _goToStep(int step) {
    if (step > 1 && DateUtilsApp.isBookingTimeInPast(_selectedDate, _selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกรอบเวลาที่เป็นเวลาล่วงหน้าในอนาคต (มากกว่าเวลาปัจจุบัน)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _currentStep = step;
      if (step > _maxReachedStep) {
        _maxReachedStep = step;
      }
    });
  }

  void _openMyBookings() {
    final user = widget.authController.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (_) => MyBookingsModal(
        bookingController: widget.bookingController,
        userId: user.id,
        onSelectBooking: (b) {
          widget.bookingController.setActiveReservation(b);
          setState(() {
            _currentStep = 5;
            _maxReachedStep = 5;
          });
        },
      ),
    );
  }

  void _openFlutterCode() {
    showDialog(
      context: context,
      builder: (_) => const FlutterCodeModal(),
    );
  }

  Future<void> _handleSubmitBooking({
    required String name,
    required String phone,
    required String email,
    required String occasion,
    required List<String> dietaryRestrictions,
    String? specialRequest,
  }) async {
    if (DateUtilsApp.isBookingTimeInPast(_selectedDate, _selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รอบเวลาที่เลือกเป็นเวลาในอดีต กรุณาเลือกรอบเวลาล่วงหน้าในอนาคต'),
          backgroundColor: Colors.red,
        ),
      );
      _goToStep(1);
      return;
    }

    final selectedTable = widget.tableController.selected;
    if (selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกโต๊ะในขั้นตอนที่ 2 ก่อน'),
          backgroundColor: Colors.redAccent,
        ),
      );
      _goToStep(2);
      return;
    }

    final user = widget.authController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนทำการจอง')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final preOrderItems = _menuController.preOrders.map((p) {
      return CreateBookingItemRequest(
        menuId: p.menuItem.id,
        name: p.menuItem.name,
        quantity: p.quantity,
        price: p.menuItem.price,
        note: p.note,
      );
    }).toList();

    final ok = await widget.bookingController.createBooking(
      userId: user.id,
      restaurantId: widget.restaurantId,
      tableId: selectedTable.id,
      date: _selectedDate,
      time: _selectedTime,
      period: _period,
      guestCount: _guestCount,
      customerName: name,
      customerPhone: phone,
      customerEmail: email,
      occasion: occasion,
      dietaryRestrictions: dietaryRestrictions,
      specialRequest: specialRequest,
      totalAmount: _menuController.totalPreOrderPrice,
      items: preOrderItems,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _goToStep(5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('จองโต๊ะสำเร็จ! บันทึกข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } else {
      final msg = widget.bookingController.errorMessage ??
          'ไม่สามารถจองโต๊ะได้ กรุณาลองใหม่อีกครั้ง';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
      await _refreshTables();
    }
  }

  void _startNewBooking() {
    _menuController.clearCart();
    widget.tableController.selectTable(null);
    setState(() {
      _currentStep = 1;
      _maxReachedStep = 1;
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = '12:00';
      _period = 'lunch';
      _guestCount = 2;
    });
    _refreshTables();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final activeReservation = widget.bookingController.activeReservation ??
        widget.bookingController.lastCreated;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: HeaderAppBar(
        onOpenMyBookings: _openMyBookings,
        onOpenFlutterCode: _openFlutterCode,
        bookingCount: widget.bookingController.myBookings.length,
        userName: user?.name,
        onLogout: () {
          widget.authController.logout();
        },
      ),
      body: Column(
        children: [
          // Step Progress Bar
          BookingProgressBar(
            currentStep: _currentStep,
            maxReachedStep: _maxReachedStep,
            onStepClick: _goToStep,
          ),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: _buildCurrentStepWidget(activeReservation),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget(BookingEntity? activeReservation) {
    switch (_currentStep) {
      case 1:
        return DateTimeSelectorWidget(
          selectedDate: _selectedDate,
          onSelectDate: (d) {
            setState(() => _selectedDate = d);
            _refreshTables();
          },
          selectedTime: _selectedTime,
          onSelectTime: (t) {
            setState(() => _selectedTime = t);
            _refreshTables();
          },
          period: _period,
          onSelectPeriod: (p) {
            setState(() {
              _period = p;
              final slots = DateTimeSelectorWidget.timeSlots[p] ?? [];
              if (slots.isNotEmpty) {
                _selectedTime = slots.first.time;
              }
            });
            _refreshTables();
          },
          guestCount: _guestCount,
          onUpdateGuestCount: (c) {
            setState(() => _guestCount = c);
            _refreshTables();
          },
          onContinue: () => _goToStep(2),
        );

      case 2:
        return ListenableBuilder(
          listenable: widget.tableController,
          builder: (context, _) {
            return InteractiveFloorPlanWidget(
              tables: widget.tableController.tables,
              activeZoneId: widget.tableController.activeZoneId,
              onSelectZone: (zoneId) =>
                  widget.tableController.setZone(zoneId),
              selectedTable: widget.tableController.selected,
              onSelectTable: (t) =>
                  widget.tableController.selectTable(t),
              guestCount: _guestCount,
              onContinue: () => _goToStep(3),
              onBack: () => _goToStep(1),
            );
          },
        );

      case 3:
        return ListenableBuilder(
          listenable: _menuController,
          builder: (context, _) {
            return PreOrderMenuWidget(
              menuController: _menuController,
              onContinue: () => _goToStep(4),
              onBack: () => _goToStep(2),
            );
          },
        );

      case 4:
        final user = widget.authController.currentUser;
        final selectedTable = widget.tableController.selected;
        final zone = InteractiveFloorPlanWidget.zones.firstWhere(
          (z) => z.id == widget.tableController.activeZoneId,
          orElse: () => InteractiveFloorPlanWidget.zones[0],
        );

        return CustomerFormWidget(
          selectedTable: selectedTable,
          zoneName: zone.name,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          period: _period,
          guestCount: _guestCount,
          preOrders: _menuController.preOrders,
          isSubmitting: _isSubmitting,
          initialName: user?.name ?? 'คุณสุทัศน์ พิทักษ์ธรรม',
          initialPhone: user?.phone ?? '081-234-5678',
          initialEmail: user?.email ?? 'sutas@example.com',
          onSubmit: _handleSubmitBooking,
          onBack: () => _goToStep(3),
        );

      case 5:
        if (activeReservation == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'ไม่พบบัตรการจอง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('กลับไปยังหน้าโฮม'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _startNewBooking,
                      icon: const Icon(Icons.add),
                      label: const Text('เริ่มการจองใหม่'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return BookingTicketViewWidget(
          reservation: activeReservation,
          onNewBooking: _startNewBooking,
          onViewMyBookings: _openMyBookings,
          onBackToHome: () => context.go('/'),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
