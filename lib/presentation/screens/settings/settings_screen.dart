import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

// Settings state providers
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final locationEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeProvider = StateProvider<bool>((ref) => false);
final autoCheckIntervalProvider = StateProvider<int>((ref) => 30);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              // Header
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Notifications group
              _SectionHeader(title: 'Notifications', isDark: isDark),
              _SettingsGroup(
                isDark: isDark,
                children: [
                  _SwitchTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.coral,
                    title: 'Push Notifications',
                    subtitle: 'Outage alerts for your area',
                    value: ref.watch(notificationsEnabledProvider),
                    onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Location group
              _SectionHeader(title: 'Location', isDark: isDark),
              _SettingsGroup(
                isDark: isDark,
                children: [
                  _SwitchTile(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.cyan,
                    title: 'Location Services',
                    subtitle: 'Enable for accurate alerts',
                    value: ref.watch(locationEnabledProvider),
                    onChanged: (v) => ref.read(locationEnabledProvider.notifier).state = v,
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _InfoTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.online,
                    title: 'Your Privacy',
                    subtitle: 'Only approximate location is used',
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Connection group
              _SectionHeader(title: 'Connection', isDark: isDark),
              _SettingsGroup(
                isDark: isDark,
                children: [
                  _IntervalTile(
                    value: ref.watch(autoCheckIntervalProvider),
                    onChanged: (v) => ref.read(autoCheckIntervalProvider.notifier).state = v,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Appearance group
              _SectionHeader(title: 'Appearance', isDark: isDark),
              _SettingsGroup(
                isDark: isDark,
                children: [
                  _SwitchTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF9B59B6),
                    title: 'Dark Mode',
                    subtitle: 'Switch theme appearance',
                    value: ref.watch(darkModeProvider),
                    onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // About group
              _SectionHeader(title: 'About', isDark: isDark),
              _SettingsGroup(
                isDark: isDark,
                children: [
                  _NavigationTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.info,
                    title: 'Version',
                    trailing: Text(
                      AppConstants.appVersion,
                      style: TextStyle(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _NavigationTile(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.teal,
                    title: 'Terms of Service',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _NavigationTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.cyan,
                    title: 'Privacy Policy',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  _NavigationTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.coral,
                    title: 'Help & Support',
                    onTap: () => _showComingSoon(context),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign out button
              GestureDetector(
                onTap: () => _showSignOut(context, isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.offline,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'Island Ping v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showSignOut(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'You will need to sign in again to access your account.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signed out'),
                  backgroundColor: AppColors.online,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                ),
              );
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.offline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SettingsGroup({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _NavigationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _IntervalTile extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _IntervalTile({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Interval',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Every $value seconds',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              isDense: true,
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15s')),
                DropdownMenuItem(value: 30, child: Text('30s')),
                DropdownMenuItem(value: 60, child: Text('1m')),
                DropdownMenuItem(value: 120, child: Text('2m')),
              ],
              onChanged: (v) {
                if (v != null) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
