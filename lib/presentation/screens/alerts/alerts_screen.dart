import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/alert.dart';
import '../../../providers/alert_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerts',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (unreadCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$unreadCount unread',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.coral,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(alertsProvider.notifier).markAllAsRead();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: alerts.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AlertCard(
                              alert: alert,
                              isDark: isDark,
                              onTap: () {
                                if (!alert.isRead) {
                                  ref.read(alertsProvider.notifier).markAsRead(alert.id);
                                }
                                _showAlertSheet(context, alert, isDark);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Alerts',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertSheet(BuildContext context, Alert alert, bool isDark) {
    final typeData = _getTypeData(alert.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Type indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeData.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeData.icon, size: 16, color: typeData.color),
                          const SizedBox(width: 6),
                          Text(
                            typeData.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: typeData.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(alert.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 28),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({Color color, IconData icon, String label}) _getTypeData(AlertType type) {
    switch (type) {
      case AlertType.outageDetected:
        return (color: AppColors.offline, icon: Icons.warning_rounded, label: 'Outage');
      case AlertType.outageResolved:
        return (color: AppColors.online, icon: Icons.check_circle_rounded, label: 'Resolved');
      case AlertType.systemUpdate:
        return (color: AppColors.info, icon: Icons.system_update_rounded, label: 'Update');
      case AlertType.info:
        return (color: AppColors.teal, icon: Icons.info_rounded, label: 'Info');
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Individual alert card
class _AlertCard extends StatelessWidget {
  final Alert alert;
  final bool isDark;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeData = _getTypeData(alert.type);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeData.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeData.icon, color: typeData.color, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: typeData.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(alert.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color color, IconData icon, String label}) _getTypeData(AlertType type) {
    switch (type) {
      case AlertType.outageDetected:
        return (color: AppColors.offline, icon: Icons.warning_rounded, label: 'Outage');
      case AlertType.outageResolved:
        return (color: AppColors.online, icon: Icons.check_circle_rounded, label: 'Resolved');
      case AlertType.systemUpdate:
        return (color: AppColors.info, icon: Icons.system_update_rounded, label: 'Update');
      case AlertType.info:
        return (color: AppColors.teal, icon: Icons.info_rounded, label: 'Info');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
