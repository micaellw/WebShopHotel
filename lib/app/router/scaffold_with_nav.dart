import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const ScaffoldWithNav({
    super.key,
    required this.child,
    required this.state,
  });

  int _currentIndex() {
    final loc = state.uri.toString();
    if (loc.startsWith('/bookings')) return 1;
    if (loc.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext ctx, int i) {
    switch (i) {
      case 0:
        ctx.go('/booking/1');
        break;
      case 1:
        ctx.go('/bookings');
        break;
      case 2:
        _showProfileMenu(ctx);
        break;
    }
  }

  void _showProfileMenu(BuildContext ctx) {
    final auth = getIt<AuthController>();
    showModalBottomSheet(
      context: ctx,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFD1FAE5),
                      child: Text(
                        (auth.currentUser?.name ?? '?')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.name ?? 'Guest',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(auth.currentUser?.email ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Color(0xFF0F766E)),
                  title: const Text('จองโต๊ะ กินดีถ่ายข้อง'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    ctx.go('/booking/1');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFF0F766E)),
                  title: const Text('ประวัติการจอง'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    ctx.go('/bookings');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('ออกจากระบบ',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    auth.logout();
                    if (ctx.mounted) ctx.go('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = state.uri.toString();
    // For Home and booking screens, render child directly for full screen luxury experience
    if (loc.startsWith('/booking') || loc == '/') {
      return child;
    }

    final idx = _currentIndex();
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: const Color(0xFF141A16),
              elevation: 2,
              selectedIndex: idx,
              onDestinationSelected: (i) => _onTap(context, i),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Color(0xFF34D399)),
              unselectedIconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),
              selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelTextStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              leading: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Tooltip(
                  message: 'กลับสู่หน้าหลัก (Home)',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go('/'),
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.restaurant_menu,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'กินดี',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: Text('จองโต๊ะ'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('การจอง'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  selectedIcon: Icon(Icons.person),
                  label: Text('บัญชี'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => _onTap(context, i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD1FAE5),
        elevation: 4,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'จองโต๊ะ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'การจอง',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'บัญชี',
          ),
        ],
      ),
    );
  }
}
