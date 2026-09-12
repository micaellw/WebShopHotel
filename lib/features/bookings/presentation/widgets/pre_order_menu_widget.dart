import 'package:flutter/material.dart';
import '../../../menu/presentation/controllers/menu_controller.dart';

class PreOrderMenuWidget extends StatelessWidget {
  final WellnessMenuController menuController;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  static const List<Map<String, String>> categories = [
    {'id': 'all', 'label': 'เมนูทั้งหมด'},
    {'id': 'soup', 'label': 'ซุป & แกงอุ่นท้อง'},
    {'id': 'main', 'label': 'จานหลักไฟเบอร์สูง'},
    {'id': 'appetizer', 'label': 'เรียกน้ำย่อย'},
    {'id': 'drink', 'label': 'โพรไบโอติกส์ & ชา'},
    {'id': 'dessert', 'label': 'ของหวานเพื่อลำไส้'},
  ];

  const PreOrderMenuWidget({
    super.key,
    required this.menuController,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final items = menuController.filteredItems;
    final totalAmount = menuController.totalPreOrderPrice;
    final totalCount = menuController.totalItemCount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Wellness Intro Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Color(0xFF6EE7B7), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'แนวคิดห้องอาหาร "กินดี ถ่ายคล่อง"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'สั่งอาหารล่วงหน้าเพื่อสุขภาพกระเพาะและลำไส้ (Optional)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'สำรับอาหารปรุงสดใหม่ไร้ผงชูรส อุดมด้วยพรีไบโอติกส์ จุลินทรีย์มีชีวิต และเส้นใยอาหารธรรมชาติ '
                  'ช่วยให้ระบบทางเดินอาหารทำงานอย่างผาสุก (สามารถข้ามไปขั้นตอนถัดไปได้หากต้องการสั่งที่ร้าน)',
                  style: TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = menuController.selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (_) => menuController.setCategory(cat['id']!),
                    selectedColor: const Color(0xFF141A16),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF34D399) : const Color(0xFF374151),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Menu Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 270,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final qty = menuController.getItemQuantity(item.id);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: qty > 0 ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB),
                    width: qty > 0 ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Photo, Price, Calories
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFF3F4F6),
                            child: item.image != null
                                ? Image.network(
                                    item.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.fastfood,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  )
                                : const Icon(Icons.fastfood, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.isRecommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '★ เมนูแนะนำ Signature',
                                    style: TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.nameEn != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.nameEn!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '฿${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.calories} kcal',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Digestive Benefit Box
                    if (item.digestiveBenefit != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.eco, color: Color(0xFF059669), size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.digestiveBenefit!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF065F46),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Bottom: Quantity controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          qty > 0 ? 'สั่งแล้ว $qty จาน' : 'ยังไม่ได้เลือก',
                          style: TextStyle(
                            fontSize: 11,
                            color: qty > 0
                                ? const Color(0xFF0F766E)
                                : const Color(0xFF9CA3AF),
                            fontWeight: qty > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              if (qty > 0) ...[
                                InkWell(
                                  onTap: () => menuController.removeItem(item.id),
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                              InkWell(
                                onTap: () => menuController.addItem(item),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. Cart summary bar & navigation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('ย้อนกลับ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      totalCount > 0
                          ? 'สั่งอาหารล่วงหน้า $totalCount รายการ'
                          : 'ยังไม่มีอาหารพรีออเดอร์',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (totalCount > 0)
                      Text(
                        'ยอดรวม: ฿${totalAmount.toStringAsFixed(0)} บาท',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: Text(totalCount > 0 ? 'กรอกข้อมูลผู้จอง' : 'ข้าม / กรอกข้อมูลผู้จอง'),
                  label: const Icon(Icons.arrow_forward, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
}
