import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/booking_entity.dart';

class BookingTicketViewWidget extends StatelessWidget {
  final BookingEntity reservation;
  final VoidCallback onNewBooking;
  final VoidCallback onViewMyBookings;
  final VoidCallback? onBackToHome;

  const BookingTicketViewWidget({
    super.key,
    required this.reservation,
    required this.onNewBooking,
    required this.onViewMyBookings,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateUtilsApp.formatThaiDateFull(reservation.bookingDate);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Congratulations Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 4),
                ),
                child: const Icon(Icons.check, color: Color(0xFF059669), size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'ยืนยันการจองโต๊ะสำเร็จ!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'เราได้บันทึกการจองโต๊ะที่ร้าน กินดีถ่ายข้อง เรียบร้อยแล้ว\n'
                'และได้ส่งข้อความยืนยันไปยัง ${reservation.customerEmail ?? "อีเมลของคุณ"}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              // Quick Actions Bar (Immediate Access without scrolling)
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onBackToHome ?? () => context.go('/'),
                    icon: const Icon(Icons.home_rounded, size: 20, color: Colors.white),
                    label: const Text(
                      'กลับไปยังหน้าโฮม',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onViewMyBookings,
                    icon: const Icon(Icons.receipt_long, size: 17, color: Color(0xFF374151)),
                    label: const Text(
                      'ดูรายการจองทั้งหมด',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onNewBooking,
                    icon: const Icon(Icons.add, size: 17, color: Color(0xFF0F766E)),
                    label: const Text(
                      'จองโต๊ะเพิ่ม / จองใหม่',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Luxury E-Ticket Pass Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Ticket Top Banner
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF141A16), Color(0xFF064E3B), Color(0xFF141A16)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Tooltip(
                            message: 'คลิกเพื่อกลับสู่หน้าโฮม',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onBackToHome ?? () => context.go('/'),
                                mouseCursor: SystemMouseCursors.click,
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              color: Color(0xFF34D399), size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            'OFFICIAL DINING RESERVATION PASS',
                                            style: TextStyle(
                                              color: const Color(0xFF34D399)
                                                  .withValues(alpha: 0.9),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'กินดีถ่ายข้อง • Kin Dee Thai Khong',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.home_outlined,
                                              color: Color(0xFF34D399), size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'ห้องอาหารสุขภาพ & โรงแรมเวลเนสรีสอร์ต (คลิกเพื่อกลับหน้าโฮม)',
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'BOOKING ID',
                                  style: TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  reservation.bookingCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'CONFIRMED',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Perforated Divider
                    CustomPaint(
                      size: const Size(double.infinity, 24),
                      painter: PerforatedDividerPainter(),
                    ),

                    // Ticket Details Body
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3 Metric Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  icon: Icons.calendar_today,
                                  label: 'วันและเวลาที่จอง',
                                  value: formattedDate,
                                  subValue: '${reservation.bookingTime} น.',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildMetricCard(
                                  icon: Icons.people_alt,
                                  label: 'จำนวนที่นั่ง',
                                  value: '${reservation.guestCount} ท่าน',
                                  subValue: reservation.occasion ?? 'ทั่วไป',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildMetricCard(
                                  icon: Icons.table_bar,
                                  label: 'โซน & โต๊ะ',
                                  value: reservation.tableNumber ?? 'T-01',
                                  subValue: reservation.tableName ?? 'โต๊ะอาหาร',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Guest Details
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ข้อมูลผู้จองโต๊ะ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'ชื่อ: ${reservation.customerName ?? "-"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'เบอร์โทร: ${reservation.customerPhone ?? "-"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (reservation.dietaryRestrictions.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'ข้อจำกัดอาหาร: ${reservation.dietaryRestrictions.join(", ")}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (reservation.specialRequest != null &&
                                    reservation.specialRequest!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'คำขอพิเศษ: ${reservation.specialRequest}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Pre-orders section
                          if (reservation.items.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
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
                                      const Text(
                                        'รายการอาหารสุขภาพที่สั่งล่วงหน้า',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        'รวม ฿${reservation.totalAmount.toStringAsFixed(0)} บาท',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...reservation.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '• ${item.name} x${item.quantity}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            '฿${item.totalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // QR Code verification card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141A16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CustomPaint(
                                  size: const Size(64, 64),
                                  painter: SimulatedQrPainter(),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'แสดงบัตรนี้ต่อพนักงานต้อนรับหน้าร้าน',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'สแกน QR Pass หรือแจ้งรหัสการจองเพื่อพาไปยังโต๊ะของท่านได้ทันที',
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onBackToHome ?? () => context.go('/'),
                    icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'กลับไปยังหน้าโฮม',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onViewMyBookings,
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('ดูรายการจองทั้งหมด'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onNewBooking,
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF0F766E)),
                    label: const Text(
                      'จองโต๊ะเพิ่ม / จองใหม่',
                      style: TextStyle(color: Color(0xFF0F766E)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF0F766E)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subValue,
            style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PerforatedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF9FAFB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Left and right semi-circle notches
    final notchPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawCircle(Offset(0, size.height / 2), 10, notchPaint);
    canvas.drawCircle(Offset(size.width, size.height / 2), 10, notchPaint);

    // Dashed line
    final dashPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5;

    double x = 16;
    while (x < size.width - 16) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 6, size.height / 2),
        dashPaint,
      );
      x += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SimulatedQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)),
      bgPaint,
    );

    final blackPaint = Paint()..color = Colors.black;

    // Corner eye squares (QR eyes)
    void drawEye(double left, double top) {
      canvas.drawRect(Rect.fromLTWH(left, top, 16, 16), blackPaint);
      canvas.drawRect(Rect.fromLTWH(left + 2, top + 2, 12, 12), bgPaint);
      canvas.drawRect(Rect.fromLTWH(left + 4, top + 4, 8, 8), blackPaint);
    }

    drawEye(4, 4);
    drawEye(size.width - 20, 4);
    drawEye(4, size.height - 20);

    // Simulated QR dots
    final dotPaint = Paint()..color = Colors.black;
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(24 + (i * 3.5), 10 + (j * 3.5), 2.5, 2.5),
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
