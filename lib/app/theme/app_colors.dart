import 'package:flutter/material.dart';

/// Theme-aware colors accessed via AppColors.of(context)
class AdaptiveColors {
  final BuildContext context;
  AdaptiveColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // ─── BACKGROUNDS ───────────────────────────────────────────────
  Color get background => isDark ? const Color(0xFF0F1123) : const Color(0xFFF7F8FC);
  Color get backgroundPure => isDark ? const Color(0xFF0A0D1A) : Colors.white;
  Color get surface => isDark ? const Color(0xFF171B30) : Colors.white;
  Color get surfaceVariant => isDark ? const Color(0xFF1E2545) : const Color(0xFFF0F2F8);
  Color get cardBg => isDark ? const Color(0xFF1A1F36) : Colors.white;

  // ─── TEXT ──────────────────────────────────────────────────────
  Color get textPrimary => isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1A1A2E);
  Color get textSecondary => isDark ? const Color(0xFFB0B8D1) : const Color(0xFF6B7280);
  Color get textTertiary => isDark ? const Color(0xFF6B7394) : const Color(0xFF9CA3AF);

  // ─── BORDERS & DIVIDERS ────────────────────────────────────────
  Color get border => isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE5E7EB);
  Color get divider => isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF3F4F6);

  // ─── CARD SHADOWS (light mode only) ────────────────────────────
  List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(color: const Color(0xFF1A1A2E).withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: const Color(0xFF1A1A2E).withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ];

  // ─── NAV BAR ───────────────────────────────────────────────────
  Color get navBarBg => isDark ? const Color(0xFF1A1A2E) : Colors.white;
  Color get navBarInactiveIcon => isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFFB0B8C9);

  // ─── INPUT FIELDS ──────────────────────────────────────────────
  Color get inputFill => isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF5F7FA);
  Color get inputBorder => isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE5E7EB);
}

/// Color system with static defaults (backward compatible) + adaptive theme-aware access.
///
/// Static access: `AppColors.textPrimary` → uses default colors (works everywhere)
/// Theme-aware:   `AppColors.of(context).textPrimary` → adapts to light/dark
class AppColors {
  /// Get theme-aware adaptive colors
  static AdaptiveColors of(BuildContext context) => AdaptiveColors(context);

  // ─── STATIC BACKGROUNDS (backward compat — dark theme defaults) ─
  static const Color background = Color(0xFF0A0E21);
  static const Color backgroundLight = Color(0xFF1A1F36);
  static const Color surface = Color(0xFF151A30);
  static const Color surfaceLight = Color(0xFF1E2545);

  // ─── STATIC TEXT (backward compat) ─────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textTertiary = Color(0xFF6B7394);

  // ─── ACCENT COLORS (same in both modes) ────────────────────────
  static const Color accent = Color(0xFF4A90FF);
  static const Color accentSecondary = Color(0xFF7B61FF);
  static const Color accentTertiary = Color(0xFF00C9A7);
  static const Color accentWarm = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFF8E53);

  // ─── STATUS COLORS ─────────────────────────────────────────────
  static const Color success = Color(0xFF00C9A7);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF4A90FF);

  // ─── GRADIENTS ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF4A90FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F1123), Color(0xFF1A1F36)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.15),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── GLASS COLORS (backward compat) ───────────────────────────
  static Color glassWhite = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.05);
}
