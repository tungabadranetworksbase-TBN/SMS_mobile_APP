import 'dart:async';

import 'package:logger/logger.dart';

import '../config/app_constants.dart';
import '../di/service_locator.dart';
import '../storage/secure_storage.dart';
import '../storage/preference_manager.dart';

/// Authenticated session identity. Authorization lives in CapabilitiesStore.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SecureStorage get _secureStorage => locator<SecureStorage>();
  PreferenceManager get _preferenceManager => locator<PreferenceManager>();
  final Logger _logger = Logger();

  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;
  bool _isAuthenticated = false;

  StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userAvatar => _userAvatar;

  Future<String?> get token =>
      _secureStorage.read(AppConstants.keySessionToken);
  Future<String?> get refreshToken =>
      _secureStorage.read(AppConstants.keyRefreshToken);

  Future<void> init() async {
    try {
      final token = await _secureStorage.read(AppConstants.keySessionToken);

      if (token != null && token.isNotEmpty) {
        _userId = _preferenceManager.getString(AppConstants.keyUserId);
        _userName = _preferenceManager.getString(AppConstants.keyUserName);
        _userEmail = _preferenceManager.getString(AppConstants.keyUserEmail);
        _userAvatar = _preferenceManager.getString(AppConstants.keyUserAvatar);
        _isAuthenticated = true;
      }

      _authStateController.add(_isAuthenticated);
    } catch (e) {
      _logger.e('Session init failed: $e');
      _isAuthenticated = false;
      _authStateController.add(false);
    }
  }

  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatar,
  }) async {
    await _secureStorage.write(AppConstants.keySessionToken, token);
    if (refreshToken != null) {
      await _secureStorage.write(AppConstants.keyRefreshToken, refreshToken);
    }

    await _preferenceManager.setString(AppConstants.keyUserId, userId);
    await _preferenceManager.setString(AppConstants.keyUserName, userName);
    await _preferenceManager.setString(AppConstants.keyUserEmail, userEmail);
    if (userAvatar != null) {
      await _preferenceManager.setString(
        AppConstants.keyUserAvatar,
        userAvatar,
      );
    }

    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userAvatar = userAvatar;
    _isAuthenticated = true;

    _authStateController.add(true);
    _logger.i('Session saved for user: $userName');
  }

  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    await _preferenceManager.remove(AppConstants.keyUserId);
    await _preferenceManager.remove(AppConstants.keyUserName);
    await _preferenceManager.remove(AppConstants.keyUserEmail);
    await _preferenceManager.remove(AppConstants.keyUserAvatar);
    await _preferenceManager.remove(AppConstants.keyDemoRole);

    _userId = null;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    _isAuthenticated = false;

    _authStateController.add(false);
    _logger.i('Session cleared');
  }

  Future<String?> getToken() async {
    return _secureStorage.read(AppConstants.keySessionToken);
  }

  void dispose() {
    _authStateController.close();
  }

  void resetForTest() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    _isAuthenticated = false;
    _authStateController = StreamController<bool>.broadcast();
  }
}
