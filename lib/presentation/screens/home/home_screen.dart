import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/island_ping_logo.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../../../data/services/connectivity_service.dart';
import '../main/main_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final location = ref.watch(currentLocationProvider);
    final activeOutages = ref.watch(activeOutagesCountProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // Minimal header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo mark only - using vector logo
                    const IslandPingLogo(size: 36),
                    // Notification bell
                    GestureDetector(
                      onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 22,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            if (activeOutages > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.offline,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hero status - the MAIN event
              Expanded(
                flex: 3,
                child: Center(
                  child: connectionStatus.when(
                    data: (status) => _HeroStatus(status: status, isDark: isDark, ref: ref),
                    loading: () => _HeroStatus(status: ConnectionStatus.checking, isDark: isDark, ref: ref),
                    error: (_, __) => _HeroStatus(status: ConnectionStatus.offline, isDark: isDark, ref: ref),
                  ),
                ),
              ),

              // Premium info cards section
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Network & ISP Card - Premium glassmorphic style
                      deviceInfo.when(
                        data: (info) => _PremiumNetworkCard(info: info, isDark: isDark),
                        loading: () => _PremiumNetworkCard(
                          info: null,
                          isDark: isDark,
                          isLoading: true,
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),

                      // Device & Health Card
                      deviceInfo.when(
                        data: (info) => _PremiumDeviceCard(info: info, isDark: isDark),
                        loading: () => _PremiumDeviceCard(
                          info: null,
                          isDark: isDark,
                          isLoading: true,
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),

                      // Location card
                      _InfoTile(
                        icon: Icons.location_on_rounded,
                        label: 'Your Location',
                        value: location.when(
                          data: (loc) => loc?.area ?? 'Unknown',
                          loading: () => 'Locating...',
                          error: (_, __) => 'Unavailable',
                        ),
                        isDark: isDark,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),

                      // Outages card
                      _InfoTile(
                        icon: Icons.warning_amber_rounded,
                        label: 'Active Outages',
                        value: activeOutages == 0 ? 'None' : '$activeOutages in your area',
                        valueColor: activeOutages > 0 ? AppColors.offline : AppColors.online,
                        isDark: isDark,
                        onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
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

/// Premium Network Card - Shows ISP and connection type
class _PremiumNetworkCard extends StatelessWidget {
  final DeviceInfoModel? info;
  final bool isDark;
  final bool isLoading;

  const _PremiumNetworkCard({
    required this.info,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final networkName = info?.networkDisplayName ?? 'Detecting...';
    final networkType = info?.networkType ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.teal.withOpacity(0.15),
                  AppColors.cyan.withOpacity(0.08),
                ]
              : [
                  AppColors.teal.withOpacity(0.08),
                  AppColors.cyan.withOpacity(0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.teal.withOpacity(isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Network icon with glow
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.teal,
                  AppColors.cyan,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getNetworkIcon(networkType),
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Network info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NETWORK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        networkType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                isLoading
                    ? _buildShimmer(isDark)
                    : Text(
                        networkName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),

          // Signal strength indicator
          Column(
            children: [
              _SignalBars(strength: info != null ? 3 : 0, isDark: isDark),
              const SizedBox(height: 4),
              Text(
                'Strong',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.online,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNetworkIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Icons.wifi_rounded;
      case 'mobile data':
        return Icons.cell_tower_rounded;
      case 'ethernet':
        return Icons.settings_ethernet_rounded;
      default:
        return Icons.signal_cellular_alt_rounded;
    }
  }

  Widget _buildShimmer(bool isDark) {
    return Container(
      height: 24,
      width: 150,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Signal strength bars
class _SignalBars extends StatelessWidget {
  final int strength;
  final bool isDark;

  const _SignalBars({required this.strength, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < strength;
        final height = 6.0 + (index * 4);
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? AppColors.online : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Premium Device Card - Shows device name and battery health
class _PremiumDeviceCard extends StatelessWidget {
  final DeviceInfoModel? info;
  final bool isDark;
  final bool isLoading;

  const _PremiumDeviceCard({
    required this.info,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceName = info?.displayName ?? 'Your Device';
    final batteryLevel = info?.batteryLevel ?? 0;
    final batteryHealth = info?.batteryHealth ?? 'Unknown';
    final isCharging = info?.batteryState == BatteryState.charging;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.coral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.smartphone_rounded,
              color: AppColors.coral,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEVICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? _buildShimmer(isDark)
                    : Text(
                        deviceName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),

          // Battery indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCharging)
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: AppColors.online,
                    ),
                  Icon(
                    _getBatteryIcon(batteryLevel, isCharging),
                    size: 28,
                    color: _getBatteryColor(batteryLevel),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$batteryLevel%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _getBatteryColor(batteryLevel),
                ),
              ),
              Text(
                batteryHealth,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getBatteryIcon(int level, bool charging) {
    if (charging) return Icons.battery_charging_full_rounded;
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 60) return Icons.battery_5_bar_rounded;
    if (level >= 40) return Icons.battery_4_bar_rounded;
    if (level >= 20) return Icons.battery_2_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  Color _getBatteryColor(int level) {
    if (level >= 50) return AppColors.online;
    if (level >= 20) return AppColors.warning;
    return AppColors.offline;
  }

  Widget _buildShimmer(bool isDark) {
    return Container(
      height: 20,
      width: 120,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// The hero status display - dominates the screen
class _HeroStatus extends StatefulWidget {
  final ConnectionStatus status;
  final bool isDark;
  final WidgetRef ref;

  const _HeroStatus({
    required this.status,
    required this.isDark,
    required this.ref,
  });

  @override
  State<_HeroStatus> createState() => _HeroStatusState();
}

class _HeroStatusState extends State<_HeroStatus>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == ConnectionStatus.online) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    } else if (widget.status == ConnectionStatus.checking) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(_HeroStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == ConnectionStatus.online) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else if (widget.status == ConnectionStatus.checking) {
        _pulseController.stop();
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusText;
    final String statusSubtext;
    final IconData statusIcon;

    switch (widget.status) {
      case ConnectionStatus.online:
        statusColor = AppColors.online;
        statusText = 'Connected';
        statusSubtext = 'Your network is stable';
        statusIcon = Icons.wifi_rounded;
        break;
      case ConnectionStatus.offline:
        statusColor = AppColors.offline;
        statusText = 'Offline';
        statusSubtext = 'No connection detected';
        statusIcon = Icons.wifi_off_rounded;
        break;
      case ConnectionStatus.checking:
        statusColor = AppColors.warning;
        statusText = 'Checking';
        statusSubtext = 'Verifying connection...';
        statusIcon = Icons.sync_rounded;
        break;
    }

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final service = widget.ref.read(connectivityServiceProvider);
        await service.forceCheck();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated status orb
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.status == ConnectionStatus.online
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withOpacity(0.15),
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor,
                                statusColor.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            statusIcon,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Status text
          Text(
            statusText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statusSubtext,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Tap to refresh hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (widget.isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: widget.isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap to refresh',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
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

/// Clean info tile
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.teal, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

