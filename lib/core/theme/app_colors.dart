import 'package:flutter/material.dart';

/// Island Ping Design System Colors
/// Inspired by the brand: teal ocean, island, signal waves, coral ping
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS - Extracted from logo
  // ═══════════════════════════════════════════════════════════════════════════

  /// Deep teal - Primary brand color (ocean depth)
  static const Color teal = Color(0xFF1A5C6B);

  /// Light teal/cyan - Signal waves, accents
  static const Color cyan = Color(0xFF4ECDC4);

  /// Coral/Salmon - The "ping" dot, call-to-actions
  static const Color coral = Color(0xFFE8927C);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary actions, selected states
  static const Color primary = teal;

  /// Secondary accents, highlights
  static const Color accent = coral;

  /// Online/Connected/Success
  static const Color online = Color(0xFF34C759);

  /// Offline/Disconnected/Error
  static const Color offline = Color(0xFFFF3B30);

  /// Warning/Checking states
  static const Color warning = Color(0xFFFF9500);

  /// Info/Neutral
  static const Color info = Color(0xFF007AFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main background - warm white
  static const Color backgroundLight = Color(0xFFF9FAFB);

  /// Elevated surfaces - pure white
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Cards and containers
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Primary text - near black
  static const Color textPrimaryLight = Color(0xFF1C1C1E);

  /// Secondary text - medium gray
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// Tertiary text - light gray
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  /// Dividers and borders
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main background - true dark
  static const Color backgroundDark = Color(0xFF000000);

  /// Elevated surfaces - lifted dark
  static const Color surfaceDark = Color(0xFF1C1C1E);

  /// Cards and containers
  static const Color cardDark = Color(0xFF2C2C2E);

  /// Primary text - pure white
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary text - medium gray
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  /// Tertiary text - dark gray
  static const Color textTertiaryDark = Color(0xFF636366);

  /// Dividers and borders
  static const Color dividerDark = Color(0xFF38383A);

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY SUPPORT (for existing code)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color secondary = cyan;
  static const Color primaryDark = Color(0xFF145A68);
  static const Color primaryLight = Color(0xFF2A8A9C);
  static const Color accentLight = Color(0xFFF5B8A8);
  static const Color secondaryDark = Color(0xFF3DBDB4);
  static const Color critical = Color(0xFF9B59B6);
  static const Color separatorLight = dividerLight;
  static const Color separatorDark = dividerDark;
  static const Color textTertiaryLight_old = textTertiaryLight;
  static const Color textTertiaryDark_old = textTertiaryDark;

  // Gradients
  static const List<Color> primaryGradient = [teal, Color(0xFF2A8A9C)];
  static const List<Color> accentGradient = [coral, Color(0xFFF5B8A8)];
  static const List<Color> successGradient = [Color(0xFF34C759), Color(0xFF30D158)];
  static const List<Color> dangerGradient = [Color(0xFFFF3B30), Color(0xFFFF6961)];
  static const List<Color> warningGradient = [Color(0xFFFF9500), Color(0xFFFFB340)];
  static const List<Color> darkGradient = [surfaceDark, cardDark];

  // Map
  static const Color outageAreaFill = Color(0x40FF3B30);
  static const Color outageAreaBorder = Color(0xFFFF3B30);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
}
