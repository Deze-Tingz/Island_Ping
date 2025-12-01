class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Island Ping';
  static const String appVersion = '1.0.0';

  // Connectivity Check Settings
  static const Duration pingInterval = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const List<String> pingUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://www.amazon.com',
  ];

  // Location Settings
  static const int locationAccuracyMeters = 1000; // 1km accuracy for privacy
  static const Duration locationUpdateInterval = Duration(minutes: 5);

  // Notification Channels
  static const String outageChannelId = 'outage_alerts';
  static const String outageChannelName = 'Outage Alerts';
  static const String outageChannelDescription = 'Notifications for service outages in your area';

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String alertsBox = 'alerts';
  static const String userBox = 'user';
}
