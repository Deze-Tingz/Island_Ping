import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/island_ping_logo.dart';
import 'data/services/firebase_service.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

// Provider to track onboarding completion
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

class IslandPingApp extends ConsumerStatefulWidget {
  const IslandPingApp({super.key});

  @override
  ConsumerState<IslandPingApp> createState() => _IslandPingAppState();
}

class _IslandPingAppState extends ConsumerState<IslandPingApp> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Longer delay for splash screen to be visible
    await Future.delayed(const Duration(milliseconds: 2500));

    final box = await Hive.openBox('settings');
    final hasCompletedOnboarding = box.get('onboarding_complete', defaultValue: false) as bool;

    if (mounted) {
      setState(() {
        _showOnboarding = !hasCompletedOnboarding;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final box = await Hive.openBox('settings');
    await box.put('onboarding_complete', true);

    // Initialize Firebase services now that onboarding is complete
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    await firebaseService.subscribeToOutageAlerts();

    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Island Ping',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoading
          ? const _SplashScreen()
          : _showOnboarding
              ? OnboardingScreen(onComplete: _completeOnboarding)
              : const MainScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  // Brand colors matching the new logo
  static const Color tealBackground = Color(0xFF1A6B7C);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Set status bar to light for teal background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A6B7C),
                  Color(0xFF155A69),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Animated Logo
                  Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: const IslandPingLogo(
                        size: 140,
                        animated: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App name
                  Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: const Text(
                        'IslandPing',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tagline
                  Transform.translate(
                    offset: Offset(0, _slideUp.value * 1.2),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: Text(
                        'Stay connected.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Loading indicator
                  Opacity(
                    opacity: _fadeIn.value,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
