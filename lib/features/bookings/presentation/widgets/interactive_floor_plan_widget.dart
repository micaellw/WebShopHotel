import 'package:flutter/material.dart';
import '../../../tables/domain/entities/table_entity.dart';
import '../../../tables/presentation/widgets/table_detail_modal.dart';

class ZoneItem {
  final String id;
  final String name;
  final String nameEn;
  final String ambiance;
  final String temperature;
  final IconData icon;

  const ZoneItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.ambiance,
    required this.temperature,
    required this.icon,
  });
}

class InteractiveFloorPlanWidget extends StatefulWidget {
  final List<TableEntity> tables;
  final String activeZoneId;
  final ValueChanged<String> onSelectZone;
  final TableEntity? selectedTable;
  final ValueChanged<TableEntity> onSelectTable;
  final int guestCount;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  static const List<ZoneItem> zones = [
    ZoneItem(
      id: 'glasshouse',
      name: 'โซนเรือนกระจก',
      nameEn: 'Glasshouse Pavilion',
      ambiance: 'แอร์เย็นสบาย • วิวสวนและสระบัว',
      temperature: '24°C ปรับอากาศ',
      icon: Icons.spa,
    ),
    ZoneItem(
      id: 'garden',
      name: 'โซนระเบียงสวนริมน้ำ',
      nameEn: 'Garden Waterside',
      ambiance: 'ร่มรื่น • ลมพัดเย็นธรรมชาติ',
      temperature: 'ลมธรรมชาติ & พัดลมไอน้ำ',
      icon: Icons.park,
    ),
    ZoneItem(
      id: 'vip',
      name: 'โซนห้องรับรองพิเศษ',
      nameEn: 'VIP Chamber',
      ambiance: 'เป็นส่วนตัว 100% • บริการบัตเลอร์',
      temperature: '22°C แอร์ส่วนตัว',
      icon: Icons.diamond,
    ),
    ZoneItem(
      id: 'rooftop',
      name: 'โซนดาดฟ้าพระอาทิตย์ตก',
      nameEn: 'Rooftop Sunset Deck',
      ambiance: 'โรแมนติก • ชมวิวพระอาทิตย์ตก 360°',
      temperature: 'ลมพัดสบายยอดตึก',
      icon: Icons.wb_twilight,
    ),
  ];

