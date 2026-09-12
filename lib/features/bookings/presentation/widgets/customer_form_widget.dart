import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../tables/domain/entities/table_entity.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';

class CustomerFormWidget extends StatefulWidget {
  final TableEntity? selectedTable;
  final String zoneName;
  final DateTime selectedDate;
  final String selectedTime;
  final String period;
  final int guestCount;
  final List<PreOrderItemEntity> preOrders;
  final bool isSubmitting;
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final Future<void> Function({
    required String name,
    required String phone,
    required String email,
    required String occasion,
    required List<String> dietaryRestrictions,
    String? specialRequest,
  }) onSubmit;
  final VoidCallback onBack;

  const CustomerFormWidget({
    super.key,
    required this.selectedTable,
    required this.zoneName,
    required this.selectedDate,
    required this.selectedTime,
    required this.period,
    required this.guestCount,
    required this.preOrders,
    required this.isSubmitting,
    this.initialName = '',
    this.initialPhone = '',
    this.initialEmail = '',
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<CustomerFormWidget> createState() => _CustomerFormWidgetState();
}

class _CustomerFormWidgetState extends State<CustomerFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _noteCtrl = TextEditingController();

  String _occasion = 'general';
  final Set<String> _selectedDietary = {};
  bool _agreePolicy = true;

  static const List<Map<String, String>> occasionOptions = [
    {'id': 'general', 'label': 'รับประทานอาหารทั่วไป'},
    {'id': 'birthday', 'label': 'ฉลองวันเกิด (รับเค้กสุขภาพฟรี)'},
    {'id': 'anniversary', 'label': 'วันครบรอบแต่งงาน/ความรัก'},
    {'id': 'family', 'label': 'รวมญาติ/สังสรรค์ครอบครัว'},
    {'id': 'business', 'label': 'เจรจาธุรกิจ/เลี้ยงรับรองลูกค้า'},
    {'id': 'date', 'label': 'เดตโรแมนติกสองต่อสอง'},
  ];

  static const List<String> dietaryOptions = [
    'ไม่ใส่ผงชูรส (No MSG)',
    'อาหารเจ / มังสวิรัติ (Vegetarian)',
    'ไม่ทานเนื้อสัตว์ใหญ่ (ทานปลา/ทะเลได้)',
    'แพ้อาหารทะเล/กุ้งปู',
    'แพ้ถั่วลิสง/กลูเตน',
    'รสชาติกลมกล่อมเผ็ดน้อย (Kids & Elderly)',
    'ขอเก้าอี้เด็กเสริม (Baby Highchair)',
    'ผู้ใช้รถเข็นวีลแชร์ (Wheelchair Access)',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณายอมรับเงื่อนไขการจองก่อนกดยืนยัน'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onSubmit(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      occasion: _occasion,
      dietaryRestrictions: _selectedDietary.toList(),
      specialRequest:
          _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final totalPreOrder = widget.preOrders.fold(0.0, (s, i) => s + i.totalPrice);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildFormInputs()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildSummarySidebar(totalPreOrder)),
                ],
              )
            else ...[
              _buildFormInputs(),
              const SizedBox(height: 24),
              _buildSummarySidebar(totalPreOrder),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Information Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.badge, color: Color(0xFF0F766E), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ข้อมูลผู้ติดต่อสำหรับการจอง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ - นามสกุลผู้จอง *',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                  hintText: 'เช่น คุณสุทัศน์ พิทักษ์ธรรม',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone & Email
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรศัพท์ติดต่อ *',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        hintText: '08X-XXX-XXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().length < 9) {
                          return 'กรุณากรอกเบอร์โทรศัพท์';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'อีเมลรับ E-Ticket *',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                        hintText: 'example@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || !val.contains('@')) {
                          return 'กรุณากรอกอีเมลที่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Occasion & Dietary Preferences Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.celebration, color: Color(0xFF0F766E), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'โอกาสพิเศษและข้อจำกัดอาหาร',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'โอกาสในการรับประทานอาหาร',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: occasionOptions.map((opt) {
                  final isSelected = _occasion == opt['id'];
                  return ChoiceChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _occasion = opt['id']!),
                    selectedColor: const Color(0xFFD1FAE5),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF065F46)
                          : const Color(0xFF374151),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              const Text(
                'ข้อจำกัดทางอาหาร / ความต้องการพิเศษ (เลือกได้หลายข้อ)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dietaryOptions.map((item) {
                  final isChecked = _selectedDietary.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isChecked,
                    onSelected: (checked) {
                      setState(() {
                        if (checked) {
                          _selectedDietary.add(item);
                        } else {
                          _selectedDietary.remove(item);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFD1FAE5),
                    checkmarkColor: const Color(0xFF059669),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: isChecked
                          ? const Color(0xFF065F46)
                          : const Color(0xFF374151),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'คำขอเพิ่มเติมถึงร้านอาหาร (Optional)',
                  hintText: 'เช่น ขอโต๊ะริมหน้าต่าง, จัดจานพิเศษสำหรับวันเกิด ฯลฯ',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Agree policy checkbox
              CheckboxListTile(
                value: _agreePolicy,
                onChanged: (val) => setState(() => _agreePolicy = val ?? true),
                activeColor: const Color(0xFF0F766E),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'ฉันยอมรับเงื่อนไขการจองโต๊ะและการรักษาเวลา (ร้านขอสงวนสิทธิ์โต๊ะไว้ 15 นาทีหลังจากเวลานัดหมาย)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySidebar(double totalPreOrder) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFF0F766E), size: 20),
              SizedBox(width: 8),
              Text(
                'สรุปรายละเอียดการจอง',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSummaryRow(
            'วัน-เวลา',
            '${DateUtilsApp.formatThaiDateShort(widget.selectedDate)} (${widget.selectedTime} น.)',
          ),
          _buildSummaryRow('จำนวนผู้ร่วมโต๊ะ', '${widget.guestCount} ท่าน'),
          _buildSummaryRow('โซนที่เลือก', widget.zoneName),
          _buildSummaryRow('โต๊ะที่เลือก', widget.selectedTable?.name ?? '-'),
          const Divider(height: 24),

          // Pre-orders summary
          const Text(
            'รายการอาหารสั่งล่วงหน้า',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.preOrders.isEmpty)
            const Text(
              'ไม่มี (สั่งที่ร้านในวันเข้ารับบริการ)',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            )
          else
            ...widget.preOrders.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${p.menuItem.name} x${p.quantity}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF4B5563)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '฿${p.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const Divider(height: 24),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดประเมินรวม',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '฿${totalPreOrder.toStringAsFixed(0)} บาท',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ยืนยันการจองโต๊ะ (Confirm)',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Back button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onBack,
              child: const Text('ย้อนกลับไปแก้ไขเมนูอาหาร'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
