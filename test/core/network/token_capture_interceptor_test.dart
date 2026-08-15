import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbn_lms/core/config/app_constants.dart';
import 'package:tbn_lms/core/network/interceptors/token_capture_interceptor.dart';
import 'package:tbn_lms/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

Response<dynamic> _responseWith(Map<String, List<String>> headers) => Response(
  requestOptions: RequestOptions(path: '/auth/sign-in/email'),
  statusCode: 200,
  headers: Headers.fromMap(headers),
);

void main() {
  late MockSecureStorage storage;
  late TokenCaptureInterceptor interceptor;

  setUp(() {
    storage = MockSecureStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    interceptor = TokenCaptureInterceptor(secureStorage: storage);
  });

  test('stores the token when the header is present', () async {
    final handler = ResponseInterceptorHandler();
    interceptor.onResponse(
      _responseWith({
        'set-auth-token': ['signed.token.value'],
      }),
      handler,
    );
    await Future<void>.delayed(Duration.zero);

    verify(
      () => storage.write(AppConstants.keySessionToken, 'signed.token.value'),
    ).called(1);
  });

  test('writes nothing when the header is absent', () async {
    final handler = ResponseInterceptorHandler();
    interceptor.onResponse(
      _responseWith({
        'content-type': ['application/json'],
      }),
      handler,
    );
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => storage.write(any(), any()));
  });

  test('ignores an empty header value', () async {
    final handler = ResponseInterceptorHandler();
    interceptor.onResponse(
      _responseWith({
        'set-auth-token': [''],
      }),
      handler,
    );
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => storage.write(any(), any()));
  });
}
