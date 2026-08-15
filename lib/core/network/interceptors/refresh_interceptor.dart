import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../config/api_endpoints.dart';
import '../../config/app_constants.dart';
import '../../storage/secure_storage.dart';

/// Handles 401 responses by refreshing the Better Auth session token
/// and retrying the original request.
///
/// Pattern: Zentriva's re-login flow, but automated with token refresh.
class RefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();
  bool _isRefreshing = false;

  RefreshInterceptor({
    required Dio dio,
    required SecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken =
          await _secureStorage.read(AppConstants.keyRefreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        return handler.next(err);
      }

      // Attempt to refresh the session
      final response = await _dio.post(
        ApiEndpoints.refreshSession,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        final newRefresh = response.data['refreshToken'] as String?;

        if (newToken != null) {
          await _secureStorage.write(AppConstants.keySessionToken, newToken);
          if (newRefresh != null) {
            await _secureStorage.write(
                AppConstants.keyRefreshToken, newRefresh);
          }

          // Retry original request with new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';

          final retryResponse = await _dio.fetch(retryOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      }

      _isRefreshing = false;
      handler.next(err);
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      _isRefreshing = false;

      // Clear tokens — force re-login
      await _secureStorage.delete(AppConstants.keySessionToken);
      await _secureStorage.delete(AppConstants.keyRefreshToken);

      handler.next(err);
    }
  }
}
