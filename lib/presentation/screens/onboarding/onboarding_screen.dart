import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Stay Connected',
      description:
          'Monitor your network connectivity in real-time. Know instantly when you\'re online or experiencing issues.',
      icon: Icons.wifi_rounded,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Outage Alerts',
      description:
          'Get notified when service outages occur in your area. Never be left in the dark about connectivity issues.',
      icon: Icons.notifications_active_rounded,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'View the Map',
      description:
          'See affected areas on an interactive map. Find out which zones are experiencing outages near you.',
      icon: Icons.map_rounded,
      color: AppColors.accent,
    ),
    OnboardingPage(
      title: 'Report Issues',
      description:
          'Help your community by reporting outages. Your reports help others stay informed about service disruptions.',
      icon: Icons.report_problem_rounded,
      color: AppColors.warning,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], isDark);
                },
              ),
            ),

            // Page indicators and button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index, isDark),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildPage(OnboardingPage page, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive sizing based on available height
        final isCompact = constraints.maxHeight < 400;
        final iconSize = isCompact ? 70.0 : 100.0;
        final iconInnerSize = isCompact ? 34.0 : 48.0;
        final titleSize = isCompact ? 22.0 : 26.0;
        final descSize = isCompact ? 14.0 : 15.0;
        final spacing = isCompact ? 16.0 : 32.0;

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: isCompact ? 24 : 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container with gradient background
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          page.color,
                          page.color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(iconSize * 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: page.color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: iconInnerSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Title
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    page.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: descSize,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator(int index, bool isDark) {
    final isActive = index == _currentPage;
    final color = isActive ? _pages[_currentPage].color : (isDark ? AppColors.separatorDark : AppColors.separatorLight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
