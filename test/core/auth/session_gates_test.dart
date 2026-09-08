import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/auth/capabilities.dart';
import 'package:tbn_lms/core/auth/session_gates.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';
import 'package:tbn_lms/core/network/api_exception.dart';
import 'package:tbn_lms/core/router/route_names.dart';

void main() {
  group('SessionGates.needsEmailOtp', () {
    test('plain 403 at sign-in (unverified) needs OTP', () {
      expect(
        SessionGates.needsEmailOtp(const ApiException.forbidden()),
        isTrue,
      );
    });

    test('REG_FEE_REQUIRED is not an OTP 403', () {
      expect(
        SessionGates.needsEmailOtp(
          const ApiException(
            message: 'pay',
            statusCode: 403,
            code: ApiErrorCode.regFeeRequired,
          ),
        ),
        isFalse,
      );
    });

    test('wrong password 401 is not OTP', () {
      expect(
        SessionGates.needsEmailOtp(const ApiException.unauthorized()),
        isFalse,
      );
    });
  });

  group('SessionGates.destination', () {
    test('mustChangePassword wins over home', () {
      const caps = Capabilities(
        tier: UserTier.student,
        permissions: {},
        modules: {},
        mustChangePassword: true,
      );
      expect(
        SessionGates.destination(caps: caps, regFeeRequired: false),
        RoutePaths.forcedPasswordChange,
      );
    });

    test('REG_FEE_REQUIRED sends students to registration', () {
      const caps = Capabilities(
        tier: UserTier.student,
        permissions: {},
        modules: {},
      );
      expect(
        SessionGates.destination(caps: caps, regFeeRequired: true),
        RoutePaths.registration,
      );
    });

    test('staff is not sent to the student registration gate', () {
      const caps = Capabilities(
        tier: UserTier.staff,
        permissions: {'students.account.view'},
        modules: {},
      );
      expect(
        SessionGates.destination(caps: caps, regFeeRequired: true),
        RoutePaths.staffStudents,
      );
    });
  });
}
