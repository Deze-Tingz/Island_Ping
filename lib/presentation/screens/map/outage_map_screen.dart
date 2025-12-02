import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/outage.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/location_provider.dart';

// Mapbox access token for tile loading
const String _mapboxAccessToken = 'pk.eyJ1IjoiZGV6ZXRpbmd6IiwiYSI6ImNtaW42anV4azIwM3ozY3B3eGpxdWlxenYifQ.Y5YI-07V6nwBUCPxF7qH3w';

// Sample user data for demonstration - in production, this would come from Firebase
class MapUser {
  final String id;
  final String firstName;
  final String lastName;
  final double latitude;
  final double longitude;
  final bool hasInternet;
  final DateTime lastUpdate;

  MapUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.latitude,
    required this.longitude,
    required this.hasInternet,
    required this.lastUpdate,
  });

  String get initials => '${firstName[0]}.'.toUpperCase();
  String get displayName => '${firstName[0]}. $lastName';
}

class OutageMapScreen extends ConsumerStatefulWidget {
  const OutageMapScreen({super.key});

  @override
  ConsumerState<OutageMapScreen> createState() => _OutageMapScreenState();
}

class _OutageMapScreenState extends ConsumerState<OutageMapScreen> {
  final MapController _mapController = MapController();
  bool _hasMovedToUser = false;
  bool _showLegend = false;
  bool _showUserMarkers = true; // Toggle for user markers

  // Default fallback position (Jamaica)
  static const LatLng _defaultPosition = LatLng(18.1096, -77.2975);

