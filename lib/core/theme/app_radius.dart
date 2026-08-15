import 'package:flutter/material.dart';

/// Tungabadra Networks LMS — Border Radius Tokens
///
/// Explicit border radii to ensure consistent curve treatments.
class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double pill = 9999.0;

  static final BorderRadius roundedSm = BorderRadius.circular(sm);
  static final BorderRadius roundedMd = BorderRadius.circular(md);
  static final BorderRadius roundedLg = BorderRadius.circular(lg);
  static final BorderRadius roundedXl = BorderRadius.circular(xl);
  static final BorderRadius roundedPill = BorderRadius.circular(pill);

  // Specific treatments
  static const BorderRadius topSheet = BorderRadius.vertical(top: Radius.circular(xxl));
}
