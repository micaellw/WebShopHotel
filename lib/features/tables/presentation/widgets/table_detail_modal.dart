import 'package:flutter/material.dart';
import '../../domain/entities/table_entity.dart';

class TableDetailModal extends StatelessWidget {
  final TableEntity table;
  final String zoneName;
  final String zoneTemperature;
  final bool isSelected;
  final VoidCallback onSelect;

  const TableDetailModal({
    super.key,
    required this.table,
    required this.zoneName,
    required this.zoneTemperature,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isReserved = table.isReserved;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image & Badge Banner
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFF141A16),
                  child: table.photoUrl != null && table.photoUrl!.isNotEmpty
                      ? Image.network(
                          table.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.restaurant,
                                color: Color(0xFF0F766E), size: 48),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.restaurant,
                              color: Color(0xFF0F766E), size: 48),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Table Name & Status
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                zoneName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              table.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isReserved
                              ? const Color(0xFF4B5563)
                              : (isSelected
                                  ? const Color(0xFF34D399)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isReserved
                              ? 'จองแล้ว'
                              : (isSelected ? 'กำลังเลือก' : 'สถานะ: ว่าง'),
                          style: TextStyle(
                            color: isReserved
                                ? Colors.white
                                : (isSelected
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFF065F46)),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Modal Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specs: Seats & Temperature
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt,
                              color: Color(0xFF0F766E), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'รองรับสูงสุด: ${table.seatCount} ที่นั่ง',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.thermostat,
                              color: Color(0xFF0F766E), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            zoneTemperature,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Description
                  if (table.description != null &&
                      table.description!.isNotEmpty) ...[
                    const Text(
                      'คำอธิบายและบรรยากาศ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      table.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Features
                  if (table.features.isNotEmpty) ...[
                    const Text(
                      'จุดเด่นและสิ่งอำนวยความสะดวก',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: table.features.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF0F766E), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                f,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Min spend warning (VIP)
                  if (table.minSpend != null && table.minSpend! > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFFD97706), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'สำหรับห้อง VIP นี้ มียอดค่าอาหารและเครื่องดื่มขั้นต่ำ '
                              '฿${table.minSpend!.toStringAsFixed(0)} บาท',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('ปิดหน้าต่าง'),
                        ),
                      ),
                      if (!isReserved) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              onSelect();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xFF141A16)
                                  : const Color(0xFF0F766E),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check : Icons.touch_app,
                                  size: 16,
                                  color: isSelected
                                      ? const Color(0xFF34D399)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isSelected
                                      ? 'เลือกโต๊ะนี้แล้ว'
                                      : 'ยืนยันเลือกโต๊ะนี้',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
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
