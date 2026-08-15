// test/features/auth/users_api_service_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbn_lms/core/config/app_config.dart';
import 'package:tbn_lms/core/config/app_constants.dart';
import 'package:tbn_lms/core/network/api_client.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';
import 'package:tbn_lms/core/network/api_exception.dart';
import 'package:tbn_lms/core/network/network_info.dart';
import 'package:tbn_lms/core/storage/secure_storage.dart';
import 'package:tbn_lms/features/auth/data/services/users_api_service.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object? body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockSecureStorage storage;
  late MockNetworkInfo network;

  setUp(() {
    storage = MockSecureStorage();
    network = MockNetworkInfo();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    when(() => network.isConnected).thenAnswer((_) async => true);
  });

  ApiClient buildClient(_RecordingAdapter adapter) {
    final client = ApiClient(
      initialBaseUrl: 'https://lms.test/api',
      config: AppConfig(),
      secureStorage: storage,
      networkInfo: network,
    );
    client.dio.httpClientAdapter = adapter;
    return client;
  }

  test('a signed-in GET /users/me parses into MeDto', () async {
    when(
      () => storage.read(AppConstants.keySessionToken),
    ).thenAnswer((_) async => 'signed.session.token');

    final adapter = _RecordingAdapter(200, {
      'success': true,
      'data': {
        'user': {
          'id': 'usr_1',
          'name': 'Asha Rao',
          'email': 'asha@example.com',
          'emailVerified': true,
          'image': null,
          'userType': 'STAFF',
          'status': 'ACTIVE',
          'createdAt': '2026-01-04T09:12:00.000Z',
          'mustChangePassword': false,
        },
        'permissions': ['students.account.view'],
        'modules': {'students': true, 'crm': false},
      },
    });

    final service = UsersApiService(apiClient: buildClient(adapter));
    final response = await service.fetchMe();

    expect(response.success, isTrue);
    expect(response.data!.user.name, 'Asha Rao');
    expect(response.data!.permissions, ['students.account.view']);
    expect(response.data!.modules['crm'], isFalse);

    // The bearer token must be on the wire, and the path must be /users/me.
    expect(adapter.lastRequest!.path, '/users/me');
    expect(
      adapter.lastRequest!.headers['Authorization'],
      'Bearer signed.session.token',
    );
  });

  test('an unauthenticated call surfaces UNAUTHORIZED', () async {
    when(
      () => storage.read(AppConstants.keySessionToken),
    ).thenAnswer((_) async => null);

    final adapter = _RecordingAdapter(401, {
      'success': false,
      'error': {'code': 'UNAUTHORIZED', 'message': 'Authentication required'},
    });

    final service = UsersApiService(apiClient: buildClient(adapter));

    await expectLater(
      service.fetchMe(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.unauthorized,
        ),
      ),
    );
    // No token stored => no Authorization header sent.
    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });
}
