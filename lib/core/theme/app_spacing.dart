/// Tungabadra Networks LMS — Spacing Scale
///
/// Consistent 4px and 8px base grid system tokens used throughout the app.
class AppSpacing {
  AppSpacing._();

  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;

  // Legacy mappings to maintain backward compatibility during refactor
  static const double xxs = s2;
  static const double xs = s4;
  static const double sm = s8;
  static const double md = s12;
  static const double base = s16;
  static const double lg = s20;
  static const double xl = s24;
  static const double xxl = s32;
  static const double xxxl = s48;
  static const double huge = s64;

  @Deprecated('Use AppRadius.sm instead')
  static const double radiusSm = 4.0;
  @Deprecated('Use AppRadius.md instead')
  static const double radiusMd = 8.0;
  @Deprecated('Use AppRadius.lg instead')
  static const double radiusLg = 12.0;
  @Deprecated('Use AppRadius.pill instead')
  static const double radiusFull = 9999.0;
}
