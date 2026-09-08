import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tbn_lms/core/config/app_constants.dart';
import 'package:tbn_lms/core/managers/session_manager.dart';
import 'package:tbn_lms/core/storage/preference_manager.dart';
import 'package:tbn_lms/core/storage/secure_storage.dart';
import 'package:tbn_lms/core/di/service_locator.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockPreferenceManager extends Mock implements PreferenceManager {}

void main() {
  late SessionManager sessionManager;
  late MockSecureStorage mockSecureStorage;
  late MockPreferenceManager mockPreferenceManager;

  setUp(() async {
    mockSecureStorage = MockSecureStorage();
    mockPreferenceManager = MockPreferenceManager();

    await locator.reset();
    locator.registerSingleton<SecureStorage>(mockSecureStorage);
    locator.registerSingleton<PreferenceManager>(mockPreferenceManager);

    sessionManager = SessionManager();
  });

  tearDown(() {
    sessionManager.dispose();
    sessionManager.resetForTest();
  });

  group('SessionManager Initialization', () {
    test(
      'init() should set isAuthenticated to false if no token exists',
      () async {
        when(
          () => mockSecureStorage.read(AppConstants.keySessionToken),
        ).thenAnswer((_) async => null);

        await sessionManager.init();

        expect(sessionManager.isAuthenticated, false);
        expect(sessionManager.userId, null);
      },
    );

    test(
      'init() should set isAuthenticated to true if token exists',
      () async {
        when(
          () => mockSecureStorage.read(AppConstants.keySessionToken),
        ).thenAnswer((_) async => 'valid_token_123');
        when(
          () => mockPreferenceManager.getString(AppConstants.keyUserId),
        ).thenReturn('user_1');
        when(
          () => mockPreferenceManager.getString(AppConstants.keyUserName),
        ).thenReturn('User One');
        when(
          () => mockPreferenceManager.getString(AppConstants.keyUserEmail),
        ).thenReturn('user@test.com');
        when(
          () => mockPreferenceManager.getString(AppConstants.keyUserAvatar),
        ).thenReturn(null);

        await sessionManager.init();

        expect(sessionManager.isAuthenticated, true);
        expect(sessionManager.userId, 'user_1');
      },
    );
  });

  group('SessionManager Auth Lifecycle', () {
    test('saveSession() should persist data and update state', () async {
      when(
        () => mockSecureStorage.write(any(), any()),
      ).thenAnswer((_) => Future<void>.value());
      when(
        () => mockPreferenceManager.setString(any(), any()),
      ).thenAnswer((_) async => true);

      await sessionManager.saveSession(
        token: 'new_token',
        userId: 'admin_1',
        userName: 'Admin User',
        userEmail: 'admin@tbn.com',
      );

      expect(sessionManager.isAuthenticated, true);
      verify(
        () => mockSecureStorage.write(
          AppConstants.keySessionToken,
          'new_token',
        ),
      ).called(1);
      verify(
        () => mockPreferenceManager.setString(
          AppConstants.keyUserId,
          'admin_1',
        ),
      ).called(1);
    });

    test(
      'clearSession() should delete all persisted data and reset state',
      () async {
        when(
          () => mockSecureStorage.write(any(), any()),
        ).thenAnswer((_) => Future<void>.value());
        when(
          () => mockSecureStorage.deleteAll(),
        ).thenAnswer((_) => Future<void>.value());
        when(
          () => mockPreferenceManager.remove(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockPreferenceManager.setString(any(), any()),
        ).thenAnswer((_) async => true);

        await sessionManager.saveSession(
          token: 'token',
          userId: 'u1',
          userName: 'n1',
          userEmail: 'e1',
        );

        await sessionManager.clearSession();

        expect(sessionManager.isAuthenticated, false);
        expect(sessionManager.userId, null);
        verify(() => mockSecureStorage.deleteAll()).called(1);
        verify(
          () => mockPreferenceManager.remove(AppConstants.keyUserId),
        ).called(1);
      },
    );
  });
}
