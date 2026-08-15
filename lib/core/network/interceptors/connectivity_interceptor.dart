import 'package:dio/dio.dart';

import '../network_info.dart';
import '../api_exception.dart';

/// Blocks requests when device is offline and throws a typed exception.
class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;

  ConnectivityInterceptor({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const ApiException.network(),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    handler.next(options);
  }
}
