/// The backend's `error.code` vocabulary.
///
/// Values are verbatim from `server/src/lib/response.ts` (the `ApiError`
/// factories) plus the custom codes raised in `middlewares/authenticate.ts`,
/// `middlewares/region.ts`, `app.ts` and `lib/auth.ts`.
///
/// [unknown] is deliberate: the backend gains codes without a client release,
/// and an unrecognised code must degrade rather than crash.
enum ApiErrorCode {
  badRequest('BAD_REQUEST'),
  validationError('VALIDATION_ERROR'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  conflict('CONFLICT'),
  unprocessable('UNPROCESSABLE'),
  rateLimited('RATE_LIMITED'),
  internal('INTERNAL'),
  serviceUnavailable('SERVICE_UNAVAILABLE'),

  /// Student has not cleared the registration-fee gate (`requireRegFeePaid`).
  regFeeRequired('REG_FEE_REQUIRED'),

  /// Account is on an administrator-set password; every non-GET is blocked.
  passwordChangeRequired('PASSWORD_CHANGE_REQUIRED'),

  /// Account suspended or pending activation.
  accountNotActive('ACCOUNT_NOT_ACTIVE'),

  corsForbidden('CORS_FORBIDDEN'),
  selfModification('SELF_MODIFICATION'),
  timeLimitExceeded('TIME_LIMIT_EXCEEDED'),
  monitoringDisabled('MONITORING_DISABLED'),

  /// Not in the envelope — Better Auth raises this on a weak password.
  weakPassword('WEAK_PASSWORD'),

  unknown('UNKNOWN');

  const ApiErrorCode(this.wire);

  /// The exact string the backend sends in `error.code`.
  final String wire;

  static ApiErrorCode fromWire(String? wire) {
    if (wire == null) return ApiErrorCode.unknown;
    for (final code in ApiErrorCode.values) {
      if (code.wire == wire) return code;
    }
    return ApiErrorCode.unknown;
  }
}