  const InteractiveFloorPlanWidget({
    super.key,
    required this.tables,
    required this.activeZoneId,
    required this.onSelectZone,
    required this.selectedTable,
    required this.onSelectTable,
    required this.guestCount,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<InteractiveFloorPlanWidget> createState() =>
      _InteractiveFloorPlanWidgetState();
}

class _InteractiveFloorPlanWidgetState extends State<InteractiveFloorPlanWidget> {
  String _viewMode = 'map'; // 'map' or 'grid'
  int? _capacityFilter;
  bool _onlyAvailable = false;

  void _openDetailModal(TableEntity table) {
    final zone = InteractiveFloorPlanWidget.zones.firstWhere(
      (z) => z.id == table.zoneId,
      orElse: () => InteractiveFloorPlanWidget.zones[0],
    );

    showDialog(
      context: context,
      builder: (_) => TableDetailModal(
        table: table,
        zoneName: zone.name,
        zoneTemperature: zone.temperature,
        isSelected: widget.selectedTable?.id == table.id,
        onSelect: () => widget.onSelectTable(table),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentZone = InteractiveFloorPlanWidget.zones.firstWhere(
      (z) => z.id == widget.activeZoneId,
      orElse: () => InteractiveFloorPlanWidget.zones[0],
    );

    // Filter tables for the active zone
    final zoneTables =
        widget.tables.where((t) => t.zoneId == widget.activeZoneId).toList();

    // Secondary filters
    final filteredTables = zoneTables.where((t) {
      if (_onlyAvailable && t.isReserved) return false;
      if (_capacityFilter != null) {
        if (_capacityFilter == 6) {
          return t.seatCount >= 6;
        }
        return t.seatCount == _capacityFilter;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Zone Selection Tabs
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                return GridView.count(
                  crossAxisCount: isNarrow ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: isNarrow ? 2.0 : 1.8,
                  children: InteractiveFloorPlanWidget.zones.map((zone) {
                    final isActive = zone.id == widget.activeZoneId;
                    final availCount = widget.tables
                        .where((t) => t.zoneId == zone.id && t.isAvailable)
                        .length;

                    return InkWell(
                      onTap: () => widget.onSelectZone(zone.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF141A16)
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE5E7EB),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  zone.icon,
                                  size: 16,
                                  color: isActive
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF0F766E),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: availCount > 0
                                        ? (isActive
                                            ? const Color(0xFF064E3B)
                                            : const Color(0xFFD1FAE5))
                                        : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    availCount > 0
                                        ? 'ว่าง $availCount โต๊ะ'
                                        : 'เต็ม',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: availCount > 0
                                          ? (isActive
                                              ? const Color(0xFF6EE7B7)
                                              : const Color(0xFF065F46))
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              zone.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              zone.temperature,
                              style: TextStyle(
                                fontSize: 10,
                                color: isActive
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 2. Filter & View Controls Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                // Capacity filter chips
                Wrap(
                  spacing: 6,
                  children: [
                    FilterChip(
                      label: const Text('ทั้งหมด'),
                      selected: _capacityFilter == null,
                      onSelected: (_) => setState(() => _capacityFilter = null),
                      selectedColor: const Color(0xFFD1FAE5),
                    ),
                    FilterChip(
                      label: const Text('2 ที่นั่ง'),
                      selected: _capacityFilter == 2,
                      onSelected: (_) => setState(() => _capacityFilter = 2),
                      selectedColor: const Color(0xFFD1FAE5),
                    ),
                    FilterChip(
                      label: const Text('4 ที่นั่ง'),
                      selected: _capacityFilter == 4,
                      onSelected: (_) => setState(() => _capacityFilter = 4),
                      selectedColor: const Color(0xFFD1FAE5),
                    ),
                    FilterChip(
                      label: const Text('6+ ที่นั่ง'),
                      selected: _capacityFilter == 6,
                      onSelected: (_) => setState(() => _capacityFilter = 6),
                      selectedColor: const Color(0xFFD1FAE5),
                    ),
                  ],
                ),

                // Toggles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Only available toggle
                    InkWell(
                      onTap: () =>
                          setState(() => _onlyAvailable = !_onlyAvailable),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _onlyAvailable,
                            onChanged: (v) =>
                                setState(() => _onlyAvailable = v ?? false),
                            activeColor: const Color(0xFF0F766E),
                          ),
                          const Text(
                            'เฉพาะโต๊ะว่าง',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Map / Grid toggle buttons
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'map',
                          icon: Icon(Icons.layers, size: 14),
                          label: Text('ผังร้าน'),
                        ),
                        ButtonSegment(
                          value: 'grid',
                          icon: Icon(Icons.grid_view, size: 14),
                          label: Text('ตาราง'),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (v) =>
                          setState(() => _viewMode = v.first),
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Interactive Floor Plan or Grid
          if (_viewMode == 'map') ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Custom Painted Botanical Garden & Water Canvas
                          CustomPaint(
                            size: Size(width, height),
                            painter: FloorPlanBackgroundPainter(
                              zoneId: widget.activeZoneId,
                            ),
                          ),

                          // Zone Ambiance Indicator
                          Positioned(
                            top: 14,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Icon(currentZone.icon,
                                      color: const Color(0xFF34D399), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currentZone.name} • ${currentZone.temperature}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Legend
                          Positioned(
                            top: 14,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Color(0xFF10B981)),
                                  SizedBox(width: 4),
                                  Text('ว่าง',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  SizedBox(width: 8),
                                  CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Color(0xFF6B7280)),
                                  SizedBox(width: 4),
                                  Text('จองแล้ว',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),

                          // Table interactive pins
                          ...filteredTables.map((table) {
                            final isSelected =
                                widget.selectedTable?.id == table.id;
                            final isReserved = table.isReserved;

                            // Calculate pixel coordinates
                            final tWidth = (table.width / 100) * width;
                            final tHeight = (table.height / 100) * height;
                            final tLeft =
                                (table.x / 100) * width - (tWidth / 2);
                            final tTop =
                                (table.y / 100) * height - (tHeight / 2);

                            return Positioned(
                              left: tLeft.clamp(0.0, width - tWidth),
                              top: tTop.clamp(0.0, height - tHeight),
                              width: tWidth,
                              height: tHeight,
                              child: _buildTableShapeWidget(
                                table: table,
                                isSelected: isSelected,
                                isReserved: isReserved,
                                onTap: () {
                                  if (!isReserved) {
                                    widget.onSelectTable(table);
                                  }
                                  _openDetailModal(table);
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ] else ...[
            // Grid View
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisExtent: 170,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredTables.length,
              itemBuilder: (context, index) {
                final table = filteredTables[index];
                final isSelected = widget.selectedTable?.id == table.id;
                final isReserved = table.isReserved;

                return InkWell(
                  onTap: () {
                    if (!isReserved) {
                      widget.onSelectTable(table);
                    }
                    _openDetailModal(table);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFECFDF5)
                          : (isReserved
                              ? const Color(0xFFF3F4F6)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF059669)
                            : (isReserved
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFFD1D5DB)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              table.tableNumber,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isReserved
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF0F766E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isReserved
                                    ? const Color(0xFFE5E7EB)
                                    : (isSelected
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD1FAE5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isReserved
                                    ? 'จองแล้ว'
                                    : (isSelected ? 'เลือกแล้ว' : 'ว่าง'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isReserved
                                      ? const Color(0xFF6B7280)
                                      : (isSelected
                                          ? Colors.white
                                          : const Color(0xFF065F46)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          table.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14, color: Color(0xFF6B7280)),
                            const SizedBox(width: 4),
                            Text(
                              '${table.seatCount} ที่นั่ง (${table.shape})',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        if (table.minSpend != null)
                          Text(
                            'ขั้นต่ำ ฿${table.minSpend!.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),

          // 4. Selected Table Summary & Navigation Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('ย้อนกลับ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),

                // Selected Table Info or Prompt
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: widget.selectedTable != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'โต๊ะที่เลือก: ${widget.selectedTable!.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.selectedTable!.seatCount} ที่นั่ง • ${currentZone.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : const Text(
                            'กรุณาคลิกเลือกโต๊ะบนผังร้านเพื่อดำเนินการต่อ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),

                // Continue button
                ElevatedButton.icon(
                  onPressed:
                      widget.selectedTable != null ? widget.onContinue : null,
                  icon: const Text('สั่งอาหารสุขภาพ (ถัดไป)'),
                  label: const Icon(Icons.arrow_forward, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTableShapeWidget({
    required TableEntity table,
    required bool isSelected,
    required bool isReserved,
    required VoidCallback onTap,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      bgColor = const Color(0xFF10B981);
      borderColor = const Color(0xFF34D399);
      textColor = Colors.black;
    } else if (isReserved) {
      bgColor = const Color(0xFF263228).withValues(alpha: 0.85);
      borderColor = const Color(0xFF374151);
      textColor = const Color(0xFF9CA3AF);
    } else {
      bgColor = const Color(0xFF0F766E).withValues(alpha: 0.85);
      borderColor = const Color(0xFF14B8A6);
      textColor = Colors.white;
    }

    BorderRadius borderRadius;
    if (table.shape == 'round') {
      borderRadius = BorderRadius.circular(100);
    } else if (table.shape == 'booth') {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(18));
    } else {
      borderRadius = BorderRadius.circular(10);
    }

    return Tooltip(
      message: '${table.name} (${table.seatCount} ที่นั่ง)\n'
          '${isReserved ? "จองแล้ว" : "สถานะ: ว่าง (คลิกเพื่อเลือก)"}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF34D399).withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Icon(Icons.check, color: Colors.black, size: 14)
              else if (isReserved)
                const Icon(Icons.lock, color: Color(0xFF9CA3AF), size: 12)
              else
                Icon(
                  table.shape == 'round'
                      ? Icons.circle_outlined
                      : Icons.chair_alt,
                  color: Colors.white70,
                  size: 12,
                ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  table.tableNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${table.seatCount} ที่',
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloorPlanBackgroundPainter extends CustomPainter {
  final String zoneId;

  const FloorPlanBackgroundPainter({required this.zoneId});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark botanical ground
    final bgPaint = Paint()..color = const Color(0xFF141A16);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Subtle architectural grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1F2923)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (zoneId == 'glasshouse' || zoneId == 'garden') {
      // Draw organic lotus stream / river curve
      final waterPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.22));

      final waterPath = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.16)
        ..quadraticBezierTo(
            size.width * 0.5, size.height * 0.24, 0, size.height * 0.16)
        ..close();

      canvas.drawPath(waterPath, waterPaint);

      // Lotus pond accent lilies
      final lilyPaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.4);
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.08), 8, lilyPaint);
      canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.10), 10, lilyPaint);
    } else if (zoneId == 'rooftop') {
      // Rooftop glass balcony edge & sunset accent glow
      final sunsetGlow = Paint()
        ..shader = RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sunsetGlow);

      final railingPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
        ..strokeWidth = 3;
      canvas.drawLine(Offset(0, 4), Offset(size.width, 4), railingPaint);
    } else if (zoneId == 'vip') {
      // Luxury teak floor partitions
      final woodBorderPaint = Paint()
        ..color = const Color(0xFF78350F).withValues(alpha: 0.3)
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.10, size.height * 0.15,
              size.width * 0.80, size.height * 0.75),
          const Radius.circular(16),
        ),
        woodBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloorPlanBackgroundPainter oldDelegate) =>
      oldDelegate.zoneId != zoneId;
}
