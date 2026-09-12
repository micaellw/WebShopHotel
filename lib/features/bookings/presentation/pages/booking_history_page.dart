import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/booking_entity.dart';
import '../controllers/booking_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class BookingHistoryPage extends StatefulWidget {
  final BookingController bookingController;
  final AuthController authController;

  const BookingHistoryPage({
    super.key,
    required this.bookingController,
    required this.authController,
  });

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload();
    });
  }

  Future<void> _reload() async {
    final u = widget.authController.currentUser;
    if (u != null) {
      await widget.bookingController.loadMyBookings(u.id);
    } else {
      if (mounted) context.go('/login');
    }
  }

  Future<void> _cancel(BookingEntity b) async {
    final u = widget.authController.currentUser;
    if (u == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก'),
        content: const Text('คุณต้องการยกเลิกการจองนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ไม่')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ยกเลิกการจอง',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await widget.bookingController.cancelBooking(b.id, u.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'ยกเลิกการจองสำเร็จ' : 'ไม่สามารถยกเลิกได้'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการจอง'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListenableBuilder(
          listenable: widget.bookingController,
          builder: (_, _) {
            if (widget.bookingController.isLoading &&
                widget.bookingController.myBookings.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = widget.bookingController.myBookings;
            if (list.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('ยังไม่มีประวัติการจอง',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.restaurant),
                        label: const Text('ไปจองโต๊ะเลย'),
                        onPressed: () => context.go('/restaurants'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _buildItem(list[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BookingEntity b) {
    final isCancelled = b.isCancelled;
    final isPast = b.isPast;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: isCancelled
                ? Colors.grey.shade200
                : isPast
                    ? Colors.blue.shade50
                    : Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isCancelled
                      ? Icons.cancel
                      : isPast
                          ? Icons.history
                          : Icons.event_available,
                  color: isCancelled
                      ? Colors.grey
                      : isPast
                          ? Colors.blue
                          : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b.restaurantName ?? 'ร้านอาหาร #${b.restaurantId}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.grey.shade300
                        : isPast
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCancelled
                        ? 'ยกเลิกแล้ว'
                        : isPast
                            ? 'ผ่านไปแล้ว'
                            : 'ยืนยันแล้ว',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCancelled
                            ? Colors.grey.shade700
                            : isPast
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _infoCell(Icons.calendar_month,
                            DateUtilsApp.formatDate(b.bookingDate))),
                    Expanded(
                        child:
                            _infoCell(Icons.access_time, b.bookingTime)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _infoCell(Icons.table_restaurant,
                            'โต๊ะ ${b.tableNumber ?? '?'}')),
                    Expanded(
                        child: _infoCell(Icons.group,
                            '${b.guestCount} คน${b.seatCount != null ? ' / ${b.seatCount} ที่นั่ง' : ''}')),
                  ],
                ),
                if (b.specialRequest != null &&
                    b.specialRequest!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'หมายเหตุ: ${b.specialRequest}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isCancelled && !isPast) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.cancel),
                      label: const Text('ยกเลิกการจอง'),
                      onPressed: () => _cancel(b),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCell(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange.shade700),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }
}
