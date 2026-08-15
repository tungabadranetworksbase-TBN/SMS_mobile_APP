// test/core/network/api_client_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbn_lms/core/config/app_config.dart';
import 'package:tbn_lms/core/network/api_client.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';
import 'package:tbn_lms/core/network/api_exception.dart';
import 'package:tbn_lms/core/network/network_info.dart';
import 'package:tbn_lms/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

/// Serves a canned response without touching the network, so the whole
/// interceptor chain is exercised.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body, {this.headers = const {}});

  final int statusCode;
  final Object? body;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _clientServing(
  int status,
  Object? body, {
  Map<String, List<String>> headers = const {},
}) {
  final storage = MockSecureStorage();
  final network = MockNetworkInfo();
  when(() => storage.read(any())).thenAnswer((_) async => null);
  when(() => storage.write(any(), any())).thenAnswer((_) async {});
  when(() => network.isConnected).thenAnswer((_) async => true);

  final client = ApiClient(
    initialBaseUrl: 'https://example.test/api',
    config: AppConfig(),
    secureStorage: storage,
    networkInfo: network,
  );
  client.dio.httpClientAdapter = _FakeAdapter(status, body, headers: headers);
  return client;
}

void main() {
  test('unwraps the success envelope before calling fromJson', () async {
    final client = _clientServing(200, {
      'success': true,
      'data': {'id': 'u1', 'name': 'Asha'},
    });

    final response = await client.get<Map<String, dynamic>>(
      '/users/me',
      fromJson: (json) {
        // Must receive the payload, never the envelope.
        expect((json as Map).containsKey('success'), isFalse);
        return Map<String, dynamic>.from(json);
      },
    );

    expect(response.data!['name'], 'Asha');
    expect(response.success, isTrue);
  });

  test('passes a Better Auth body through without unwrapping', () async {
    final client = _clientServing(200, {
      'token': 'abc',
      'user': {'id': 'u1'},
    });

    final response = await client.post<Map<String, dynamic>>(
      '/auth/sign-in/email',
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    expect(response.data!['token'], 'abc');
  });

  test('throws a typed exception carrying the gate code', () async {
    final client = _clientServing(403, {
      'success': false,
      'error': {'code': 'REG_FEE_REQUIRED', 'message': 'Pay first'},
    });

    await expectLater(
      client.get<dynamic>('/student/dashboard'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.regFeeRequired)
            .having((e) => e.message, 'message', 'Pay first')
            .having((e) => e.statusCode, 'statusCode', 403),
      ),
    );
  });

  test('a 404 on a disabled module is typed, not swallowed', () async {
    final client = _clientServing(404, {
      'success': false,
      'error': {'code': 'NOT_FOUND', 'message': 'Resource not found'},
    });

    await expectLater(
      client.get<dynamic>('/crm/leads'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test(
    'a 401 surfaces as unauthorized rather than being retried away',
    () async {
      final client = _clientServing(401, {
        'success': false,
        'error': {'code': 'UNAUTHORIZED', 'message': 'Authentication required'},
      });

      await expectLater(
        client.get<dynamic>('/users/me'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unauthorized,
          ),
        ),
      );
    },
  );
}
