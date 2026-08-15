import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logs all HTTP requests and responses in debug mode.
///
/// Pattern: Zentriva's print-based logging, upgraded to structured Logger.
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${options.uri}\n'
      '  Headers: ${options.headers}\n'
      '  Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      '  Data: ${_truncate(response.data.toString(), 500)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✖ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.uri}\n'
      '  Type: ${err.type}\n'
      '  Message: ${err.message}',
    );
    handler.next(err);
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
