import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'network_info.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

/// Tungabadra Networks LMS — Dio API Client
///
/// Central HTTP client with full interceptor chain.
/// Pattern: Zentriva's HTTP calls, but isolated into a dedicated client
/// with proper error handling and typed responses.
///
/// Interceptor order:
///   Connectivity → Auth → Logging → [Request] → Retry → Refresh
class ApiClient {
  late final Dio _dio;
  final AppConfig _config;

  ApiClient({
    required String initialBaseUrl,
    required AppConfig config,
    required SecureStorage secureStorage,
    required NetworkInfo networkInfo,
  }) : _config = config {
    _dio = Dio(
      BaseOptions(
        baseUrl: initialBaseUrl,
        connectTimeout: _config.connectTimeout,
        receiveTimeout: _config.receiveTimeout,
        sendTimeout: _config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptor Chain ──
    _dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo: networkInfo),
      AuthInterceptor(secureStorage: secureStorage),
      if (kDebugMode) LoggingInterceptor(),
      RetryInterceptor(
        dio: _dio,
        maxRetries: _config.maxRetries,
        baseDelay: _config.retryDelay,
      ),
      RefreshInterceptor(
        dio: _dio,
        secureStorage: secureStorage,
      ),
    ]);
  }

  /// Direct access to Dio for advanced use cases.
  Dio get dio => _dio;

  /// Update the base URL dynamically when a user configures their server.
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  // ══════════════════════════════════════════════
  // HTTP METHODS
  // ══════════════════════════════════════════════

  /// GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      fromJson: fromJson,
    );
  }

  /// POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
      fromJson: fromJson,
    );
  }

  /// PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.put(path, data: data),
      fromJson: fromJson,
    );
  }

  /// PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.patch(path, data: data),
      fromJson: fromJson,
    );
  }

  /// DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.delete(path, data: data),
      fromJson: fromJson,
    );
  }

  /// Multipart file upload.
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(
      () => _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      ),
      fromJson: fromJson,
    );
  }

  /// Download file to local path.
  Future<void> download(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // ══════════════════════════════════════════════
  // INTERNAL
  // ══════════════════════════════════════════════

  Future<ApiResponse<T>> _request<T>(
    Future<Response> Function() request, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await request();
      final responseData = response.data;

      T? data;
      if (fromJson != null && responseData != null) {
        data = fromJson(responseData);
      } else if (responseData is T) {
        data = responseData;
      }

      // Check for pagination metadata
      PaginationMeta? pagination;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('pagination')) {
        pagination =
            PaginationMeta.fromJson(responseData['pagination'] as Map<String, dynamic>);
      }

      return ApiResponse.success(
        data as T,
        statusCode: response.statusCode,
        pagination: pagination,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw const ApiException.unknown();
    }
  }

  ApiException _mapDioException(DioException e) {
    // If the error is already an ApiException (from connectivity interceptor)
    if (e.error is ApiException) return e.error as ApiException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException.timeout();
      case DioExceptionType.connectionError:
        return const ApiException.network();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body = e.response?.data is Map
            ? (e.response!.data as Map)['message']?.toString()
            : e.response?.data?.toString();
        return ApiException.fromStatusCode(statusCode, body: body);
      default:
        return const ApiException.unknown();
    }
  }
}
