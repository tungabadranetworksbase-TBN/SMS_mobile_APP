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

  /// Routes that a signed-out user is allowed to sit on.
  static const _authRoutes = {
    RoutePaths.login,
    RoutePaths.signup,
    RoutePaths.forgotPassword,
    RoutePaths.resetPassword,
    RoutePaths.verifyEmail,
    RoutePaths.serverConfig,
  };

  /// The whole GoRouter redirect decision, as a pure function.
  ///
  /// Every screen in the app is reachable only through this, so it is kept
  /// free of Flutter and I/O: the router reads the stores and passes plain
  /// values in. Returns null to allow [location], or the path to go to.
  static String? redirect({
    required bool isLoggedIn,
    required bool hasServerUrl,
    required Capabilities? caps,
    required bool regFeeRequired,
    required String location,
  }) {
    if (!isLoggedIn) {
      // No server configured yet: nothing else can work, so pin to setup.
      if (!hasServerUrl) {
        return location == RoutePaths.serverConfig
            ? null
            : RoutePaths.serverConfig;
      }
      return _authRoutes.contains(location) ? null : RoutePaths.login;
    }

    // Authenticated but caps missing — boot hydration should have filled or
    // cleared the session. Bounce to login rather than hold the splash.
    if (caps == null) return RoutePaths.login;

    final dest = destination(caps: caps, regFeeRequired: regFeeRequired);

    // A gate screen may only be left for the gate the caps actually demand.
    if (location == RoutePaths.forcedPasswordChange ||
        location == RoutePaths.registration) {
      return location == dest ? null : dest;
    }

    // Signed in: auth screens and the splash have nothing left to show.
    if (_authRoutes.contains(location) || location == RoutePaths.splash) {
      return dest;
    }

    // An outstanding gate outranks wherever the user was heading.
    if (dest == RoutePaths.forcedPasswordChange ||
        dest == RoutePaths.registration) {
      return dest;
    }

    if (location.startsWith('/staff')) {
      if (caps.tier == UserTier.student) return RoutePaths.studentDashboard;

      if (location == RoutePaths.staffUnavailable) {
        // Only staff with no visible tab at all belong on this screen.
        return visibleStaffDestinations(caps).isEmpty ? null : dest;
      }
      final allowed = visibleStaffDestinations(
        caps,
      ).any((d) => location == d.route || location.startsWith('${d.route}/'));
      if (!allowed) return dest;
    }

    return null;
  }
}
