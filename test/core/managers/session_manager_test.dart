import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tbn_lms/core/config/app_constants.dart';
import 'package:tbn_lms/core/managers/session_manager.dart';
import 'package:tbn_lms/core/storage/preference_manager.dart';
import 'package:tbn_lms/core/storage/secure_storage.dart';
import 'package:tbn_lms/core/di/service_locator.dart';

// Mocks
class MockSecureStorage extends Mock implements SecureStorage {}
class MockPreferenceManager extends Mock implements PreferenceManager {}

void main() {
  late SessionManager sessionManager;
  late MockSecureStorage mockSecureStorage;
  late MockPreferenceManager mockPreferenceManager;

  setUp(() async {
    // Setup Mocktail and DI Locator
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
    test('init() should set isAuthenticated to false if no token exists', () async {
      // Arrange
      when(() => mockSecureStorage.read(AppConstants.keySessionToken))
          .thenAnswer((_) async => null);

      // Act
      await sessionManager.init();

      // Assert
      expect(sessionManager.isAuthenticated, false);
      expect(sessionManager.userId, null);
    });

    test('init() should set isAuthenticated to true and load preferences if token exists', () async {
      // Arrange
      when(() => mockSecureStorage.read(AppConstants.keySessionToken))
          .thenAnswer((_) async => 'valid_token_123');
      when(() => mockPreferenceManager.getString(AppConstants.keyUserId))
          .thenReturn('user_1');
      when(() => mockPreferenceManager.getString(AppConstants.keyUserName))
          .thenReturn('User One');
      when(() => mockPreferenceManager.getString(AppConstants.keyUserEmail))
          .thenReturn('user@test.com');
      when(() => mockPreferenceManager.getString(AppConstants.keyUserRole))
          .thenReturn(AppConstants.roleStudent);
      when(() => mockPreferenceManager.getString(AppConstants.keyUserAvatar))
          .thenReturn(null);

      // Act
      await sessionManager.init();

      // Assert
      expect(sessionManager.isAuthenticated, true);
      expect(sessionManager.userId, 'user_1');
      expect(sessionManager.isStudent, true);
      expect(sessionManager.isAdmin, false);
    });
  });

  group('SessionManager Auth Lifecycle', () {
    test('saveSession() should persist data and update state', () async {
      // Arrange
      when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) => Future<void>.value());
      when(() => mockPreferenceManager.setString(any(), any())).thenAnswer((_) async => true);

      // Act
      await sessionManager.saveSession(
        token: 'new_token',
        userId: 'admin_1',
        userName: 'Admin User',
        userEmail: 'admin@tbn.com',
        userRole: AppConstants.roleAdmin,
      );

      // Assert
      expect(sessionManager.isAuthenticated, true);
      expect(sessionManager.isAdmin, true);
      verify(() => mockSecureStorage.write(AppConstants.keySessionToken, 'new_token')).called(1);
      verify(() => mockPreferenceManager.setString(AppConstants.keyUserId, 'admin_1')).called(1);
    });

    test('clearSession() should delete all persisted data and reset state', () async {
      // Arrange
      when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) => Future<void>.value());
      when(() => mockSecureStorage.deleteAll()).thenAnswer((_) => Future<void>.value());
      when(() => mockPreferenceManager.remove(any())).thenAnswer((_) async => true);
      when(() => mockPreferenceManager.setString(any(), any())).thenAnswer((_) async => true);

      // Set initial state
      await sessionManager.saveSession(
        token: 'token',
        userId: 'u1',
        userName: 'n1',
        userEmail: 'e1',
        userRole: AppConstants.roleStudent,
      );

      // Act
      await sessionManager.clearSession();

      // Assert
      expect(sessionManager.isAuthenticated, false);
      expect(sessionManager.userId, null);
      verify(() => mockSecureStorage.deleteAll()).called(1);
      verify(() => mockPreferenceManager.remove(AppConstants.keyUserId)).called(1);
    });
  });
}
