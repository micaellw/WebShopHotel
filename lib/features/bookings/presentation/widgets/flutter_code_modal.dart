import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterCodeModal extends StatefulWidget {
  const FlutterCodeModal({super.key});

  @override
  State<FlutterCodeModal> createState() => _FlutterCodeModalState();
}

class _FlutterCodeModalState extends State<FlutterCodeModal> {
  String _activeTab = 'architecture';
  bool _copied = false;

  final Map<String, String> _codeSnippets = {
    'architecture': '''
// Architecture Guidelines from send.md
// FLUTTER WEB CLEAN ARCHITECTURE
//
// UI
//  ↓
// Controller   (Manages State, no SQL, no direct Dio)
//  ↓
// UseCase      (Business Logic, Validation, Flow Rules)
//  ↓
// Repository   (Data Abstraction)
//  ↓
// Datasource   (Local SQLite / Network API Client)
//  ↓
// Database     (Transaction Conflict Prevention)
//
// สำคัญที่สุด: ป้องกัน Booking Conflict ในระดับ Database Transaction!
''',
    'floor_plan': '''
// lib/features/bookings/presentation/widgets/interactive_floor_plan_widget.dart
class FloorPlanBackgroundPainter extends CustomPainter {
  final String zoneId;
  FloorPlanBackgroundPainter({required this.zoneId});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark botanical ground
    final bgPaint = Paint()..color = const Color(0xFF141A16);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Stream and lotus pond curve
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.22));

    final waterPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.16)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.24, 0, size.height * 0.16)
      ..close();

    canvas.drawPath(waterPath, waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
''',
    'usecase': '''
// lib/features/bookings/domain/usecases/booking_usecases.dart
class CreateBookingUseCase extends BaseUseCase<BookingEntity, CreateBookingRequest> {
  final BookingRepository repository;
  CreateBookingUseCase(this.repository);

  @override
  Future<BookingEntity> execute(CreateBookingRequest request) async {
    if (request.guestCount <= 0) {
      throw ValidationFailure('จำนวนผู้ร่วมโต๊ะไม่ถูกต้อง');
    }
    return repository.createBooking(request);
  }
}
''',
  };

  void _copyCode() {
    final text = _codeSnippets[_activeTab] ?? '';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = _codeSnippets[_activeTab] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750, maxHeight: 600),
        child: Container(
          color: const Color(0xFF141A16),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.code, color: Color(0xFF22D3EE), size: 22),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flutter Web Clean Architecture',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'โครงสร้างระบบจองโต๊ะ "กินดีถ่ายข้อง" ตามมาตรฐาน send.md',
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

              // Tab Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: const Color(0xFF0F1411),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildTabButton('architecture', 'Clean Architecture'),
                        _buildTabButton('floor_plan', 'Floor Plan Painter'),
                        _buildTabButton('usecase', 'UseCase Logic'),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _copyCode,
                      icon: Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 14,
                        color: _copied
                            ? const Color(0xFF34D399)
                            : const Color(0xFF22D3EE),
                      ),
                      label: Text(
                        _copied ? 'คัดลอกแล้ว!' : 'Copy Code',
                        style: TextStyle(
                          fontSize: 11,
                          color: _copied
                              ? const Color(0xFF34D399)
                              : const Color(0xFF22D3EE),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Code Display
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF0A0E0C),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      currentCode,
                      style: const TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontFamily: 'Courier',
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                color: const Color(0xFF141A16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dart 3.x / Flutter 3.x Web • Clean Architecture per send.md',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('ปิด'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String id, String label) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF22D3EE) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF22D3EE) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
