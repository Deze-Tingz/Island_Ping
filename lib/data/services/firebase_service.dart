import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final _notificationController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get notificationStream => _notificationController.stream;

  Future<void> initialize() async {
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _updateTokenOnServer(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    _notificationController.add(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.data}');
    _notificationController.add(message);
  }

  Future<void> _updateTokenOnServer(String token) async {
    // Store token in Firestore for sending targeted notifications
    // This would typically include user ID and area information
    try {
      await _firestore.collection('device_tokens').doc(token).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('Error updating token: $e');
    }
  }

  Future<void> subscribeToArea(String areaId) async {
    try {
      await _messaging.subscribeToTopic('area_$areaId');
      debugPrint('Subscribed to area: $areaId');
    } catch (e) {
      debugPrint('Error subscribing to area: $e');
    }
  }

  Future<void> unsubscribeFromArea(String areaId) async {
    try {
      await _messaging.unsubscribeFromTopic('area_$areaId');
      debugPrint('Unsubscribed from area: $areaId');
    } catch (e) {
      debugPrint('Error unsubscribing from area: $e');
    }
  }

  // Subscribe to outage alerts topic
  Future<void> subscribeToOutageAlerts() async {
    try {
      await _messaging.subscribeToTopic('outage_alerts');
      debugPrint('Subscribed to outage alerts');
    } catch (e) {
      debugPrint('Error subscribing to outage alerts: $e');
    }
  }

  // Report an outage to Firestore
  Future<void> reportOutage({
    required double latitude,
    required double longitude,
    required String area,
    String? description,
  }) async {
    try {
      await _firestore.collection('outage_reports').add({
        'latitude': latitude,
        'longitude': longitude,
        'area': area,
        'description': description,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      debugPrint('Outage reported successfully');
    } catch (e) {
      debugPrint('Error reporting outage: $e');
    }
  }

  // Get active outages from Firestore
  Stream<QuerySnapshot> getActiveOutages() {
    return _firestore
        .collection('outages')
        .where('status', isEqualTo: 'active')
        .orderBy('reportedAt', descending: true)
        .snapshots();
  }

  void dispose() {
    _notificationController.close();
  }
}
