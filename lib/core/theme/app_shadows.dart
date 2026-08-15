import 'package:flutter/material.dart';

/// Tungabadra Networks LMS — Box Shadows
///
/// Predefined box shadows for specific depth layers.
class AppShadows {
  AppShadows._();

  // ── LIGHT MODE SHADOWS ──
  static final List<BoxShadow> lightSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> lightMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> lightLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // ── DARK MODE SHADOWS (Usually subtle or non-existent in true dark mode) ──
  static final List<BoxShadow> darkSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> darkMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
