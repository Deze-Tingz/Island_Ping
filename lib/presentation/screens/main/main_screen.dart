import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/alert_provider.dart';
import '../home/home_screen.dart';
import '../alerts/alerts_screen.dart';
import '../map/outage_map_screen.dart';
import '../settings/settings_screen.dart';

// Current tab provider
final currentTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = const [
      HomeScreen(),
      AlertsScreen(),
      OutageMapScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: currentTab,
        unreadCount: unreadCount,
        isDark: isDark,
        onTap: (index) {
          HapticFeedback.selectionClick();
          ref.read(currentTabProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.unreadCount,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                isDark: isDark,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: 'Alerts',
                isActive: currentIndex == 1,
                badge: unreadCount > 0 ? unreadCount : null,
                isDark: isDark,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                label: 'Map',
                isActive: currentIndex == 2,
                isDark: isDark,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                isActive: currentIndex == 3,
                isDark: isDark,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int? badge;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.teal.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 24,
                    color: isActive
                        ? AppColors.teal
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: 8,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.offline,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        badge! > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.teal
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
