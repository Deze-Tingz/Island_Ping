import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

// Settings state provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final locationEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeProvider = StateProvider<bool>((ref) => false);
final autoCheckIntervalProvider = StateProvider<int>((ref) => 30);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context,
                ref,
                title: 'Push Notifications',
                subtitle: 'Receive alerts about outages in your area',
                icon: Icons.notifications,
                provider: notificationsEnabledProvider,
              ),
            ],
          ),
          _buildSection(
            title: 'Location',
            children: [
              _buildSwitchTile(
                context,
                ref,
                title: 'Location Services',
                subtitle: 'Allow approximate location for area-based alerts',
                icon: Icons.location_on,
                provider: locationEnabledProvider,
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Note'),
                subtitle: Text(
                  'We only use approximate location (neighborhood level) and never store exact addresses.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Connectivity Check',
            children: [
              _buildIntervalSelector(context, ref),
            ],
          ),
          _buildSection(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                context,
                ref,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                icon: Icons.dark_mode,
                provider: darkModeProvider,
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: const Text(AppConstants.appVersion),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _showSignOutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.offline,
              ),
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Island Ping v${AppConstants.appVersion}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required StateProvider<bool> provider,
  }) {
    final value = ref.watch(provider);

    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        ref.read(provider.notifier).state = newValue;
      },
    );
  }

  Widget _buildIntervalSelector(BuildContext context, WidgetRef ref) {
    final interval = ref.watch(autoCheckIntervalProvider);

    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Check Interval'),
      subtitle: Text('Check connectivity every $interval seconds'),
      trailing: DropdownButton<int>(
        value: interval,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 15, child: Text('15s')),
          DropdownMenuItem(value: 30, child: Text('30s')),
          DropdownMenuItem(value: 60, child: Text('1m')),
          DropdownMenuItem(value: 120, child: Text('2m')),
          DropdownMenuItem(value: 300, child: Text('5m')),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(autoCheckIntervalProvider.notifier).state = value;
          }
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out with FirebaseAuth
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.offline),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
