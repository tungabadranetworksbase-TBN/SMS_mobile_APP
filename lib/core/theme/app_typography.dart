import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tungabadra Networks LMS — Typography System
///
/// Font pairing:
/// - Headlines / Display: **Manrope** (geometric, modern authority)
/// - Body / Labels: **Inter** (high-legibility utility)
class AppTypography {
  AppTypography._();

  static TextStyle get _manrope => GoogleFonts.manrope();
  static TextStyle get _inter => GoogleFonts.inter();

  // ── DISPLAY ──
  static TextStyle get displayLarge => _manrope.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.12,
      );

  static TextStyle get displayMedium => _manrope.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.16,
      );

  static TextStyle get displaySmall => _manrope.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.22,
      );

  // ── HEADLINE ──
  static TextStyle get headlineLarge => _manrope.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle get headlineMedium => _manrope.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
      );

  static TextStyle get headlineSmall => _manrope.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  // ── TITLE ──
  static TextStyle get titleLarge => _manrope.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
      );

  static TextStyle get titleMedium => _inter.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get titleSmall => _inter.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      );

  // ── BODY ──
  static TextStyle get bodyLarge => _inter.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _inter.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      );

  static TextStyle get bodySmall => _inter.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );

  // ── LABEL ──
  static TextStyle get labelLarge => _inter.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get labelMedium => _inter.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );

  static TextStyle get labelSmall => _inter.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
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
