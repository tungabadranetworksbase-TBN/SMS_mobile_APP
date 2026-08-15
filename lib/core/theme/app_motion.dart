import 'package:flutter/animation.dart';

/// Tungabadra Networks LMS — Motion & Animation Tokens
///
/// Centralized duration and curve tokens for consistent micro-interactions.
class AppMotion {
  AppMotion._();

  // ── DURATIONS ──
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // ── CURVES ──
  /// Use for most standard enter/exit transitions
  static const Curve standard = Curves.easeInOutCubic;

  /// Use for elements entering the screen (deceleration)
  static const Curve enter = Curves.easeOutQuart;

  /// Use for elements exiting the screen (acceleration)
  static const Curve exit = Curves.easeInQuart;
}
