import '../network/api_exception.dart';
import '../router/route_names.dart';
import 'capabilities.dart';
import 'destinations.dart';

/// Post-auth and API-error routing. Pure — no Flutter, no I/O.
class SessionGates {
  SessionGates._();

  /// Better Auth answers unverified sign-in with 403 and no session.
  static bool needsEmailOtp(ApiException e) {
    if (e.statusCode != 403) return false;
    if (e.isRegFeeRequired || e.isPasswordChangeRequired || e.isAccountNotActive) {
      return false;
    }
    return true;
  }

  static String destination({
    required Capabilities caps,
    required bool regFeeRequired,
  }) {
    if (caps.mustChangePassword) return RoutePaths.forcedPasswordChange;
    if (regFeeRequired && caps.tier == UserTier.student) {
      return RoutePaths.registration;
    }
    return homeRouteFor(caps);
  }
}
