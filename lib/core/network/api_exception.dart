import 'package:equatable/equatable.dart';

/// Tungabadra Networks LMS — Typed API Exceptions
///
/// Every network error is mapped to a typed exception.
/// UI displays user-friendly messages; logs contain technical details.
class ApiException extends Equatable implements Exception {
  final String message;
  final String? technicalMessage;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.technicalMessage,
    this.statusCode,
    this.data,
  });

  // ── Named Constructors ──

  const ApiException.network()
      : message = 'No internet connection. Please check your network.',
        technicalMessage = 'NetworkException',
        statusCode = null,
        data = null;

  const ApiException.timeout()
      : message = 'Request timed out. Please try again.',
        technicalMessage = 'TimeoutException',
        statusCode = null,
        data = null;

  const ApiException.unauthorized()
      : message = 'Session expired. Please log in again.',
        technicalMessage = 'UnauthorizedException',
        statusCode = 401,
        data = null;

  const ApiException.forbidden()
      : message = 'You don\'t have permission for this action.',
        technicalMessage = 'ForbiddenException',
        statusCode = 403,
        data = null;

  const ApiException.notFound()
      : message = 'The requested resource was not found.',
        technicalMessage = 'NotFoundException',
        statusCode = 404,
        data = null;

  const ApiException.server()
      : message = 'Server error. Please try again later.',
        technicalMessage = 'InternalServerError',
        statusCode = 500,
        data = null;

  const ApiException.unknown()
      : message = 'Something went wrong. Please try again.',
        technicalMessage = 'UnknownException',
        statusCode = null,
        data = null;

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

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'ApiException($statusCode: $message)';
}
