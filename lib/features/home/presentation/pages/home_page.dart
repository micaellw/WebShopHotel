import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../bookings/presentation/controllers/booking_controller.dart';
import '../../../bookings/presentation/widgets/my_bookings_modal.dart';
import '../../../bookings/presentation/widgets/flutter_code_modal.dart';
import '../widgets/header_app_bar.dart';
import '../widgets/molecular_particles_background.dart';

class HomePage extends StatefulWidget {
  final AuthController authController;

  const HomePage({super.key, required this.authController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final BookingController _bookingController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bookingController = getIt<BookingController>();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final user = widget.authController.currentUser;
    if (user != null) {
      _bookingController.loadMyBookings(user.id);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openMyBookings() {
    final user = widget.authController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเข้าสู่ระบบเพื่อดูประวัติการจองของคุณ'),
          backgroundColor: const Color(0xFF141A16),
          action: SnackBarAction(
            label: 'เข้าสู่ระบบ',
            textColor: const Color(0xFF34D399),
            onPressed: () => context.go('/login'),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MyBookingsModal(
        bookingController: _bookingController,
        userId: user.id,
        onSelectBooking: (booking) {
          Navigator.of(ctx).pop();
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

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0D),
      appBar: HeaderAppBar(
        onOpenMyBookings: _openMyBookings,
        onOpenFlutterCode: _openFlutterCode,
        onLogin: () => context.go('/login'),
        onLogout: () {
          widget.authController.logout();
          setState(() {});
        },
        bookingCount: _bookingController.myBookings.length,
        userName: user?.name,
      ),
      body: MolecularParticlesBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Hero Section
              Container(
                constraints: const BoxConstraints(minHeight: 560),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                  vertical: isMobile ? 40 : 60,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Wellness Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF34D399).withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.spa, color: Color(0xFF34D399), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'THAI WELLNESS CUISINE & BOTANICAL RESORT',
                                style: TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main Brand Heading
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFE6FFFA),
                              Color(0xFF6EE7B7),
                              Color(0xFFFDE68A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'กินดีถ่ายข้อง',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 42 : 64,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          'ศาสตร์แห่งอาหารไทยบำบัดธาตุ ท่ามกลางธรรมชาติ 4 บรรยากาศริมสายน้ำ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 22,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFD1D5DB),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          'สัมผัสประสบการณ์ผังร้านแบบอินเทอร์แอคทีฟ สั่งอาหารเพื่อสุขภาพล่วงหน้า\nพร้อมระบบออกตั๋วรับรอง Luxury E-Ticket Pass อัตโนมัติ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 15,
                            color: const Color(0xFF9CA3AF),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Pulsing CTA Button to enter booking
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.45),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/booking/1'),
                              icon: const Icon(Icons.calendar_month,
                                  color: Colors.white, size: 22),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isMobile
                                        ? 'สำรองที่นั่งทันที'
                                        : 'สำรองโต๊ะอาหาร & สัมผัสประสบการณ์',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward,
                                      color: Color(0xFFA7F3D0), size: 20),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 36,
                                  vertical: isMobile ? 18 : 22,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(
                                    color: Color(0xFF34D399),
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Highlights Ribbon
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeaturePill(Icons.eco, 'วัตถุดิบอินทรีย์ 100%'),
                            _buildFeaturePill(Icons.health_and_safety, 'ปราศจากผงชูรส'),
                            _buildFeaturePill(Icons.layers, '4 โซนบรรยากาศ'),
                            _buildFeaturePill(Icons.lock_clock, 'ป้องกัน Booking Conflict ระดับ DB'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4 Atmosphere Zones Cards Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                  vertical: 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '4 โซนบรรยากาศเอกลักษณ์',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'เลือกโซนที่ต้องการและคลิกเพื่อสำรองที่นั่งในผังร้านแบบ 3D',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            if (!isMobile)
                              TextButton.icon(
                                onPressed: () => context.go('/booking/1'),
                                icon: const Icon(Icons.touch_app,
                                    color: Color(0xFF34D399), size: 18),
                                label: const Text(
                                  'เปิดผังโต๊ะทั้งหมด',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Grid of 4 Zones
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth < 600 ? 1 : 2;
                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: isMobile ? 1.4 : 1.7,
                              children: [
                                _buildZoneCard(
                                  title: 'Glasshouse Botanica',
                                  subtitle: 'เรือนกระจกพันธุ์ไม้เมืองร้อนริมสระบัว',
                                  tag: 'Signature Zone',
                                  icon: Icons.filter_vintage,
                                  color: const Color(0xFF0F766E),
                                  features: 'โต๊ะริมสระบัว • บูธโซฟากำมะหยี่ • ร่มรื่น',
                                  onTap: () => context.go('/booking/1'),
                                ),
                                _buildZoneCard(
                                  title: 'Secret Garden',
                                  subtitle: 'สวนบำบัดกลางแจ้งพร้อมลำธารหินธรรมชาติ',
                                  tag: 'Outdoor Oasis',
                                  icon: Icons.park,
                                  color: const Color(0xFF047857),
                                  features: 'ร่มเงาต้นไม้ใหญ่ • ไอหมอกน้ำตก • ลมธรรมชาติ',
                                  onTap: () => context.go('/booking/1'),
                                ),
                                _buildZoneCard(
                                  title: 'Private VIP Pavilion',
                                  subtitle: 'เรือนไม้สักทองส่วนตัวและบริการผู้ช่วย',
                                  tag: 'Exclusive Luxury',
                                  icon: Icons.workspace_premium,
                                  color: const Color(0xFFB45309),
                                  features: 'ห้องส่วนตัว • โต๊ะประชุมจัดเลี้ยง • Butler Service',
                                  onTap: () => context.go('/booking/1'),
                                ),
                                _buildZoneCard(
                                  title: 'Sky Wellness Terrace',
                                  subtitle: 'ดาดฟ้าชมวิวขอบฟ้าและพระอาทิตย์ตกดิน',
                                  tag: 'Sunset View',
                                  icon: Icons.wb_twilight,
                                  color: const Color(0xFF4338CA),
                                  features: 'บาร์ชาสมุนไพร • ระเบียงกระจก • แสงดาวค่ำคืน',
                                  onTap: () => context.go('/booking/1'),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF1F2923)),
                  ),
                  color: Color(0xFF0B0F0D),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'กินดีถ่ายข้อง (Kin Dee Thai Khong) — Thai Wellness Dining & Holistic Resort',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Clean Architecture with Flutter Web • SQLite Conflict-Safe Transactions • 2026',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141A16).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263228)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF34D399), size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard({
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
    required String features,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF141A16).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  features,
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'คลิกเพื่อเลือกโต๊ะโซนนี้',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios,
                    size: 11, color: Color(0xFF34D399)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
