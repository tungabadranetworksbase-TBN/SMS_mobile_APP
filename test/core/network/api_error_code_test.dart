import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';

void main() {
  group('ApiErrorCode.fromWire', () {
    test('maps every known backend code', () {
      expect(
        ApiErrorCode.fromWire('REG_FEE_REQUIRED'),
        ApiErrorCode.regFeeRequired,
      );
      expect(
        ApiErrorCode.fromWire('PASSWORD_CHANGE_REQUIRED'),
        ApiErrorCode.passwordChangeRequired,
      );
      expect(
        ApiErrorCode.fromWire('ACCOUNT_NOT_ACTIVE'),
        ApiErrorCode.accountNotActive,
      );
      expect(ApiErrorCode.fromWire('UNAUTHORIZED'), ApiErrorCode.unauthorized);
      expect(
        ApiErrorCode.fromWire('VALIDATION_ERROR'),
        ApiErrorCode.validationError,
      );
      expect(
        ApiErrorCode.fromWire('ACTIVATION_REQUIRED'),
        ApiErrorCode.activationRequired,
      );
    });

    test('unknown code degrades instead of throwing', () {
      // The backend adds codes without warning; an unrecognised one must not crash.
      expect(ApiErrorCode.fromWire('SOME_FUTURE_CODE'), ApiErrorCode.unknown);
    });

    test('null degrades to unknown', () {
      expect(ApiErrorCode.fromWire(null), ApiErrorCode.unknown);
    });

    test('wire values are unique', () {
      final wires = ApiErrorCode.values.map((c) => c.wire).toList();
      expect(wires.toSet().length, wires.length);
    });
  });
}
