/// Tungabadra Networks LMS — Application Constants
class AppConstants {
  AppConstants._();

  // ── App Identity ──
  static const String appName = 'Tungabadra Networks';
  static const String appTagline = 'Learning Management System';
  static const String appVersion = '1.0.0';

  // ── Storage Keys ──
  static const String keySessionToken = 'session_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserAvatar = 'user_avatar';
  static const String keyServerUrl = 'server_url';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyNotificationsSeen = 'notifications_seen';

  // ── User Roles ──
  static const String roleStudent = 'student';
  static const String roleSmr = 'smr';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  // ── Pagination ──
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Debounce ──
  static const Duration searchDebounce = Duration(milliseconds: 400);
}
