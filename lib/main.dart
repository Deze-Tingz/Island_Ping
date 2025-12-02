import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'data/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Firebase (without requesting permissions yet)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if onboarding is complete before requesting permissions
  final settingsBox = await Hive.openBox('settings');
  final hasCompletedOnboarding = settingsBox.get('onboarding_complete', defaultValue: false) as bool;

  if (hasCompletedOnboarding) {
    // Only request permissions after onboarding is complete
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    await firebaseService.subscribeToOutageAlerts();
  }

  runApp(
    const ProviderScope(
      child: IslandPingApp(),
    ),
  );
}
