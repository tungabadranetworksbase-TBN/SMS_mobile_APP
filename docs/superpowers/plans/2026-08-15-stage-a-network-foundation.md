# Stage A — Network Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Flutter client capable of a successful authenticated round-trip against the real LMS backend — correct paths, correct envelope, correct error semantics, bearer token capture.

**Architecture:** Response shaping moves out of `ApiClient` into two pure, fully-testable units (`ApiErrorCode`, `ApiEnvelope`). `ApiClient._request` becomes a thin caller of them. Token capture becomes an interceptor that reads Better Auth's `set-auth-token` response header. `RefreshInterceptor` is deleted outright — the endpoint it calls does not exist.

**Tech Stack:** Flutter 3.8 / Dart, Dio 5.7, `flutter_secure_storage`, `mocktail` (already a dev dependency), `flutter_test`.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-08-15-capability-driven-workspace-auth-design.md`. Stage A is §6 only.
- **No UI, routing, or `SessionManager` changes in Stage A.** 401 and gate codes are surfaced as typed exceptions; acting on them is Stage B.
- Backend success envelope is `{ "success": true, "data": … }`; failure is `{ "success": false, "error": { "code", "message", "details"? } }` (`server/src/lib/response.ts`).
- **`/api/auth/*` is Better Auth and does NOT use that envelope.** It returns its own JSON shape. Every parser must pass non-enveloped bodies through unchanged.
- API base URL already ends in `/api`; every constant in `ApiEndpoints` is relative to that and starts with `/`.
- Error code strings are verbatim from the backend — do not invent new ones.
- Dart formatting: `dart format` defaults. Analyzer must stay clean (`flutter analyze` currently reports 3 pre-existing `prefer_const_declarations` infos in `student_attendance_screen.dart`; do not introduce more).
- Commit after every task.

---

## File Structure

**Create**
| File | Responsibility |
|---|---|
| `lib/core/network/api_error_code.dart` | The backend's `error.code` vocabulary as a Dart enum. Pure. |
| `lib/core/network/api_envelope.dart` | Unwrap `{success,data}`; build a typed exception from `{success,error}`. Pure. |
| `lib/core/network/interceptors/token_capture_interceptor.dart` | Persist the `set-auth-token` header when Better Auth issues one. |
| `lib/features/auth/data/models/me_dto.dart` | `/api/users/me` payload: user + permissions + modules. |
| `lib/features/auth/data/services/users_api_service.dart` | `fetchMe()`. |
| `test/core/network/api_error_code_test.dart` | |
| `test/core/network/api_envelope_test.dart` | |
| `test/core/network/api_client_test.dart` | Full chain via a fake `HttpClientAdapter`. |
| `test/core/config/api_endpoints_test.dart` | |
| `test/features/auth/users_api_service_test.dart` | Stage A acceptance test. |

**Modify**
| File | Change |
|---|---|
| `lib/core/network/api_exception.dart` | Carry `ApiErrorCode`; add `fromEnvelope`. |
| `lib/core/network/api_client.dart` | Delegate to `ApiEnvelope`; swap interceptors. |
| `lib/core/config/api_endpoints.dart` | Rewrite against the real route inventory. |
| `lib/core/di/service_locator.dart` | Register `UsersApiService`. |

**Delete**
| File | Reason |
|---|---|
| `lib/core/network/interceptors/refresh_interceptor.dart` | Calls `/auth/session/refresh`, which does not exist. |

---

### Task 1: `ApiErrorCode` — the backend's error vocabulary

**Files:**
- Create: `lib/core/network/api_error_code.dart`
- Test: `test/core/network/api_error_code_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum ApiErrorCode` with `final String wire`, and `static ApiErrorCode fromWire(String? wire)` returning `ApiErrorCode.unknown` for null/unrecognised input.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/network/api_error_code_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';

void main() {
  group('ApiErrorCode.fromWire', () {
    test('maps every known backend code', () {
      expect(ApiErrorCode.fromWire('REG_FEE_REQUIRED'), ApiErrorCode.regFeeRequired);
      expect(ApiErrorCode.fromWire('PASSWORD_CHANGE_REQUIRED'), ApiErrorCode.passwordChangeRequired);
      expect(ApiErrorCode.fromWire('ACCOUNT_NOT_ACTIVE'), ApiErrorCode.accountNotActive);
      expect(ApiErrorCode.fromWire('UNAUTHORIZED'), ApiErrorCode.unauthorized);
      expect(ApiErrorCode.fromWire('VALIDATION_ERROR'), ApiErrorCode.validationError);
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/api_error_code_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:tbn_lms/core/network/api_error_code.dart'`

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/network/api_error_code.dart

/// The backend's `error.code` vocabulary.
///
/// Values are verbatim from `server/src/lib/response.ts` (the `ApiError`
/// factories) plus the custom codes raised in `middlewares/authenticate.ts`,
/// `middlewares/region.ts`, `app.ts` and `lib/auth.ts`.
///
/// [unknown] is deliberate: the backend gains codes without a client release,
/// and an unrecognised code must degrade rather than crash.
enum ApiErrorCode {
  badRequest('BAD_REQUEST'),
  validationError('VALIDATION_ERROR'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  notFound('NOT_FOUND'),
  conflict('CONFLICT'),
  unprocessable('UNPROCESSABLE'),
  rateLimited('RATE_LIMITED'),
  internal('INTERNAL'),
  serviceUnavailable('SERVICE_UNAVAILABLE'),

  /// Student has not cleared the registration-fee gate (`requireRegFeePaid`).
  regFeeRequired('REG_FEE_REQUIRED'),

  /// Account is on an administrator-set password; every non-GET is blocked.
  passwordChangeRequired('PASSWORD_CHANGE_REQUIRED'),

  /// Account suspended or pending activation.
  accountNotActive('ACCOUNT_NOT_ACTIVE'),

  corsForbidden('CORS_FORBIDDEN'),
  selfModification('SELF_MODIFICATION'),
  timeLimitExceeded('TIME_LIMIT_EXCEEDED'),
  monitoringDisabled('MONITORING_DISABLED'),

  /// Not in the envelope — Better Auth raises this on a weak password.
  weakPassword('WEAK_PASSWORD'),

  unknown('UNKNOWN');

  const ApiErrorCode(this.wire);

  /// The exact string the backend sends in `error.code`.
  final String wire;

  static ApiErrorCode fromWire(String? wire) {
    if (wire == null) return ApiErrorCode.unknown;
    for (final code in ApiErrorCode.values) {
      if (code.wire == wire) return code;
    }
    return ApiErrorCode.unknown;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/api_error_code_test.dart`
Expected: PASS — 4 tests

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/api_error_code.dart test/core/network/api_error_code_test.dart
git commit -m "feat(network): add ApiErrorCode for the backend error vocabulary"
```

---

### Task 2: `ApiException` carries the backend code

**Files:**
- Modify: `lib/core/network/api_exception.dart`
- Test: `test/core/network/api_exception_test.dart` (create)

**Interfaces:**
- Consumes: `ApiErrorCode` from Task 1.
- Produces: `ApiException` gains `final ApiErrorCode code` (defaults to `ApiErrorCode.unknown`) and convenience getters `isRegFeeRequired`, `isPasswordChangeRequired`, `isAccountNotActive`. The existing named constructors and `fromStatusCode` keep working unchanged. `props` includes `code`.

- [ ] **Step 1: Write the failing test**

```dart
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
      const a = ApiException(message: 'x', statusCode: 403, code: ApiErrorCode.regFeeRequired);
      const b = ApiException(message: 'x', statusCode: 403, code: ApiErrorCode.forbidden);
      expect(a, isNot(equals(b)));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/api_exception_test.dart`
Expected: FAIL — `No named parameter with the name 'code'`

- [ ] **Step 3: Write minimal implementation**

In `lib/core/network/api_exception.dart`, add the import, the field, the getters, and a `code` to each named constructor. Full replacement for the top of the class through `fromStatusCode`:

```dart
import 'package:equatable/equatable.dart';

import 'api_error_code.dart';

/// Tungabadra Networks LMS — Typed API Exceptions
///
/// Every network error is mapped to a typed exception.
/// UI displays user-friendly messages; logs contain technical details.
class ApiException extends Equatable implements Exception {
  final String message;
  final String? technicalMessage;
  final int? statusCode;
  final dynamic data;

  /// The backend's `error.code`. Drives routing decisions in Stage B —
  /// two 403s can mean very different things.
  final ApiErrorCode code;

  const ApiException({
    required this.message,
    this.technicalMessage,
    this.statusCode,
    this.data,
    this.code = ApiErrorCode.unknown,
  });

  // ── Named Constructors ──

  const ApiException.network()
      : message = 'No internet connection. Please check your network.',
        technicalMessage = 'NetworkException',
        statusCode = null,
        data = null,
        code = ApiErrorCode.unknown;

  const ApiException.timeout()
      : message = 'Request timed out. Please try again.',
        technicalMessage = 'TimeoutException',
        statusCode = null,
        data = null,
        code = ApiErrorCode.unknown;

  const ApiException.unauthorized()
      : message = 'Session expired. Please log in again.',
        technicalMessage = 'UnauthorizedException',
        statusCode = 401,
        data = null,
        code = ApiErrorCode.unauthorized;

  const ApiException.forbidden()
      : message = 'You don\'t have permission for this action.',
        technicalMessage = 'ForbiddenException',
        statusCode = 403,
        data = null,
        code = ApiErrorCode.forbidden;

  const ApiException.notFound()
      : message = 'The requested resource was not found.',
        technicalMessage = 'NotFoundException',
        statusCode = 404,
        data = null,
        code = ApiErrorCode.notFound;

  const ApiException.server()
      : message = 'Server error. Please try again later.',
        technicalMessage = 'InternalServerError',
        statusCode = 500,
        data = null,
        code = ApiErrorCode.internal;

  const ApiException.unknown()
      : message = 'Something went wrong. Please try again.',
        technicalMessage = 'UnknownException',
        statusCode = null,
        data = null,
        code = ApiErrorCode.unknown;
```

Then replace the tail of the class (from `bool get isUnauthorized` to the end):

```dart
  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork => technicalMessage == 'NetworkException';

  bool get isRegFeeRequired => code == ApiErrorCode.regFeeRequired;
  bool get isPasswordChangeRequired => code == ApiErrorCode.passwordChangeRequired;
  bool get isAccountNotActive => code == ApiErrorCode.accountNotActive;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() => 'ApiException(${code.wire} $statusCode: $message)';
}
```

Leave `fromStatusCode` exactly as it is — it is the fallback for responses with no envelope.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/api_exception_test.dart`
Expected: PASS — 4 tests

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/api_exception.dart test/core/network/api_exception_test.dart
git commit -m "feat(network): carry the backend error code on ApiException"
```

---

### Task 3: `ApiEnvelope` — unwrap success, type failure

**Files:**
- Create: `lib/core/network/api_envelope.dart`
- Test: `test/core/network/api_envelope_test.dart`

**Interfaces:**
- Consumes: `ApiErrorCode` (Task 1), `ApiException` (Task 2).
- Produces:
  - `dynamic ApiEnvelope.unwrap(dynamic body)` — returns `body['data']` when `body` is a `Map` containing both `success` and `data`; otherwise returns `body` unchanged.
  - `ApiException ApiEnvelope.toException(int statusCode, dynamic body)` — reads `body['error']['code']` / `['message']` when present; otherwise falls back to `ApiException.fromStatusCode`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/network/api_envelope_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/network/api_envelope.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';

void main() {
  group('ApiEnvelope.unwrap', () {
    test('unwraps a standard success envelope', () {
      final body = {'success': true, 'data': {'id': '1', 'name': 'Asha'}};
      expect(ApiEnvelope.unwrap(body), {'id': '1', 'name': 'Asha'});
    });

    test('unwraps a list payload', () {
      final body = {'success': true, 'data': [1, 2, 3]};
      expect(ApiEnvelope.unwrap(body), [1, 2, 3]);
    });

    test('unwraps a null data payload', () {
      final body = {'success': true, 'data': null};
      expect(ApiEnvelope.unwrap(body), isNull);
    });

    test('passes a Better Auth body through untouched', () {
      // /api/auth/* does not use the envelope. Unwrapping it would destroy it.
      final body = {'token': 'abc', 'user': {'id': '1'}};
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
        'error': {'code': 'REG_FEE_REQUIRED', 'message': 'Pay the registration fee first'},
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/api_envelope_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:tbn_lms/core/network/api_envelope.dart'`

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/network/api_envelope.dart
import 'api_error_code.dart';
import 'api_exception.dart';

/// Shapes the backend's response envelope.
///
/// Success: `{ "success": true, "data": … }`
/// Failure: `{ "success": false, "error": { "code", "message", "details"? } }`
/// — `server/src/lib/response.ts`
///
/// `/api/auth/*` is Better Auth and does NOT use this envelope, so both
/// helpers pass unrecognised bodies through untouched rather than assuming
/// a shape.
class ApiEnvelope {
  ApiEnvelope._();

  /// Returns the payload inside a success envelope, or [body] unchanged when
  /// it is not one.
  static dynamic unwrap(dynamic body) {
    if (body is Map && body.containsKey('success') && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Builds a typed exception from a failure envelope, falling back to plain
  /// status-code mapping when [body] is not one.
  static ApiException toException(int statusCode, dynamic body) {
    if (body is Map && body['error'] is Map) {
      final error = body['error'] as Map;
      final message = error['message']?.toString();
      return ApiException(
        message: message ?? _fallbackMessage(statusCode),
        technicalMessage: error['code']?.toString(),
        statusCode: statusCode,
        data: error['details'],
        code: ApiErrorCode.fromWire(error['code']?.toString()),
      );
    }
    return ApiException.fromStatusCode(statusCode);
  }

  static String _fallbackMessage(int statusCode) =>
      ApiException.fromStatusCode(statusCode).message;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/api_envelope_test.dart`
Expected: PASS — 12 tests

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/api_envelope.dart test/core/network/api_envelope_test.dart
git commit -m "feat(network): add ApiEnvelope to unwrap payloads and type failures"
```

---

### Task 4: Capture the bearer token from `set-auth-token`

**Files:**
- Create: `lib/core/network/interceptors/token_capture_interceptor.dart`
- Test: `test/core/network/token_capture_interceptor_test.dart`

**Interfaces:**
- Consumes: `SecureStorage`, `AppConstants.keySessionToken`.
- Produces: `class TokenCaptureInterceptor extends Interceptor` with constructor `TokenCaptureInterceptor({required SecureStorage secureStorage})`. Used by Task 5.

**Context:** Better Auth's `bearer()` plugin sets a `set-auth-token` response header on any response that issues a session (sign-in, sign-up). The value is the signed session cookie value and must be stored and replayed verbatim.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/network/token_capture_interceptor_test.dart
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
      _responseWith({'set-auth-token': ['signed.token.value']}),
      handler,
    );
    await Future<void>.delayed(Duration.zero);

    verify(() => storage.write(AppConstants.keySessionToken, 'signed.token.value')).called(1);
  });

  test('writes nothing when the header is absent', () async {
    final handler = ResponseInterceptorHandler();
    interceptor.onResponse(_responseWith({'content-type': ['application/json']}), handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => storage.write(any(), any()));
  });

  test('ignores an empty header value', () async {
    final handler = ResponseInterceptorHandler();
    interceptor.onResponse(_responseWith({'set-auth-token': ['']}), handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => storage.write(any(), any()));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/token_capture_interceptor_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../token_capture_interceptor.dart'`

- [ ] **Step 3: Write minimal implementation**

`unawaited` comes from `dart:async` — import it rather than declaring a local
helper, which would silently drop the write.

```dart
// lib/core/network/interceptors/token_capture_interceptor.dart
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
```

`unawaited` comes from `dart:async`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/token_capture_interceptor_test.dart`
Expected: PASS — 3 tests

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/interceptors/token_capture_interceptor.dart test/core/network/token_capture_interceptor_test.dart
git commit -m "feat(network): capture the bearer token from the set-auth-token header"
```

---

### Task 5: Wire `ApiClient` to the envelope; delete `RefreshInterceptor`

**Files:**
- Modify: `lib/core/network/api_client.dart`
- Delete: `lib/core/network/interceptors/refresh_interceptor.dart`
- Test: `test/core/network/api_client_test.dart`

**Interfaces:**
- Consumes: `ApiEnvelope` (Task 3), `TokenCaptureInterceptor` (Task 4).
- Produces: `ApiClient` unchanged in public shape — `get/post/put/patch/delete/upload/download`, `Dio get dio`, `updateBaseUrl(String)`. Behaviour changes: success payloads are unwrapped before `fromJson`; failures throw `ApiException` carrying `code`.

**Context:** `RefreshInterceptor` posts to `/auth/session/refresh`, which does not exist — Better Auth rolls sessions via `updateAge` (1 h) inside a 12 h `expiresIn`. Deleting it makes a 401 surface as `ApiException.unauthorized()`. **Acting on that (clearing the session, routing to login) is Stage B and is deliberately not done here.**

- [ ] **Step 1: Write the failing test**

```dart
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

ApiClient _clientServing(int status, Object? body, {Map<String, List<String>> headers = const {}}) {
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
    final client = _clientServing(200, {'token': 'abc', 'user': {'id': 'u1'}});

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
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
    );
  });

  test('a 401 surfaces as unauthorized rather than being retried away', () async {
    final client = _clientServing(401, {
      'success': false,
      'error': {'code': 'UNAUTHORIZED', 'message': 'Authentication required'},
    });

    await expectLater(
      client.get<dynamic>('/users/me'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.unauthorized)),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/network/api_client_test.dart`
Expected: FAIL — the first test fails because `fromJson` receives `{success: true, data: …}`, so `containsKey('success')` is `true`.

- [ ] **Step 3: Write minimal implementation**

Delete the dead interceptor:

```bash
git rm lib/core/network/interceptors/refresh_interceptor.dart
```

In `lib/core/network/api_client.dart`, replace the `refresh_interceptor` import with the token-capture one, and add the envelope import:

```dart
import 'api_envelope.dart';
import 'interceptors/token_capture_interceptor.dart';
```

Replace the interceptor chain (currently `_dio.interceptors.addAll([...])`) with:

```dart
    // ── Interceptor Chain ──
    // Connectivity → Auth → TokenCapture → Logging → [Request] → Retry
    //
    // RefreshInterceptor is deliberately absent: Better Auth exposes no
    // refresh endpoint. It rolls the session via `updateAge` inside
    // `expiresIn`, so a 401 means "sign in again", not "refresh".
    _dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo: networkInfo),
      AuthInterceptor(secureStorage: secureStorage),
      TokenCaptureInterceptor(secureStorage: secureStorage),
      if (kDebugMode) LoggingInterceptor(),
      RetryInterceptor(
        dio: _dio,
        maxRetries: _config.maxRetries,
        baseDelay: _config.retryDelay,
      ),
    ]);
```

Replace the body of `_request` with:

```dart
  Future<ApiResponse<T>> _request<T>(
    Future<Response> Function() request, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await request();
      final body = response.data;
      final payload = ApiEnvelope.unwrap(body);

      T? data;
      if (fromJson != null && payload != null) {
        data = fromJson(payload);
      } else if (payload is T) {
        data = payload;
      }

      // NOTE: the backend's `ok(res, data)` emits only `{success, data}` — it
      // never adds an envelope-level `pagination` key. Paged endpoints return
      // their own shape INSIDE `data`, and that shape is not uniform across
      // modules. Resolving it per endpoint is Stage D (spec §6.4); this read
      // stays as a no-op so the ApiResponse contract does not change under
      // callers mid-stage.
      PaginationMeta? pagination;
      if (body is Map<String, dynamic> && body['pagination'] is Map<String, dynamic>) {
        pagination = PaginationMeta.fromJson(body['pagination'] as Map<String, dynamic>);
      }

      return ApiResponse.success(
        data as T,
        statusCode: response.statusCode,
        pagination: pagination,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException.unknown();
    }
  }
```

Replace `_mapDioException`'s `badResponse` branch so it goes through the envelope:

```dart
  ApiException _mapDioException(DioException e) {
    // Already typed by the connectivity interceptor.
    if (e.error is ApiException) return e.error as ApiException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException.timeout();
      case DioExceptionType.connectionError:
        return const ApiException.network();
      case DioExceptionType.badResponse:
        return ApiEnvelope.toException(
          e.response?.statusCode ?? 0,
          e.response?.data,
        );
      default:
        return const ApiException.unknown();
    }
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/network/api_client_test.dart`
Expected: PASS — 5 tests

Then confirm nothing else referenced the deleted file:

Run: `flutter analyze --no-pub`
Expected: no new errors; the 3 pre-existing `prefer_const_declarations` infos remain.

- [ ] **Step 5: Commit**

```bash
git add -A lib/core/network test/core/network/api_client_test.dart
git commit -m "feat(network): unwrap the response envelope and drop RefreshInterceptor"
```

---

### Task 6: Rewrite `ApiEndpoints` against the real routes

**Files:**
- Modify: `lib/core/config/api_endpoints.dart` (full rewrite)
- Test: `test/core/config/api_endpoints_test.dart`

**Interfaces:**
- Produces: `ApiEndpoints` with the constants below and `static String withParams(String endpoint, Map<String, String> params)`.
- **Removed constants** — any caller referencing these will fail to compile, which is intended; Stage D fixes the call sites: `refreshSession`, `profile`, `updateProfile`, `uploadAvatar`, `studentDashboard`, `smrDashboard`, `adminDashboard`, `courses`, `courseDetail`, `courseLessons`, `lessonDetail`, `courseProgress`, `updateProgress`, `enrollments`, `myEnrollments`, `assignments`, `assignmentDetail`, `submitAssignment`, `attendance`, `myAttendance`, `markAttendance`, `orders`, `orderDetail`, `createOrder`, `verifyPayment`, `paymentHistory`, `certificates`, `certificateDetail`, `downloadCertificate`, `unreadNotifications`, `markAllRead`, `notificationCount`, `tickets`, `ticketDetail`, `createTicket`, `ticketMessages`, `sendMessage`, `leads`, `leadDetail`, `followUps`, `analyticsOverview`, `analyticsRevenue`, `analyticsStudents`, `uploadUrl`, `downloadUrl`.

**Note:** Stage A only changes this file. The API services that referenced the removed names will not compile until Stage D. Run `flutter analyze` after this task and record the resulting error list in the commit message — those errors are the Stage D worklist, not a regression.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/config/api_endpoints_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/config/api_endpoints.dart';

void main() {
  group('withParams', () {
    test('substitutes a single parameter', () {
      expect(
        ApiEndpoints.withParams(ApiEndpoints.batchDetail, {'id': 'b1'}),
        '/batches/b1',
      );
    });

    test('substitutes every occurrence of a parameter', () {
      expect(ApiEndpoints.withParams('/a/{id}/b/{id}', {'id': 'x'}), '/a/x/b/x');
    });

    test('leaves an unsupplied placeholder in place', () {
      // Loud failure at the HTTP layer beats a silently malformed URL.
      expect(ApiEndpoints.withParams('/a/{id}', const {}), '/a/{id}');
    });
  });

  group('endpoint hygiene', () {
    test('the routes v1 depends on are correct', () {
      expect(ApiEndpoints.serverHealth, '/health');
      expect(ApiEndpoints.signIn, '/auth/sign-in/email');
      expect(ApiEndpoints.me, '/users/me');
      expect(ApiEndpoints.studentDashboardV1, '/student/dashboard');
      expect(ApiEndpoints.notifications, '/notifications');
      expect(ApiEndpoints.unreadCount, '/notifications/unread-count');
      expect(ApiEndpoints.markAllNotificationsRead, '/notifications/read-all');
      expect(ApiEndpoints.staffRegistry, '/staff/registry');
    });

    test('no endpoint carries the /api prefix — the base URL already has it', () {
      for (final path in ApiEndpoints.all) {
        expect(path.startsWith('/api/'), isFalse, reason: '$path double-prefixes /api');
      }
    });

    test('every endpoint starts with a slash', () {
      for (final path in ApiEndpoints.all) {
        expect(path.startsWith('/'), isTrue, reason: '$path is not rooted');
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/config/api_endpoints_test.dart`
Expected: FAIL — `The getter 'me' isn't defined for the class 'ApiEndpoints'`

- [ ] **Step 3: Write minimal implementation**

Replace `lib/core/config/api_endpoints.dart` entirely:

```dart
/// Tungabadra Networks LMS — Centralized API Endpoint Constants
///
/// Every path is verified against the backend route inventory
/// (`lms-full-stack/server/src/app.ts` and each module's `*.routes.ts`).
/// Paths are relative to a base URL that already ends in `/api`, so none of
/// them carry that prefix.
///
/// Pattern: no magic strings scattered across the codebase.
class ApiEndpoints {
  ApiEndpoints._();

  // ══════════════════════════════════════════════
  // SYSTEM
  // ══════════════════════════════════════════════
  static const String serverHealth = '/health';

  // ══════════════════════════════════════════════
  // AUTH (Better Auth — no {success,data} envelope)
  // ══════════════════════════════════════════════
  static const String signIn = '/auth/sign-in/email';
  static const String signUp = '/auth/sign-up/email';
  static const String signOut = '/auth/sign-out';
  static const String session = '/auth/get-session';
  static const String changePassword = '/auth/change-password';

  /// Email-OTP plugin. Verification is required before a first sign-in.
  static const String sendVerificationOtp = '/auth/email-otp/send-verification-otp';
  static const String verifyEmailOtp = '/auth/email-otp/verify-email';
  static const String resetPasswordOtp = '/auth/email-otp/reset-password';

  // ══════════════════════════════════════════════
  // IDENTITY & CAPABILITIES
  // ══════════════════════════════════════════════

  /// `{ user, permissions[], modules{} }` — the single source of navigation.
  static const String me = '/users/me';

  /// Module + permission-key catalogue. Behind `requireStaff`.
  static const String staffRegistry = '/staff/registry';

  // ══════════════════════════════════════════════
  // STUDENT PORTAL
  // ══════════════════════════════════════════════
  static const String studentProfile = '/student/profile';
  static const String studentDashboardV1 = '/student/dashboard';
  static const String studentOverview = '/student/overview';
  static const String enrolledCourses = '/student/enrolled-courses';
  static const String studentCourseProgress = '/student/courses/{id}/progress';
  static const String purchases = '/student/purchases';
  static const String registrationStatus = '/student/registration/status';
  static const String registrationReceipt = '/student/registration/receipt';

  // ══════════════════════════════════════════════
  // LEARNING
  // ══════════════════════════════════════════════
  static const String courseContent = '/learning/courses/{id}/content';
  static const String fileDownload = '/learning/files/{id}/download';
  static const String assessments = '/learning/assessments';
  static const String startAssessment = '/learning/assessments/{id}/start';
  static const String assessmentResult = '/learning/assessments/{id}/result';
  static const String quizzes = '/learning/quizzes';
  static const String quizDetail = '/learning/quizzes/{id}';
  static const String quizResults = '/learning/quizzes/{id}/results';

  // ══════════════════════════════════════════════
  // BATCHES
  // ══════════════════════════════════════════════
  static const String myBatches = '/batches/mine';
  static const String myClasses = '/batches/my-classes';
  static const String availableBatches = '/batches/available';
  static const String batches = '/batches';
  static const String batchDetail = '/batches/{id}';
  static const String batchStats = '/batches/{id}/stats';
  static const String joinBatch = '/batches/{id}/join';

  // ══════════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════════
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // ══════════════════════════════════════════════
  // COMMERCE
  // ══════════════════════════════════════════════
  static const String cart = '/commerce/cart';
  static const String cartItems = '/commerce/cart/items';
  static const String quote = '/commerce/quote';
  static const String checkout = '/commerce/checkout';
  static const String checkoutStatus = '/commerce/checkout/status';
  static const String paymentOptions = '/commerce/payment-options';
  static const String commerceOrders = '/commerce/orders';
  static const String commerceOrderDetail = '/commerce/orders/{id}';

  // ══════════════════════════════════════════════
  // STAFF — STUDENTS
  // ══════════════════════════════════════════════
  static const String students = '/students';
  static const String studentDetail = '/students/{id}';
  static const String studentMaster = '/students/master';
  static const String studentRoster = '/students/roster';

  // ══════════════════════════════════════════════
  // STAFF — INSIGHTS
  // ══════════════════════════════════════════════
  static const String insightsDashboard = '/insights/dashboard';
  static const String analyticsCourses = '/insights/analytics/courses';
  static const String analyticsPayments = '/insights/analytics/payments';
  static const String analyticsCrm = '/insights/analytics/crm';
  static const String analyticsStudentCohorts = '/insights/analytics/batch-performance';

  // ══════════════════════════════════════════════
  // STAFF — CRM (v1.1)
  // ══════════════════════════════════════════════
  static const String leads = '/crm/leads';
  static const String leadDetail = '/crm/leads/{id}';
  static const String crmAnalytics = '/crm/analytics';

  // ══════════════════════════════════════════════
  // STAFF — FINANCE (v1.1)
  // ══════════════════════════════════════════════
  static const String financeOrders = '/finance/orders';
  static const String financeOrderDetail = '/finance/orders/{id}';
  static const String revenueReport = '/finance/reports/revenue';
  static const String invoicePdf = '/finance/invoices/{id}/pdf';

  /// Every declared endpoint, for hygiene tests.
  static const List<String> all = [
    serverHealth,
    signIn, signUp, signOut, session, changePassword,
    sendVerificationOtp, verifyEmailOtp, resetPasswordOtp,
    me, staffRegistry,
    studentProfile, studentDashboardV1, studentOverview, enrolledCourses,
    studentCourseProgress, purchases, registrationStatus, registrationReceipt,
    courseContent, fileDownload, assessments, startAssessment, assessmentResult,
    quizzes, quizDetail, quizResults,
    myBatches, myClasses, availableBatches, batches, batchDetail, batchStats, joinBatch,
    notifications, unreadCount, markNotificationRead, markAllNotificationsRead,
    cart, cartItems, quote, checkout, checkoutStatus, paymentOptions,
    commerceOrders, commerceOrderDetail,
    students, studentDetail, studentMaster, studentRoster,
    insightsDashboard, analyticsCourses, analyticsPayments, analyticsCrm,
    analyticsStudentCohorts,
    leads, leadDetail, crmAnalytics,
    financeOrders, financeOrderDetail, revenueReport, invoicePdf,
  ];

  /// Replaces `{name}` placeholders. An unsupplied placeholder is left intact
  /// so the failure is loud at the HTTP layer rather than a silently
  /// malformed URL.
  static String withParams(String endpoint, Map<String, String> params) {
    var result = endpoint;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/config/api_endpoints_test.dart`
Expected: PASS — 6 tests

Run: `flutter analyze --no-pub`
Expected: errors in the API service files that referenced removed constants. **This is expected.** Capture the list — it is the Stage D worklist.

- [ ] **Step 5: Commit**

```bash
git add lib/core/config/api_endpoints.dart test/core/config/api_endpoints_test.dart
git commit -m "feat(api): rewrite ApiEndpoints against the verified backend routes

Removed constants for routes that do not exist. Call sites in the feature
API services now fail to compile; fixing them is Stage D, tracked per module."
```

---

### Task 7: `MeDto` — the capability payload

**Files:**
- Create: `lib/features/auth/data/models/me_dto.dart`
- Test: `test/features/auth/me_dto_test.dart`

**Interfaces:**
- Produces:
  - `class MeDto` with `final MeUserDto user; final List<String> permissions; final Map<String, bool> modules;` and `factory MeDto.fromJson(Map<String, dynamic>)`.
  - `class MeUserDto` with `final String id, name, email; final bool emailVerified; final String? image; final String userType; final String status; final bool mustChangePassword;` and `factory MeUserDto.fromJson(Map<String, dynamic>)`.
- Consumed by Task 8 and by Stage B's `Capabilities`.

**Note:** hand-written, not `json_serializable`. The payload is small, and `modules` is a dynamic map whose keys are module names — generated code buys nothing here and adds a `build_runner` step.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/auth/me_dto_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/auth/data/models/me_dto.dart';

/// Shape recorded from `GET /api/users/me`
/// (`server/src/modules/users/users.routes.ts`).
const _staffPayload = {
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
  'permissions': ['students.account.view', 'batches.batch.view'],
  'modules': {'students': true, 'batches': true, 'crm': false},
};

void main() {
  test('parses a staff payload', () {
    final me = MeDto.fromJson(Map<String, dynamic>.from(_staffPayload));

    expect(me.user.id, 'usr_1');
    expect(me.user.name, 'Asha Rao');
    expect(me.user.userType, 'STAFF');
    expect(me.user.mustChangePassword, isFalse);
    expect(me.permissions, ['students.account.view', 'batches.batch.view']);
    expect(me.modules['crm'], isFalse);
  });

  test('parses a student payload with no permissions', () {
    final me = MeDto.fromJson({
      'user': {
        'id': 'usr_2',
        'name': 'Ravi K',
        'email': 'ravi@example.com',
        'emailVerified': true,
        'userType': 'STUDENT',
        'status': 'ACTIVE',
        'mustChangePassword': false,
      },
      'permissions': <dynamic>[],
      'modules': <String, dynamic>{},
    });

    expect(me.permissions, isEmpty);
    expect(me.user.userType, 'STUDENT');
    expect(me.user.image, isNull);
  });

  test('defaults mustChangePassword to false when the key is absent', () {
    final me = MeDto.fromJson({
      'user': {
        'id': 'usr_3',
        'name': 'X',
        'email': 'x@example.com',
        'emailVerified': true,
        'userType': 'SUPER_ADMIN',
        'status': 'ACTIVE',
      },
      'permissions': ['staff.user.view'],
      'modules': {'staff': true},
    });

    expect(me.user.mustChangePassword, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/me_dto_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../me_dto.dart'`

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/auth/data/models/me_dto.dart

/// `GET /api/users/me` — the identity plus the full authorization picture.
///
/// The backend's RBAC doc is explicit that the client derives ALL staff
/// navigation from this response and never from tier names, and that
/// permissions must not be cached across requests.
class MeDto {
  final MeUserDto user;

  /// Effective permission keys. Empty for students; every key for
  /// SUPER_ADMIN — the backend expands that server-side, so the client
  /// needs no special case.
  final List<String> permissions;

  /// Module key -> enabled. A missing key means enabled.
  final Map<String, bool> modules;

  const MeDto({
    required this.user,
    required this.permissions,
    required this.modules,
  });

  factory MeDto.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'] as Map? ?? const {};
    return MeDto(
      user: MeUserDto.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      permissions: (json['permissions'] as List? ?? const [])
          .map((p) => p.toString())
          .toList(growable: false),
      modules: {
        for (final entry in rawModules.entries)
          entry.key.toString(): entry.value == true,
      },
    );
  }
}

class MeUserDto {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String? image;

  /// `STUDENT` | `STAFF` | `SUPER_ADMIN`.
  final String userType;

  /// `ACTIVE` | `SUSPENDED` | …
  final String status;

  /// Account is on an administrator-set password; every non-GET is blocked
  /// until it is changed.
  final bool mustChangePassword;

  const MeUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.image,
    required this.userType,
    required this.status,
    required this.mustChangePassword,
  });

  factory MeUserDto.fromJson(Map<String, dynamic> json) => MeUserDto(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        emailVerified: json['emailVerified'] == true,
        image: json['image'] as String?,
        userType: json['userType'] as String,
        status: json['status'] as String,
        mustChangePassword: json['mustChangePassword'] == true,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/me_dto_test.dart`
Expected: PASS — 3 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/models/me_dto.dart test/features/auth/me_dto_test.dart
git commit -m "feat(auth): add MeDto for the /users/me capability payload"
```

---

### Task 8: `UsersApiService.fetchMe()` — Stage A acceptance

**Files:**
- Create: `lib/features/auth/data/services/users_api_service.dart`
- Modify: `lib/core/di/service_locator.dart`
- Test: `test/features/auth/users_api_service_test.dart`

**Interfaces:**
- Consumes: `ApiClient` (Task 5), `ApiEndpoints.me` (Task 6), `MeDto` (Task 7).
- Produces: `class UsersApiService` with constructor `UsersApiService({required ApiClient apiClient})` and `Future<ApiResponse<MeDto>> fetchMe()`.

**This task is the Stage A exit criterion:** an authenticated `GET /api/users/me` parses end-to-end through the real interceptor chain.

- [ ] **Step 1: Write the failing test**

```dart
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
    when(() => storage.read(AppConstants.keySessionToken))
        .thenAnswer((_) async => 'signed.session.token');

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
    when(() => storage.read(AppConstants.keySessionToken))
        .thenAnswer((_) async => null);

    final adapter = _RecordingAdapter(401, {
      'success': false,
      'error': {'code': 'UNAUTHORIZED', 'message': 'Authentication required'},
    });

    final service = UsersApiService(apiClient: buildClient(adapter));

    await expectLater(
      service.fetchMe(),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.unauthorized)),
    );
    // No token stored => no Authorization header sent.
    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/users_api_service_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../users_api_service.dart'`

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/auth/data/services/users_api_service.dart
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/me_dto.dart';

/// Identity and capabilities. One call, and it is the only thing the app
/// should ever consult to decide what a user may see.
class UsersApiService {
  final ApiClient _apiClient;

  UsersApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<MeDto>> fetchMe() {
    return _apiClient.get<MeDto>(
      ApiEndpoints.me,
      fromJson: (json) => MeDto.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
```

Register it in `lib/core/di/service_locator.dart`. Add the import beside the other auth imports:

```dart
import '../../features/auth/data/services/users_api_service.dart';
```

and register it in the `── Auth Module ──` block, immediately after `AuthApiService`:

```dart
  locator.registerLazySingleton<UsersApiService>(
    () => UsersApiService(apiClient: locator<ApiClient>()),
  );
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/users_api_service_test.dart`
Expected: PASS — 2 tests

Run the whole Stage A suite:

Run: `flutter test test/core/network test/core/config test/features/auth`
Expected: PASS — all tests from Tasks 1–8

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/services/users_api_service.dart lib/core/di/service_locator.dart test/features/auth/users_api_service_test.dart
git commit -m "feat(auth): add UsersApiService.fetchMe as the capability entry point"
```

---

## Stage A Exit Criteria

- [ ] `flutter test test/core/network test/core/config test/features/auth` passes.
- [ ] `GET /users/me` parses into `MeDto` through the real interceptor chain, with `Authorization: Bearer …` on the wire (Task 8, test 1).
- [ ] A 403 carrying `REG_FEE_REQUIRED` is distinguishable from a plain 403 (Task 5, test 3).
- [ ] Better Auth response bodies survive un-unwrapped (Task 5, test 2).
- [ ] `RefreshInterceptor` no longer exists in the tree.
- [ ] `flutter analyze` reports **only** the pre-existing 3 `prefer_const_declarations` infos plus the expected unresolved-constant errors from Task 6 — recorded as the Stage D worklist.

### Expected breakage — read before starting

Baseline before Stage A: `flutter test` is green, 9 tests.

From Task 6 onward the project **does not fully compile**, by design. Removing
endpoint constants for routes that never existed breaks every caller. Verified
list — these seven services reference removed constants:

```
lib/features/auth/data/services/auth_api_service.dart
lib/features/dashboard/data/services/dashboard_api_service.dart
lib/features/notifications/data/services/notifications_api_service.dart
lib/features/orders/data/services/orders_api_service.dart
lib/features/profile/data/services/profile_api_service.dart
lib/features/assessments/data/services/assessments_api_service.dart
lib/features/learning/data/services/certificates_api_service.dart
```

`lib/core/di/service_locator.dart` imports all of them, so it breaks
transitively — and so does `test/core/managers/session_manager_test.dart`,
which imports `service_locator.dart`. That test is expected to fail
compilation from Task 6 until Stage D.

**Unaffected, and must stay passing:**
- `test/widget_test.dart` — four real colour/theme tests importing only
  `app_colors.dart`. It is **not** a scaffold counter test. Do not delete it.
- `test/core/storage/cache_manager_test.dart`
- every test added by Stage A

This is why the Stage A test command names three directories rather than running
`flutter test` bare: those suites import only network, config and auth-model
code, none of which touches `service_locator.dart`.

Do not "fix" the broken services by inventing replacement endpoints — that is
precisely the failure this stage exists to undo. Do not delete tests to make the
suite green. The analyzer error list from Task 6 Step 4 is the Stage D worklist;
each module is repaired against recorded responses when its slice is wired.

## Handover to Stage B

Stage A deliberately stops at typed exceptions. Stage B consumes them:
`ApiErrorCode.unauthorized` → clear session and route to login;
`regFeeRequired` → registration screen; `passwordChangeRequired` → forced change;
a 404 on a gated route → drop the destination and re-fetch `/me`.
`MeDto` becomes the input to `Capabilities`.
