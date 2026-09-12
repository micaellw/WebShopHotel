import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/restaurant_controller.dart';

class RestaurantDetailPage extends StatefulWidget {
  final RestaurantController controller;
  final int restaurantId;

  const RestaurantDetailPage({
    super.key,
    required this.controller,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.orange, Colors.pink, Colors.teal, Colors.indigo];

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดร้าน'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (ctx, _) {
          if (widget.controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final r = widget.controller.selected;
          if (r == null) {
            return const Center(child: Text('ไม่พบข้อมูลร้านอาหาร'));
          }
          final bg = colors[r.id % colors.length];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 220,
                  color: bg.withValues(alpha: 0.2),
                  child:
                      Center(child: Icon(Icons.restaurant, size: 120, color: bg)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text('${r.rating.toStringAsFixed(1)} / 5.0',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money,
                              size: 20, color: Colors.green.shade700),
                          const SizedBox(width: 2),
                          Text(List.generate(r.priceLevel, (_) => '฿').join(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: bg.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(r.cuisine ?? 'ทั่วไป',
                                style: TextStyle(
                                    color: bg, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoTile(Icons.access_time, 'เวลาเปิดทำการ',
                          '${r.openTime} - ${r.closeTime}'),
                      if (r.address != null && r.address!.isNotEmpty)
                        _buildInfoTile(Icons.location_on, 'ที่อยู่', r.address!),
                      if (r.phone != null && r.phone!.isNotEmpty)
                        _buildInfoTile(Icons.phone, 'ติดต่อ', r.phone!),
                      const SizedBox(height: 20),
                      if (r.description != null && r.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('เกี่ยวกับร้าน',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(r.description!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5)),
                          ],
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.event_seat),
                          label: const Text('จองโต๊ะเลย',
                              style: TextStyle(fontSize: 18)),
                          onPressed: () => context.push(
                            '/booking/${r.id}',
                            extra: r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey, height: 1.2)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
