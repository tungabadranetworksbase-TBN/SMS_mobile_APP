import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/network/api_envelope.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';

void main() {
  group('ApiEnvelope.unwrap', () {
    test('unwraps a standard success envelope', () {
      final body = {
        'success': true,
        'data': {'id': '1', 'name': 'Asha'},
      };
      expect(ApiEnvelope.unwrap(body), {'id': '1', 'name': 'Asha'});
    });

    test('unwraps a list payload', () {
      final body = {
        'success': true,
        'data': [1, 2, 3],
      };
      expect(ApiEnvelope.unwrap(body), [1, 2, 3]);
    });

    test('unwraps a null data payload', () {
      final body = {'success': true, 'data': null};
      expect(ApiEnvelope.unwrap(body), isNull);
    });

    test('passes a Better Auth body through untouched', () {
      // /api/auth/* does not use the envelope. Unwrapping it would destroy it.
      final body = {
        'token': 'abc',
        'user': {'id': '1'},
      };
      expect(ApiEnvelope.unwrap(body), body);
    });

    test('passes a bare list through untouched', () {
      expect(ApiEnvelope.unwrap([1, 2]), [1, 2]);
    });

    test('does not unwrap a payload that merely has a data key', () {
      // No `success` key => not our envelope.
      final body = {'data': 'something'};
      expect(ApiEnvelope.unwrap(body), body);
    });
  });

  group('ApiEnvelope.toException', () {
    test('reads code and message from the failure envelope', () {
      final body = {
        'success': false,
        'error': {
          'code': 'REG_FEE_REQUIRED',
          'message': 'Pay the registration fee first',
        },
      };
      final e = ApiEnvelope.toException(403, body);
      expect(e.code, ApiErrorCode.regFeeRequired);
      expect(e.message, 'Pay the registration fee first');
      expect(e.statusCode, 403);
      expect(e.isRegFeeRequired, isTrue);
    });

    test('distinguishes a plain 403 from a gate 403', () {
      final plain = ApiEnvelope.toException(403, {
        'success': false,
        'error': {'code': 'FORBIDDEN', 'message': 'No access'},
      });
      expect(plain.isRegFeeRequired, isFalse);
      expect(plain.code, ApiErrorCode.forbidden);
    });

    test('unrecognised code still carries the server message', () {
      final e = ApiEnvelope.toException(400, {
        'success': false,
        'error': {'code': 'SOME_FUTURE_CODE', 'message': 'Nope'},
      });
      expect(e.code, ApiErrorCode.unknown);
      expect(e.message, 'Nope');
    });

    test('falls back to status mapping for a non-envelope body', () {
      // Better Auth 403 on an unverified email.
      final e = ApiEnvelope.toException(403, {'message': 'Email not verified'});
      expect(e.statusCode, 403);
      expect(e.code, ApiErrorCode.forbidden);
    });

    test('falls back to status mapping for a null body', () {
      final e = ApiEnvelope.toException(500, null);
      expect(e.statusCode, 500);
    });

    test('carries details through as data when present', () {
      final e = ApiEnvelope.toException(422, {
        'success': false,
        'error': {
          'code': 'UNPROCESSABLE',
          'message': 'Bad region',
          'details': {'field': 'region'},
        },
      });
      expect(e.data, {'field': 'region'});
    });
  });
}
