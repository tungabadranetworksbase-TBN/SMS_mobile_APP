import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Tungabadra Networks LMS — Application Configuration
///
/// Environment-driven configuration singleton.
/// Pattern: Zentriva singleton (SessionManager-style).
class AppConfig {
  AppConfig._internal();
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;

  // ── API ──
  String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  // ── Razorpay ──
  String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  // ── MinIO ──
  String get minioEndpoint =>
      dotenv.env['MINIO_ENDPOINT'] ?? '';

  // ── Timeouts ──
  Duration get connectTimeout => const Duration(seconds: 15);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);

  // ── Retry ──
  int get maxRetries => 3;
  Duration get retryDelay => const Duration(seconds: 1);

  // ── Notification Polling (Zentriva pattern) ──
  Duration get notificationPollInterval => const Duration(seconds: 10);

  // ── Cache ──
  Duration get cacheTtl => const Duration(minutes: 15);

  // ── Pagination ──
  int get defaultPageSize => 20;

  // ── Feature Flags ──
  bool get enableOfflineMode => true;
  bool get enableBiometricAuth => true;
  bool get enablePushNotifications => true;
}
