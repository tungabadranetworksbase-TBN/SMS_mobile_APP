import 'api_error_code.dart';
import 'api_exception.dart';

/// Marks a client feature that has no route on the LMS backend.
///
/// Parts of this app were built against an API that was never implemented
/// server-side. Rather than point those call sites at a plausible-looking URL
/// that would 404 at runtime, they throw this.
///
/// The failure is deliberate and loud: a wrong URL produces a confusing 404,
/// while this names the missing capability. When the backend gains the module,
/// replace the throw with the real call; `grep unsupportedEndpoint` lists
/// everything still outstanding — currently assignments, the SMR dashboard
/// and avatar upload.
///
/// The screens for these features were removed rather than left unreachable;
/// the routes that remain render FeatureUnavailableScreen. Certificates,
/// support tickets and attendance had no live call site left at all, so their
/// code is gone entirely — recover it from history if a backend module lands.
ApiException unsupportedEndpoint(String feature) => ApiException(
  message: '$feature is not available on this server yet.',
  technicalMessage: 'UnsupportedEndpoint($feature)',
  code: ApiErrorCode.notFound,
  statusCode: 501,
);
