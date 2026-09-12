import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/booking_entity.dart';
import '../controllers/booking_controller.dart';

class MyBookingsModal extends StatefulWidget {
  final BookingController bookingController;
  final int userId;
  final ValueChanged<BookingEntity> onSelectBooking;

  const MyBookingsModal({
    super.key,
    required this.bookingController,
    required this.userId,
    required this.onSelectBooking,
  });

  @override
  State<MyBookingsModal> createState() => _MyBookingsModalState();
}

class _MyBookingsModalState extends State<MyBookingsModal> {
  int? _cancelingBookingId;

  @override
  void initState() {
    super.initState();
    widget.bookingController.loadMyBookings(widget.userId);
  }

  Future<void> _handleCancel(int bookingId) async {
    final ok = await widget.bookingController
        .cancelBooking(bookingId, widget.userId);
    if (mounted) {
      setState(() => _cancelingBookingId = null);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการจองเรียบร้อยแล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: const Color(0xFF141A16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month, color: Color(0xFF34D399), size: 22),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'การจองโต๊ะของฉัน (My Bookings)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ประวัติการจองและบัตร E-Ticket ห้องอาหารกินดีถ่ายข้อง',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Modal Body: Bookings List
            Expanded(
              child: ListenableBuilder(
                listenable: widget.bookingController,
                builder: (context, _) {
                  if (widget.bookingController.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                    );
                  }

                  final bookings = widget.bookingController.myBookings;
                  if (bookings.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 48, color: Color(0xFFD1D5DB)),
                          SizedBox(height: 12),
                          Text(
                            'ยังไม่มีรายการจองโต๊ะ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ท่านสามารถเลือกวัน เวลา และผังโต๊ะ เพื่อจองโต๊ะได้ทันที',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      final isCanceling = _cancelingBookingId == b.id;
                      final isCancelled = b.isCancelled;
                      final formattedDate =
                          DateUtilsApp.formatThaiDateMedium(b.bookingDate);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        b.bookingCode,
                                        style: const TextStyle(
                                          color: Color(0xFF065F46),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Courier',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      b.tableName ?? b.tableNumber ?? 'โต๊ะอาหาร',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isCancelled
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isCancelled ? 'ยกเลิกแล้ว' : 'ยืนยันแล้ว',
                                    style: TextStyle(
                                      color: isCancelled
                                          ? const Color(0xFF991B1B)
                                          : const Color(0xFF065F46),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('วันและเวลา:',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      '$formattedDate (${b.bookingTime} น.)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ผู้จอง / จำนวน:',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      '${b.customerName ?? "-"} (${b.guestCount} ท่าน)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('ยอดสั่งล่วงหน้า:',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      b.items.isNotEmpty
                                          ? '${b.items.length} เมนู (฿${b.totalAmount.toStringAsFixed(0)})'
                                          : 'สั่งที่ร้าน',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F766E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onSelectBooking(b);
                                  },
                                  icon: const Icon(Icons.qr_code,
                                      size: 16, color: Color(0xFF0F766E)),
                                  label: const Text(
                                    'ดูบัตร E-Ticket Pass',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                                if (!isCancelled) ...[
                                  if (isCanceling)
                                    Row(
                                      children: [
                                        const Text('ยืนยันยกเลิก? ',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red)),
                                        ElevatedButton(
                                          onPressed: () => _handleCancel(b.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text('ใช่',
                                              style: TextStyle(fontSize: 11)),
                                        ),
                                        const SizedBox(width: 4),
                                        OutlinedButton(
                                          onPressed: () => setState(
                                              () => _cancelingBookingId = null),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text('ไม่',
                                              style: TextStyle(fontSize: 11)),
                                        ),
                                      ],
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: () => setState(
                                          () => _cancelingBookingId = b.id),
                                      icon: const Icon(Icons.delete_outline,
                                          size: 15, color: Colors.grey),
                                      label: const Text(
                                        'ยกเลิกการจอง',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF141A16),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('ปิดหน้าต่าง'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
