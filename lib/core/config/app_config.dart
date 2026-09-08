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

  /// Public web app origin for payment return URLs (no trailing slash).
  String? get clientOrigin {
    final value = dotenv.env['CLIENT_ORIGIN']?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  // ── Razorpay ──
  String get razorpayKeyId => dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  // ── Timeouts ──
  Duration get connectTimeout => const Duration(seconds: 15);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);

  // ── Retry ──
  int get maxRetries => 3;
  Duration get retryDelay => const Duration(seconds: 1);
}
