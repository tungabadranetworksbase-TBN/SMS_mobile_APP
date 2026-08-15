import 'api_error_code.dart';
import 'api_exception.dart';

/// Marks a client feature that has no route on the LMS backend.
///
/// Four screens in this app were built against an API that was never
/// implemented server-side: assignments, certificates, support tickets and
/// attendance, plus avatar upload and the SMR dashboard. Rather than point
/// those call sites at a plausible-looking URL that would 404 at runtime —
/// or leave them silently returning demo fixtures forever — they throw this.
///
/// The failure is deliberate and loud: a wrong URL produces a confusing 404,
/// while this names the missing capability. When the backend gains the module,
/// replace the throw with the real call; `grep unsupportedEndpoint` lists
/// everything still outstanding.
///
/// Demo mode short-circuits in the repository layer before reaching any of
/// these, so the screens still render from fixtures.
ApiException unsupportedEndpoint(String feature) => ApiException(
  message: '$feature is not available on this server yet.',
  technicalMessage: 'UnsupportedEndpoint($feature)',
  code: ApiErrorCode.notFound,
  statusCode: 501,
);
