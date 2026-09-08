import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/auth/capabilities.dart';
import 'package:tbn_lms/core/auth/session_gates.dart';
import 'package:tbn_lms/core/router/route_names.dart';

/// Every screen is reachable only through this decision, and it had no
/// coverage at all. Each test pins one branch.
void main() {
  String? go({
    bool isLoggedIn = true,
    bool hasServerUrl = true,
    Capabilities? caps,
    bool regFeeRequired = false,
    required String location,
  }) => SessionGates.redirect(
    isLoggedIn: isLoggedIn,
    hasServerUrl: hasServerUrl,
    caps: caps,
    regFeeRequired: regFeeRequired,
    location: location,
  );

  const student = Capabilities(
    tier: UserTier.student,
    permissions: {},
    modules: {},
  );
  const smr = Capabilities(
    tier: UserTier.staff,
    permissions: {'students.account.view'},
    modules: {},
  );
  const staffWithNothing = Capabilities(
    tier: UserTier.staff,
    permissions: {},
    modules: {},
  );

  group('signed out', () {
    test('with no server configured, everything goes to setup', () {
      expect(
        go(
          isLoggedIn: false,
          hasServerUrl: false,
          location: RoutePaths.login,
        ),
        RoutePaths.serverConfig,
      );
    });

    test('already on setup, stays put — no redirect loop', () {
      expect(
        go(
          isLoggedIn: false,
          hasServerUrl: false,
          location: RoutePaths.serverConfig,
        ),
        isNull,
      );
    });

    test('auth screens are allowed once a server is configured', () {
      for (final route in [
        RoutePaths.login,
        RoutePaths.signup,
        RoutePaths.forgotPassword,
        RoutePaths.resetPassword,
        RoutePaths.verifyEmail,
        RoutePaths.serverConfig,
      ]) {
        expect(go(isLoggedIn: false, location: route), isNull, reason: route);
      }
    });

    test('anything else goes to login', () {
      expect(
        go(isLoggedIn: false, location: RoutePaths.studentCourses),
        RoutePaths.login,
      );
    });
  });

  group('signed in without capabilities', () {
    test('bounces to login rather than holding the splash', () {
      // The splash trap: a leftover token with no caps used to stick forever.
      expect(go(caps: null, location: RoutePaths.splash), RoutePaths.login);
      expect(
        go(caps: null, location: RoutePaths.studentDashboard),
        RoutePaths.login,
      );
    });
  });

  group('gates', () {
    const mustChange = Capabilities(
      tier: UserTier.student,
      permissions: {},
      modules: {},
      mustChangePassword: true,
    );

    test('a forced password change holds its own screen', () {
      expect(
        go(caps: mustChange, location: RoutePaths.forcedPasswordChange),
        isNull,
      );
    });

    test('it also outranks wherever the user was heading', () {
      expect(
        go(caps: mustChange, location: RoutePaths.studentCourses),
        RoutePaths.forcedPasswordChange,
      );
    });

    test('leaving the gate screen once cleared goes home, not back', () {
      expect(
        go(caps: student, location: RoutePaths.forcedPasswordChange),
        RoutePaths.studentDashboard,
      );
    });

    test('an unpaid registration fee pins a student to registration', () {
      expect(
        go(
          caps: student,
          regFeeRequired: true,
          location: RoutePaths.registration,
        ),
        isNull,
      );
      expect(
        go(
          caps: student,
          regFeeRequired: true,
          location: RoutePaths.studentCourses,
        ),
        RoutePaths.registration,
      );
    });

    test('it does not pin staff — the fee gate is student-only', () {
      expect(
        go(
          caps: smr,
          regFeeRequired: true,
          location: RoutePaths.staffStudents,
        ),
        isNull,
      );
    });
  });

  group('signed in on a dead-end screen', () {
    test('splash and auth screens send the user to their home', () {
      for (final route in [RoutePaths.splash, RoutePaths.login]) {
        expect(
          go(caps: student, location: route),
          RoutePaths.studentDashboard,
          reason: route,
        );
      }
      expect(go(caps: smr, location: RoutePaths.splash), RoutePaths.staffStudents);
    });
  });

  group('staff area', () {
    test('a student cannot enter it', () {
      expect(
        go(caps: student, location: RoutePaths.staffStudents),
        RoutePaths.studentDashboard,
      );
    });

    test('staff reach the tab their permissions allow', () {
      expect(go(caps: smr, location: RoutePaths.staffStudents), isNull);
    });

    test('and are turned away from one they do not have', () {
      // smr holds students.account.view only, not insights.dashboard.view.
      expect(
        go(caps: smr, location: RoutePaths.staffInsights),
        RoutePaths.staffStudents,
      );
    });

    test('sub-routes of an allowed tab are allowed', () {
      expect(go(caps: smr, location: '${RoutePaths.staffStudents}/42'), isNull);
    });

    test('staff with no visible tab belong on the unavailable screen', () {
      expect(
        go(caps: staffWithNothing, location: RoutePaths.staffUnavailable),
        isNull,
      );
    });

    test('staff who do have a tab are moved off it', () {
      expect(
        go(caps: smr, location: RoutePaths.staffUnavailable),
        RoutePaths.staffStudents,
      );
    });
  });

  test('an ordinary student route is left alone', () {
    expect(go(caps: student, location: RoutePaths.studentBatches), isNull);
  });
}
