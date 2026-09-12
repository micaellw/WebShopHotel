import 'package:flutter/material.dart';

class StepItem {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;

  const StepItem({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class BookingProgressBar extends StatelessWidget {
  final int currentStep;
  final int maxReachedStep;
  final ValueChanged<int>? onStepClick;

  static const List<StepItem> steps = [
    StepItem(
      step: 1,
      title: 'วันที่ & เวลา',
      subtitle: 'Date & Time',
      icon: Icons.calendar_month,
    ),
    StepItem(
      step: 2,
      title: 'เลือกโซน & โต๊ะ',
      subtitle: 'Floor & Table Map',
      icon: Icons.map,
    ),
    StepItem(
      step: 3,
      title: 'สั่งเมนูสุขภาพ',
      subtitle: 'Wellness Menu',
      icon: Icons.restaurant,
    ),
    StepItem(
      step: 4,
      title: 'ข้อมูลผู้จอง',
      subtitle: 'Guest Info',
      icon: Icons.person,
    ),
    StepItem(
      step: 5,
      title: 'ยืนยันบัตรจอง',
      subtitle: 'E-Ticket Pass',
      icon: Icons.verified,
    ),
  ];

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    required this.maxReachedStep,
    this.onStepClick,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track line
              Positioned(
                left: 30,
                right: 30,
                top: 20,
                child: Container(
                  height: 2,
                  color: const Color(0xFFE5E7EB),
                ),
              ),

              // Active track line
              Positioned(
                left: 30,
                top: 20,
                child: Container(
                  height: 2,
                  width: (MediaQuery.of(context).size.width.clamp(300, 900) - 60) *
                      ((currentStep - 1).clamp(0, 4) / 4.0),
                  color: const Color(0xFF0F766E),
                ),
              ),

              // Steps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: steps.map((s) {
                  final isCompleted = currentStep > s.step;
                  final isCurrent = currentStep == s.step;
                  final isClickable = onStepClick != null &&
                      s.step <= maxReachedStep &&
                      s.step != 5;

                  Color circleColor;
                  Color iconColor;
                  BoxBorder? border;

                  if (isCompleted) {
                    circleColor = const Color(0xFF0F766E);
                    iconColor = Colors.white;
                  } else if (isCurrent) {
                    circleColor = const Color(0xFF141A16);
                    iconColor = const Color(0xFF34D399);
                    border = Border.all(color: const Color(0xFF6EE7B7), width: 2);
                  } else {
                    circleColor = const Color(0xFFF3F4F6);
                    iconColor = const Color(0xFF9CA3AF);
                    border = Border.all(color: const Color(0xFFE5E7EB));
                  }

                  return InkWell(
                    onTap: isClickable ? () => onStepClick!(s.step) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: circleColor,
                              shape: BoxShape.circle,
                              border: border,
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0F766E)
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : s.icon,
                              size: 18,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (!isCompact || isCurrent) ...[
                            Text(
                              s.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : (isCompleted
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                color: isCurrent
                                    ? const Color(0xFF141A16)
                                    : (isCompleted
                                        ? const Color(0xFF0F766E)
                                        : const Color(0xFF6B7280)),
                              ),
                            ),
                            if (!isCompact)
                              Text(
                                s.subtitle,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