  // Sample users - in production these would come from Firestore
  final List<MapUser> _nearbyUsers = [
    MapUser(
      id: '1',
      firstName: 'Marcus',
      lastName: 'Brown',
      latitude: 18.1120,
      longitude: -77.2990,
      hasInternet: true,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    MapUser(
      id: '2',
      firstName: 'Keisha',
      lastName: 'Williams',
      latitude: 18.1080,
      longitude: -77.2950,
      hasInternet: false,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    MapUser(
      id: '3',
      firstName: 'Andre',
      lastName: 'Thompson',
      latitude: 18.1050,
      longitude: -77.3010,
      hasInternet: true,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outages = ref.watch(outagesProvider);
    final locationAsync = ref.watch(currentLocationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCount = outages.where((o) => o.isActive).length;

    // Auto-focus on user location when available
    locationAsync.whenData((loc) {
      if (loc != null && !_hasMovedToUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _goToLocation(LatLng(loc.latitude, loc.longitude));
          _hasMovedToUser = true;
        });
      }
    });

    // Determine initial center
    final initialCenter = locationAsync.when(
      data: (loc) => loc != null ? LatLng(loc.latitude, loc.longitude) : _defaultPosition,
      loading: () => _defaultPosition,
      error: (_, __) => _defaultPosition,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            // Flutter Map with Mapbox tiles - smooth and premium
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 14,
                minZoom: 5,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                // Mapbox tiles - clean, smooth, minimal branding
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken'
                      : 'https://api.mapbox.com/styles/v1/mapbox/light-v11/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken',
                  userAgentPackageName: 'com.islandping.island_ping',
                  tileSize: 512,
                  zoomOffset: -1,
                ),

                // Outage circles layer
                CircleLayer(
                  circles: outages
                      .where((o) => o.isActive)
                      .map((outage) => CircleMarker(
                            point: LatLng(outage.latitude, outage.longitude),
                            radius: outage.radiusKm * 100, // Scale for visibility
                            color: _getSeverityColor(outage.severity).withOpacity(0.2),
                            borderColor: _getSeverityColor(outage.severity),
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                          ))
                      .toList(),
                ),

                // User markers layer - toggleable for performance
                if (_showUserMarkers)
                  MarkerLayer(
                    markers: _nearbyUsers.map((user) => _buildUserMarker(user, isDark)).toList(),
                  ),

                // Current user location marker
                MarkerLayer(
                  markers: [
                    if (locationAsync.valueOrNull != null)
                      Marker(
                        point: LatLng(
                          locationAsync.valueOrNull!.latitude,
                          locationAsync.valueOrNull!.longitude,
                        ),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Minimal top bar with title and status
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 20,
                  right: 20,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark ? AppColors.backgroundDark : Colors.white,
                      (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(0.95),
                      (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    // Title
                    Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Minimal status pill
                    _StatusPill(
                      isAllClear: activeCount == 0,
                      count: activeCount,
                    ),
                    const Spacer(),
                    // Toggle user markers button
                    _MinimalButton(
                      icon: _showUserMarkers ? Icons.people_rounded : Icons.people_outline_rounded,
                      isDark: isDark,
                      isActive: _showUserMarkers,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showUserMarkers = !_showUserMarkers);
                      },
                    ),
                    const SizedBox(width: 8),
                    // My location button
                    _MinimalButton(
                      icon: Icons.my_location_rounded,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _focusOnUser();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Expandable legend - bottom left
            Positioned(
              bottom: 160,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showLegend = !_showLegend);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.all(_showLegend ? 12 : 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(_showLegend ? 14 : 22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _showLegend
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  size: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'SEVERITY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _LegendDot(color: AppColors.warning, label: 'Minor', isDark: isDark),
                            const SizedBox(height: 6),
                            _LegendDot(color: Colors.orange, label: 'Moderate', isDark: isDark),
                            const SizedBox(height: 6),
                            _LegendDot(color: AppColors.offline, label: 'Major', isDark: isDark),
                            const SizedBox(height: 6),
                            _LegendDot(color: const Color(0xFF9B59B6), label: 'Critical', isDark: isDark),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'USERS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _LegendDot(color: AppColors.online, label: 'Online', isDark: isDark),
                            const SizedBox(height: 6),
                            _LegendDot(color: AppColors.offline, label: 'Offline', isDark: isDark),
                          ],
                        )
                      : Icon(
                          Icons.layers_rounded,
                          size: 20,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                ),
              ),
            ),

            // Minimal Report Button - bottom center
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showReportSheet(context, isDark);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.coral, AppColors.coral.withOpacity(0.9)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Report Issue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildUserMarker(MapUser user, bool isDark) {
    final statusColor = user.hasInternet ? AppColors.online : AppColors.offline;

    return Marker(
      point: LatLng(user.latitude, user.longitude),
      width: 90,
      height: 46,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _showUserDetails(user, isDark);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User bubble with first initial + last name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status indicator dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Name text
                  Flexible(
                    child: Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Pointer triangle
            CustomPaint(
              size: const Size(12, 6),
              painter: _TrianglePainter(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderColor: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(MapUser user, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // User avatar with initials
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (user.hasInternet ? AppColors.online : AppColors.offline).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: user.hasInternet ? AppColors.online : AppColors.offline,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: user.hasInternet ? AppColors.online : AppColors.offline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // User name
              Text(
                user.displayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              // Status row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: user.hasInternet ? AppColors.online : AppColors.offline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.hasInternet ? 'Online' : 'Experiencing Outage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: user.hasInternet ? AppColors.online : AppColors.offline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Last update
              Text(
                'Updated ${_formatTimeAgo(user.lastUpdate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _focusOnUser() {
    final location = ref.read(currentLocationProvider).valueOrNull;
    if (location != null) {
      _goToLocation(LatLng(location.latitude, location.longitude));
    }
  }

  void _goToLocation(LatLng position, {double zoom = 14}) {
    _mapController.move(position, zoom);
  }

  Color _getSeverityColor(OutageSeverity severity) {
    switch (severity) {
      case OutageSeverity.minor:
        return AppColors.warning;
      case OutageSeverity.moderate:
        return Colors.orange;
      case OutageSeverity.major:
        return AppColors.offline;
      case OutageSeverity.critical:
        return const Color(0xFF9B59B6);
    }
  }

  void _showReportSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportBottomSheet(isDark: isDark),
    );
  }
}

/// Minimal status pill showing outage count
class _StatusPill extends StatelessWidget {
  final bool isAllClear;
  final int count;

  const _StatusPill({required this.isAllClear, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isAllClear ? AppColors.online : AppColors.offline).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAllClear ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isAllClear ? 'Clear' : '$count Active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAllClear ? AppColors.online : AppColors.offline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal circular button
class _MinimalButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final bool isActive;

  const _MinimalButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.teal.withOpacity(0.15)
              : (isDark ? AppColors.cardDark : Colors.white),
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: AppColors.teal, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive
              ? AppColors.teal
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          size: 20,
        ),
      ),
    );
  }
}

/// Legend dot item
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Report bottom sheet
class _ReportBottomSheet extends StatefulWidget {
  final bool isDark;

  const _ReportBottomSheet({required this.isDark});

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  String? _selectedIssue;
  final _descriptionController = TextEditingController();

  final _issueTypes = [
    ('no_signal', 'No Signal', Icons.signal_cellular_off_rounded),
    ('slow_data', 'Slow Data', Icons.speed_rounded),
    ('calls_failing', 'Calls Failing', Icons.phone_disabled_rounded),
    ('intermittent', 'Intermittent', Icons.sync_problem_rounded),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(
                'Report an Issue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help your community by reporting outages',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Issue type selection
              Text(
                'ISSUE TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _issueTypes.map((issue) {
                  final isSelected = _selectedIssue == issue.$1;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIssue = issue.$1);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.teal.withOpacity(0.12)
                            : (widget.isDark ? AppColors.cardDark : AppColors.backgroundLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.teal : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            issue.$3,
                            size: 18,
                            color: isSelected
                                ? AppColors.teal
                                : (widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            issue.$2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.teal
                                  : (widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Description field
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Add details (optional)',
                    hintStyle: TextStyle(
                      color: widget.isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _selectedIssue != null
                      ? () {
                          Navigator.pop(context);
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  const Text('Report submitted successfully'),
                                ],
                              ),
                              backgroundColor: AppColors.online,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedIssue != null
                          ? AppColors.teal
                          : (widget.isDark ? AppColors.cardDark : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedIssue != null
                              ? Colors.white
                              : (widget.isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Triangle pointer painter for map markers
class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Fill
    canvas.drawPath(path, Paint()..color = color);

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderColor != borderColor;
  }
}
