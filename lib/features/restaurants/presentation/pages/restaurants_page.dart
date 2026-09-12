import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/restaurant_controller.dart';
import '../widgets/restaurant_card.dart';

class RestaurantsPage extends StatefulWidget {
  final RestaurantController controller;

  const RestaurantsPage({super.key, required this.controller});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadRestaurants();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร้านอาหาร'),
        backgroundColor: const Color(0xFF141A16),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F766E).withValues(alpha: 0.05),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาร้านอาหาร...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    widget.controller.loadRestaurants();
                  },
                  icon: const Icon(Icons.clear),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) => widget.controller.loadRestaurants(search: v),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (ctx, _) {
                if (widget.controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = widget.controller.restaurants;
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('ไม่พบร้านอาหาร',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => RestaurantCard(
                    restaurant: list[i],
                    onTap: () => context.push('/restaurant/${list[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
