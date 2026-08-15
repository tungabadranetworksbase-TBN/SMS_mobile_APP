import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_envelope.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'network_info.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/token_capture_interceptor.dart';
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
///   Connectivity → Auth → TokenCapture → Logging → [Request] → Retry
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
    // Connectivity → Auth → TokenCapture → Logging → [Request] → Retry
    //
    // RefreshInterceptor is deliberately absent: Better Auth exposes no
    // refresh endpoint. It rolls the session via `updateAge` inside
    // `expiresIn`, so a 401 means "sign in again", not "refresh".
    _dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo: networkInfo),
      AuthInterceptor(secureStorage: secureStorage),
      TokenCaptureInterceptor(secureStorage: secureStorage),
      if (kDebugMode) LoggingInterceptor(),
      RetryInterceptor(
        dio: _dio,
        maxRetries: _config.maxRetries,
        baseDelay: _config.retryDelay,
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
    return _request(() => _dio.put(path, data: data), fromJson: fromJson);
  }

  /// PATCH request.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(() => _dio.patch(path, data: data), fromJson: fromJson);
  }

  /// DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    return _request(() => _dio.delete(path, data: data), fromJson: fromJson);
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
    await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
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
      final body = response.data;
      final payload = ApiEnvelope.unwrap(body);

      T? data;
      if (fromJson != null && payload != null) {
        data = fromJson(payload);
      } else if (payload is T) {
        data = payload;
      }

      // NOTE: the backend's `ok(res, data)` emits only `{success, data}` — it
      // never adds an envelope-level `pagination` key. Paged endpoints return
      // their own shape INSIDE `data`, and that shape is not uniform across
      // modules. Resolving it per endpoint is Stage D (spec §6.4); this read
      // stays as a no-op so the ApiResponse contract does not change under
      // callers mid-stage.
      PaginationMeta? pagination;
      if (body is Map<String, dynamic> &&
          body['pagination'] is Map<String, dynamic>) {
        pagination = PaginationMeta.fromJson(
          body['pagination'] as Map<String, dynamic>,
        );
      }

      return ApiResponse.success(
        data as T,
        statusCode: response.statusCode,
        pagination: pagination,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException.unknown();
    }
  }

  ApiException _mapDioException(DioException e) {
    // Already typed by the connectivity interceptor.
    if (e.error is ApiException) return e.error as ApiException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException.timeout();
      case DioExceptionType.connectionError:
        return const ApiException.network();
      case DioExceptionType.badResponse:
        return ApiEnvelope.toException(
          e.response?.statusCode ?? 0,
          e.response?.data,
        );
      default:
        return const ApiException.unknown();
    }
  }
}
