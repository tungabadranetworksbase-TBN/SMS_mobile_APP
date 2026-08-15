import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../storage/secure_storage.dart';
import '../../../core/config/app_constants.dart';

/// Injects Better Auth session token into every outgoing request.
///
/// Pattern: Zentriva's SharedPreferences token injection, but using
/// flutter_secure_storage for encrypted token persistence.
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  AuthInterceptor({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.read(AppConstants.keySessionToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      _logger.w('Failed to read auth token: $e');
    }
    handler.next(options);
  }
}
