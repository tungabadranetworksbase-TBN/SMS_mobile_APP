import 'api_error_code.dart';
import 'api_exception.dart';

/// Shapes the backend's response envelope.
///
/// Success: `{ "success": true, "data": … }`
/// Failure: `{ "success": false, "error": { "code", "message", "details"? } }`
/// — `server/src/lib/response.ts`
///
/// `/api/auth/*` is Better Auth and does NOT use this envelope, so both
/// helpers pass unrecognised bodies through untouched rather than assuming
/// a shape.
class ApiEnvelope {
  ApiEnvelope._();

  /// Returns the payload inside a success envelope, or [body] unchanged when
  /// it is not one.
  static dynamic unwrap(dynamic body) {
    if (body is Map &&
        body.containsKey('success') &&
        body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Builds a typed exception from a failure envelope, falling back to plain
  /// status-code mapping when [body] is not one.
  static ApiException toException(int statusCode, dynamic body) {
    if (body is Map && body['error'] is Map) {
      final error = body['error'] as Map;
      final message = error['message']?.toString();
      return ApiException(
        message: message ?? _fallbackMessage(statusCode),
        technicalMessage: error['code']?.toString(),
        statusCode: statusCode,
        data: error['details'],
        code: ApiErrorCode.fromWire(error['code']?.toString()),
      );
    }
    return ApiException.fromStatusCode(statusCode);
  }

  static String _fallbackMessage(int statusCode) =>
      ApiException.fromStatusCode(statusCode).message;
}
