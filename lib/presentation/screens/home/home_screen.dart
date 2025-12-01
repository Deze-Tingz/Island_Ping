import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../data/services/connectivity_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final location = ref.watch(currentLocationProvider);
    final unreadCount = ref.watch(unreadAlertCountProvider);
    final activeOutages = ref.watch(activeOutagesCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Island Ping'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navigate to alerts screen
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.offline,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final service = ref.read(connectivityServiceProvider);
          await service.forceCheck();
          ref.invalidate(currentLocationProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              _buildStatusCard(context, connectionStatus),
              const SizedBox(height: 16),

              // Location Card
              _buildLocationCard(context, location),
              const SizedBox(height: 16),

              // Active Outages Card
              _buildOutagesCard(context, activeOutages),
              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    AsyncValue<ConnectionStatus> connectionStatus,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            connectionStatus.when(
              data: (status) => _buildStatusIndicator(status),
              loading: () => _buildStatusIndicator(ConnectionStatus.checking),
              error: (_, __) => _buildStatusIndicator(ConnectionStatus.offline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ConnectionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case ConnectionStatus.online:
        color = AppColors.online;
        text = 'Connected';
        icon = Icons.check_circle;
        break;
      case ConnectionStatus.offline:
        color = AppColors.offline;
        text = 'Disconnected';
        icon = Icons.error;
        break;
      case ConnectionStatus.checking:
        color = AppColors.warning;
        text = 'Checking...';
        icon = Icons.sync;
        break;
    }

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              status == ConnectionStatus.online
                  ? 'Your connection is stable'
                  : status == ConnectionStatus.checking
                      ? 'Verifying connection...'
                      : 'Connection issue detected',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    AsyncValue<dynamic> location,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Area',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            location.when(
              data: (loc) => Text(
                loc?.displayLocation ?? 'Location unavailable',
                style: const TextStyle(fontSize: 16),
              ),
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Getting location...'),
                ],
              ),
              error: (_, __) => const Text(
                'Unable to get location',
                style: TextStyle(color: AppColors.offline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutagesCard(BuildContext context, int activeOutages) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: activeOutages > 0
                          ? AppColors.warning
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Active Outages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: activeOutages > 0
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.online.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$activeOutages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: activeOutages > 0
                          ? AppColors.warning
                          : AppColors.online,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activeOutages > 0
                  ? 'There are active outages in your area'
                  : 'No outages reported in your area',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to map screen
                },
                child: const Text('View Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.refresh,
                label: 'Check Now',
                onTap: () {
                  // TODO: Force connectivity check
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.report_problem,
                label: 'Report Issue',
                onTap: () {
                  // TODO: Report outage
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
