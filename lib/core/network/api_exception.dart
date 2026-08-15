import 'package:equatable/equatable.dart';

import 'api_error_code.dart';

/// Tungabadra Networks LMS — Typed API Exceptions
///
/// Every network error is mapped to a typed exception.
/// UI displays user-friendly messages; logs contain technical details.
class ApiException extends Equatable implements Exception {
  final String message;
  final String? technicalMessage;
  final int? statusCode;
  final dynamic data;

  /// The backend's `error.code`. Drives routing decisions in Stage B —
  /// two 403s can mean very different things.
  final ApiErrorCode code;

  const ApiException({
    required this.message,
    this.technicalMessage,
    this.statusCode,
    this.data,
    this.code = ApiErrorCode.unknown,
  });

  // ── Named Constructors ──

  const ApiException.network()
    : message = 'No internet connection. Please check your network.',
      technicalMessage = 'NetworkException',
      statusCode = null,
      data = null,
      code = ApiErrorCode.unknown;

  const ApiException.timeout()
    : message = 'Request timed out. Please try again.',
      technicalMessage = 'TimeoutException',
      statusCode = null,
      data = null,
      code = ApiErrorCode.unknown;

  const ApiException.unauthorized()
    : message = 'Session expired. Please log in again.',
      technicalMessage = 'UnauthorizedException',
      statusCode = 401,
      data = null,
      code = ApiErrorCode.unauthorized;

  const ApiException.forbidden()
    : message = 'You don\'t have permission for this action.',
      technicalMessage = 'ForbiddenException',
      statusCode = 403,
      data = null,
      code = ApiErrorCode.forbidden;

  const ApiException.notFound()
    : message = 'The requested resource was not found.',
      technicalMessage = 'NotFoundException',
      statusCode = 404,
      data = null,
      code = ApiErrorCode.notFound;

  const ApiException.server()
    : message = 'Server error. Please try again later.',
      technicalMessage = 'InternalServerError',
      statusCode = 500,
      data = null,
      code = ApiErrorCode.internal;

  const ApiException.unknown()
    : message = 'Something went wrong. Please try again.',
      technicalMessage = 'UnknownException',
      statusCode = null,
      data = null,
      code = ApiErrorCode.unknown;

  factory ApiException.fromStatusCode(int statusCode, {String? body}) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message: body ?? 'Invalid request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        return const ApiException.unauthorized();
      case 403:
        return const ApiException.forbidden();
      case 404:
        return const ApiException.notFound();
      case 422:
        return ApiException(
          message: body ?? 'Validation error.',
          statusCode: 422,
        );
      case 429:
        return const ApiException(
          message: 'Too many requests. Please wait a moment.',
          statusCode: 429,
        );
      default:
        if (statusCode >= 500) return const ApiException.server();
        return const ApiException.unknown();
    }
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork => technicalMessage == 'NetworkException';

  bool get isRegFeeRequired => code == ApiErrorCode.regFeeRequired;
  bool get isPasswordChangeRequired =>
      code == ApiErrorCode.passwordChangeRequired;
  bool get isAccountNotActive => code == ApiErrorCode.accountNotActive;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() => 'ApiException(${code.wire} $statusCode: $message)';
}
