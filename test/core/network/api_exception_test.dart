// test/core/network/api_exception_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';
import 'package:tbn_lms/core/network/api_exception.dart';

void main() {
  group('ApiException code', () {
    test('defaults to unknown when not supplied', () {
      const e = ApiException(message: 'boom');
      expect(e.code, ApiErrorCode.unknown);
    });

    test('named constructors carry their code', () {
      expect(const ApiException.unauthorized().code, ApiErrorCode.unauthorized);
      expect(const ApiException.forbidden().code, ApiErrorCode.forbidden);
      expect(const ApiException.notFound().code, ApiErrorCode.notFound);
    });

    test('gate getters read the code, not the message', () {
      const e = ApiException(
        message: 'Registration fee required',
        statusCode: 403,
        code: ApiErrorCode.regFeeRequired,
      );
      expect(e.isRegFeeRequired, isTrue);
      expect(e.isPasswordChangeRequired, isFalse);
      expect(e.isAccountNotActive, isFalse);
    });

    test('equality distinguishes two 403s with different codes', () {
      const a = ApiException(
        message: 'x',
        statusCode: 403,
        code: ApiErrorCode.regFeeRequired,
      );
      const b = ApiException(
        message: 'x',
        statusCode: 403,
        code: ApiErrorCode.forbidden,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
