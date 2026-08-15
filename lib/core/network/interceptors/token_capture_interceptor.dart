import 'dart:async';

import 'package:dio/dio.dart';

import '../../config/app_constants.dart';
import '../../storage/secure_storage.dart';

/// Persists the session token Better Auth returns after a successful sign-in
/// or sign-up.
///
/// The `bearer()` plugin exposes the signed session cookie value as a
/// `set-auth-token` response header. It is opaque and HMAC-signed: store and
/// replay it byte-for-byte, never parse or rebuild it.
class TokenCaptureInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  TokenCaptureInterceptor({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final token = response.headers.value('set-auth-token');
    if (token != null && token.isNotEmpty) {
      // Fire-and-forget: the response must not block on the keystore.
      unawaited(_secureStorage.write(AppConstants.keySessionToken, token));
    }
    handler.next(response);
  }
}
