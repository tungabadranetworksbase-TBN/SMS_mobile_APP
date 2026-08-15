import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Retries failed requests with exponential backoff.
///
/// Only retries on network errors and 5xx server errors.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Logger _logger = Logger();

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  }) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      return handler.next(err);
    }

    final delay = baseDelay * pow(2, retryCount).toInt();
    _logger.w(
      'Retrying request (${retryCount + 1}/$maxRetries) '
      'after ${delay.inMilliseconds}ms: ${err.requestOptions.uri}',
    );

    await Future.delayed(delay);

    try {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
