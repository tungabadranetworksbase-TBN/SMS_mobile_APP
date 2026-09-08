import 'package:flutter/material.dart';

/// Tungabadra Networks LMS — Typography System
///
/// Uses the platform default typeface so first paint never waits on a font CDN
/// (demo / offline phones were hanging splash while google_fonts fetched).
class AppTypography {
  AppTypography._();

  static TextStyle get _display => const TextStyle(fontWeight: FontWeight.w700);
  static TextStyle get _body => const TextStyle(fontWeight: FontWeight.w400);

  // ── DISPLAY ──
  static TextStyle get displayLarge => _display.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.12,
  );

  static TextStyle get displayMedium => _display.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.16,
  );

  static TextStyle get displaySmall => _display.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // ── HEADLINE ──
  static TextStyle get headlineLarge => _display.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.25,
  );

  static TextStyle get headlineMedium => _display.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static TextStyle get headlineSmall => _display.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ── TITLE ──
  static TextStyle get titleLarge => _display.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static TextStyle get titleMedium => _body.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => _body.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ── BODY ──
  static TextStyle get bodyLarge => _body.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _body.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => _body.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ── LABEL ──
  static TextStyle get labelLarge => _body.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _body.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _body.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ── FULL TEXT THEME ──
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
