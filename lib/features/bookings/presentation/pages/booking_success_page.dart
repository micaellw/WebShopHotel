import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/booking_entity.dart';

class BookingSuccessPage extends StatelessWidget {
  final BookingEntity? booking;

  const BookingSuccessPage({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A16),
        elevation: 1,
        title: Tooltip(
          message: 'กลับสู่หน้าหลัก (Home)',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/'),
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu, color: Color(0xFF34D399), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'กินดีถ่ายข้อง',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'จองโต๊ะสำเร็จ!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text('ขอบคุณที่ใช้บริการกินดีถ่ายข้อง',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  if (booking != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('รายละเอียดการจอง',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const Divider(height: 24),
                            _row('รหัสการจอง', '#${booking!.id}'),
                            _row(
                                'ร้านอาหาร',
                                booking!.restaurantName ??
                                    'ร้าน #${booking!.restaurantId}'),
                            _row('โต๊ะ',
                                '${booking!.tableNumber ?? 'T?'} (${booking!.seatCount ?? 0} ที่นั่ง)'),
                            _row('วันที่',
                                DateUtilsApp.formatDate(booking!.bookingDate)),
                            _row('เวลา', booking!.bookingTime),
                            _row('จำนวนแขก', '${booking!.guestCount} คน'),
                            if (booking!.specialRequest != null &&
                                booking!.specialRequest!.isNotEmpty)
                              _row('หมายเหตุ', booking!.specialRequest!),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('ยืนยันแล้ว',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF0F766E)),
                            foregroundColor: const Color(0xFF0F766E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('ดูประวัติการจอง'),
                          onPressed: () => context.go('/bookings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('กลับไปยังหน้าโฮม'),
                          onPressed: () => context.go('/'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
