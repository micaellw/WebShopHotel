import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';

class TimeSlotItem {
  final String time;
  final String label;

  const TimeSlotItem({required this.time, required this.label});
}

class DateTimeSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final String selectedTime;
  final ValueChanged<String> onSelectTime;
  final String period; // 'lunch' | 'afternoon' | 'dinner'
  final ValueChanged<String> onSelectPeriod;
  final int guestCount;
  final ValueChanged<int> onUpdateGuestCount;
  final VoidCallback onContinue;

  static const Map<String, List<TimeSlotItem>> timeSlots = {
    'lunch': [
      TimeSlotItem(time: '11:00', label: '11:00 น. (เริ่มมื้อเที่ยง)'),
      TimeSlotItem(time: '11:30', label: '11:30 น.'),
      TimeSlotItem(time: '12:00', label: '12:00 น. (ยอดนิยม)'),
      TimeSlotItem(time: '12:30', label: '12:30 น. (ยอดนิยม)'),
      TimeSlotItem(time: '13:00', label: '13:00 น.'),
      TimeSlotItem(time: '13:30', label: '13:30 น.'),
    ],
    'afternoon': [
      TimeSlotItem(time: '14:00', label: '14:00 น. (High Tea บ่าย)'),
      TimeSlotItem(time: '14:30', label: '14:30 น.'),
      TimeSlotItem(time: '15:00', label: '15:00 น. (ชมสวนรับลม)'),
      TimeSlotItem(time: '15:30', label: '15:30 น.'),
      TimeSlotItem(time: '16:00', label: '16:00 น.'),
      TimeSlotItem(time: '16:30', label: '16:30 น.'),
    ],
    'dinner': [
      TimeSlotItem(time: '17:00', label: '17:00 น. (ชมพระอาทิตย์ตก)'),
      TimeSlotItem(time: '17:30', label: '17:30 น. (Golden Hour)'),
      TimeSlotItem(time: '18:00', label: '18:00 น. (ดนตรีสดเริ่ม)'),
      TimeSlotItem(time: '18:30', label: '18:30 น. (มื้อค่ำยอดนิยม)'),
      TimeSlotItem(time: '19:00', label: '19:00 น.'),
      TimeSlotItem(time: '19:30', label: '19:30 น.'),
      TimeSlotItem(time: '20:00', label: '20:00 น. (Late Dinner)'),
      TimeSlotItem(time: '20:30', label: '20:30 น.'),
    ],
  };

  const DateTimeSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.selectedTime,
    required this.onSelectTime,
    required this.period,
    required this.onSelectPeriod,
    required this.guestCount,
    required this.onUpdateGuestCount,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateList = List.generate(14, (i) => now.add(Duration(days: i)));
    final currentSlots = timeSlots[period] ?? timeSlots['lunch']!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF134E4A), Color(0xFF141A16)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF6EE7B7), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'ห้องอาหารเพื่อสุขภาพและระบบทางเดินอาหาร',
                        style: TextStyle(
                          color: Color(0xFFD1FAE5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'จองโต๊ะรับประทานอาหาร กินดีถ่ายข้อง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'เลือกวัน เวลา และจำนวนผู้ร่วมโต๊ะ เพื่อสัมผัสสำรับอาหารไทยร่วมสมัย '
                  'คัดสรรวัตถุดิบไฟเบอร์สูงและจุลินทรีย์มีชีวิต ปรับสมดุลระบบย่อย ในบรรยากาศรีสอร์ตริมน้ำ',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Date Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF0F766E), size: 20),
                        SizedBox(width: 8),
                        Text(
                          '1. เลือกวันที่ต้องการจอง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        DateUtilsApp.formatThaiDateFull(selectedDate),
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Horizontal scrollable date cards
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dateList.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = dateList[index];
                      final isSelected = selectedDate.year == date.year &&
                          selectedDate.month == date.month &&
                          selectedDate.day == date.day;
                      final isToday = index == 0;
                      final isTomorrow = index == 1;
                      final isWeekend = date.weekday == DateTime.saturday ||
                          date.weekday == DateTime.sunday;

                      final dayName = isToday
                          ? 'วันนี้'
                          : (isTomorrow ? 'พรุ่งนี้' : DateUtilsApp.formatThaiDayShort(date));

                      return InkWell(
                        onTap: () => onSelectDate(date),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 72,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF141A16)
                                : (isWeekend
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF9FAFB)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : (isWeekend
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFFE5E7EB)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF34D399)
                                      : (isWeekend
                                          ? const Color(0xFF92400E)
                                          : const Color(0xFF6B7280)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateUtilsApp.formatThaiMonthShort(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Meal Period & Time Slots
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                    Icon(Icons.access_time, color: Color(0xFF0F766E), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '2. เลือกช่วงเวลาและรอบเวลา',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Period Tabs
                Row(
                  children: [
                    Expanded(
                      child: _buildPeriodButton(
                        id: 'lunch',
                        title: 'มื้อเที่ยง',
                        timeSpan: '11:00 - 14:00',
                        icon: Icons.wb_sunny,
                        isActive: period == 'lunch',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPeriodButton(
                        id: 'afternoon',
                        title: 'ชายามบ่าย',
                        timeSpan: '14:00 - 17:00',
                        icon: Icons.coffee,
                        isActive: period == 'afternoon',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPeriodButton(
                        id: 'dinner',
                        title: 'มื้อค่ำ',
                        timeSpan: '17:00 - 21:30',
                        icon: Icons.nightlight_round,
                        isActive: period == 'dinner',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time slots grid
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: currentSlots.map((slot) {
                    final isPast = DateUtilsApp.isBookingTimeInPast(selectedDate, slot.time);
                    final isSelected = selectedTime == slot.time;
                    return InkWell(
                      onTap: isPast ? null : () => onSelectTime(slot.time),
                      borderRadius: BorderRadius.circular(12),
                      child: Opacity(
                        opacity: isPast ? 0.4 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isPast
                                ? const Color(0xFFF3F4F6)
                                : (isSelected
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFF9FAFB)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPast
                                  ? const Color(0xFFE5E7EB)
                                  : (isSelected
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPast ? Icons.block : Icons.schedule,
                                size: 14,
                                color: isPast
                                    ? const Color(0xFF9CA3AF)
                                    : (isSelected ? Colors.white : const Color(0xFF0F766E)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPast ? '${slot.label} (ผ่านรอบแล้ว)' : slot.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: isPast ? TextDecoration.lineThrough : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isPast
                                      ? const Color(0xFF9CA3AF)
                                      : (isSelected ? Colors.white : const Color(0xFF1F2937)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Guest Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                    Icon(Icons.group, color: Color(0xFF0F766E), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '3. จำนวนผู้ร่วมโต๊ะ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Stepper (- / +)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: guestCount > 1
                                ? () => onUpdateGuestCount(guestCount - 1)
                                : null,
                            icon: const Icon(Icons.remove, size: 18),
                            color: const Color(0xFF374151),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 40),
                            child: Text(
                              '$guestCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: guestCount < 20
                                ? () => onUpdateGuestCount(guestCount + 1)
                                : null,
                            icon: const Icon(Icons.add, size: 18),
                            color: const Color(0xFF0F766E),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'ท่าน',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(width: 20),

                    // Quick Chips
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [2, 4, 6, 8, 10].map((c) {
                          final isMatch = guestCount == c;
                          return ChoiceChip(
                            label: Text('$c ท่าน'),
                            selected: isMatch,
                            onSelected: (_) => onUpdateGuestCount(c),
                            selectedColor: const Color(0xFFD1FAE5),
                            labelStyle: TextStyle(
                              color: isMatch ? const Color(0xFF065F46) : const Color(0xFF4B5563),
                              fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: const Color(0xFFF3F4F6),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 5. Action Button & Warning
          Builder(
            builder: (context) {
              final isPast = DateUtilsApp.isBookingTimeInPast(selectedDate, selectedTime);
              return Column(
                children: [
                  if (isPast)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'รอบเวลาที่เลือกเป็นเวลาที่ผ่านไปแล้ว กรุณาเลือกรอบเวลาที่เป็นเวลาล่วงหน้าในอนาคต (มากกว่าเวลาปัจจุบัน)',
                              style: TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isPast ? null : onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: isPast ? 0 : 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ขั้นตอนถัดไป: เลือกโซนและโต๊ะอาหาร',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required String id,
    required String title,
    required String timeSpan,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => onSelectPeriod(id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF141A16) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF34D399) : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeSpan,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
