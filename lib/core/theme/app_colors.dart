import 'package:flutter/material.dart';

/// Tungabadra Networks LMS — Design System Color Palette
///
/// Refactored to support semantic light and dark themes.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // BASE PALETTE (Raw hex codes, do not use directly in UI)
  // ──────────────────────────────────────────────
  static const Color _rustOrangeDark = Color(0xFFC2410C);
  static const Color _rustOrange = Color(0xFFF97316);
  static const Color _rustOrangeLight = Color(0xFFFDBA74);

  static const Color _neutral900 = Color(0xFF0B0B0F);
  static const Color _neutral800 = Color(0xFF111118);
  static const Color _neutral700 = Color(0xFF1F2937);
  static const Color _neutral500 = Color(0xFF6B7280);
  static const Color _neutral400 = Color(0xFF9CA3AF);
  static const Color _neutral300 = Color(0xFFD1D5DB);
  static const Color _neutral200 = Color(0xFFE5E7EB);
  static const Color _neutral50 = Color(0xFFF9FAFB);
  static const Color _white = Color(0xFFFFFFFF);

  // ──────────────────────────────────────────────
  // SEMANTIC COLORS (Light Theme)
  // ──────────────────────────────────────────────
  static const ColorScheme lightScheme = ColorScheme.light(
    primary: _rustOrange,
    onPrimary: _white,
    primaryContainer: _rustOrangeLight,
    onPrimaryContainer: _rustOrangeDark,
    secondary: Color(0xFF6E41C7),
    onSecondary: _white,
    secondaryContainer: Color(0xFFE9D5FF),
    onSecondaryContainer: Color(0xFF3B0764),
    surface: _neutral50,
    onSurface: _neutral900,
    surfaceContainer: _white,
    onSurfaceVariant: _neutral500,
    error: Color(0xFFEF4444),
    onError: _white,
    outline: _neutral300,
    outlineVariant: _neutral200,
  );

  // ──────────────────────────────────────────────
  // SEMANTIC COLORS (Dark Theme)
  // ──────────────────────────────────────────────
  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: _rustOrange,
    onPrimary: _white,
    primaryContainer: _rustOrangeDark,
    onPrimaryContainer: _white,
    secondary: Color(0xFF6E41C7),
    onSecondary: _white,
    secondaryContainer: Color(0xFFA277FE),
    onSecondaryContainer: _white,
    surface: _neutral900, // background
    onSurface: _white,
    surfaceContainer: _neutral800, // surface
    onSurfaceVariant: _neutral400,
    error: Color(0xFFEF4444),
    onError: _white,
    outline: _neutral500,
    outlineVariant: _neutral700,
  );

  // ──────────────────────────────────────────────
  // LEGACY STATIC TOKENS (Preserved to avoid breaking current UI)
  // Mapping them directly to dark theme variables for now.
  // ──────────────────────────────────────────────
  static const Color primaryDark = _rustOrangeDark;
  static const Color primary = _rustOrange;
  static const Color primaryLight = _rustOrangeLight;
  static const Color background = _neutral900;
  static const Color surface = _neutral800;
  static const Color surfaceDim = _neutral800;
  static const Color surfaceContainer = Color(0xFF1A1A24);
  static const Color surfaceVariant = _neutral700;
  static const Color cardSurface = _neutral700;
  static const Color border = _neutral700;
  static const Color textPrimary = _white;
  static const Color textSecondary = _neutral400;
  static const Color textMuted = _neutral500;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color primaryContainer = Color(0xFF0F1B4C);
  static const Color secondary = Color(0xFF6E41C7);
  static const Color secondaryContainer = Color(0xFFA277FE);
  static const Color outline = _neutral500;
  static const Color outlineVariant = _neutral700;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color primaryGlow = primary.withValues(alpha: 0.3);
}
