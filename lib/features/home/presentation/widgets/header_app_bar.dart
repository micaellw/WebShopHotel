import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenMyBookings;
  final VoidCallback onOpenFlutterCode;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;
  final int bookingCount;
  final String? userName;

  const HeaderAppBar({
    super.key,
    required this.onOpenMyBookings,
    required this.onOpenFlutterCode,
    this.onLogout,
    this.onLogin,
    this.bookingCount = 0,
    this.userName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showHotline = screenWidth >= 1080;
    final showSubtitle = screenWidth >= 880;
    final showTagline = screenWidth >= 700;
    final isCompact = screenWidth < 768;

    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: Color(0xFF141A16),
        border: Border(
          bottom: BorderSide(color: Color(0xFF263228), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo & Title (Click to return to Home Page)
          Expanded(
            child: Tooltip(
              message: 'กลับสู่หน้าหลัก (Home)',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/'),
                  mouseCursor: SystemMouseCursors.click,
                  hoverColor: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF064E3B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFFD1FAE5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Flexible(
                                  child: Text(
                                    'กินดีถ่ายข้อง',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (showTagline) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF064E3B)
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF059669)
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.spa,
                                            color: Color(0xFF34D399), size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Wellness Dining & Hotel',
                                          style: TextStyle(
                                            color: Color(0xFF6EE7B7),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (showSubtitle) ...[
                              const SizedBox(height: 2),
                              const Text(
                                'ห้องอาหารเพื่อสุขภาพ & โต๊ะริมน้ำ บรรยากาศโรงแรมรีสอร์ต',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
          const SizedBox(width: 8),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHotline) ...[
                // Hotline
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2923),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2D3B31)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.phone_in_talk,
                          color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 6),
                      Text(
                        '02-899-7788',
                        style: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Flutter Architecture Code Button
              OutlinedButton.icon(
                onPressed: onOpenFlutterCode,
                icon: const Icon(Icons.code,
                    size: 16, color: Color(0xFF22D3EE)),
                label: Text(
                  isCompact ? 'Code' : 'Flutter Web Code',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2923),
                  side: const BorderSide(color: Color(0xFF374151)),
                  padding:
                      EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // My Bookings Button with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ElevatedButton.icon(
                    onPressed: onOpenMyBookings,
                    icon: const Icon(Icons.calendar_today,
                        size: 15, color: Colors.white),
                    label: Text(
                      isCompact ? 'การจอง' : 'การจองของฉัน',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (bookingCount > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$bookingCount',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              if (userName != null) ...[
                if (!isCompact) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2923),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2D3B31)),
                    ),
                    child: Text(
                      userName!,
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (onLogout != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout,
                        color: Color(0xFF9CA3AF), size: 18),
                    tooltip: 'ออกจากระบบ',
                  ),
                ],
              ] else if (onLogin != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onLogin,
                  icon: const Icon(Icons.login,
                      size: 14, color: Color(0xFF34D399)),
                  label: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF10B981)),
                    backgroundColor: const Color(0xFF1F2923),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
