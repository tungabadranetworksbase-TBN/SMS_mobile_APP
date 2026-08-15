import 'dart:async';

import 'package:logger/logger.dart';

import '../config/app_constants.dart';
import '../di/service_locator.dart';
import '../storage/secure_storage.dart';
import '../storage/preference_manager.dart';

/// Tungabadra Networks LMS — Session Manager
///
/// Manages the authenticated user session lifecycle.
/// Pattern: Zentriva's global isAuthenticated + SharedPreferences tokens,
/// refactored into a proper singleton with typed accessors.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SecureStorage get _secureStorage => locator<SecureStorage>();
  PreferenceManager get _preferenceManager => locator<PreferenceManager>();
  final Logger _logger = Logger();

  // ── In-memory cache ──
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userRole;
  String? _userAvatar;
  bool _isAuthenticated = false;

  // ── Stream for auth state changes ──
  StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  String? get userAvatar => _userAvatar;

  // Expose these for repositories that need them directly
  Future<String?> get token =>
      _secureStorage.read(AppConstants.keySessionToken);
  Future<String?> get refreshToken =>
      _secureStorage.read(AppConstants.keyRefreshToken);

  bool get isStudent => _userRole == AppConstants.roleStudent;
  bool get isSmr => _userRole == AppConstants.roleSmr;
  bool get isAdmin => _userRole == AppConstants.roleAdmin;
  bool get isSuperAdmin => _userRole == AppConstants.roleSuperAdmin;
  bool get hasAdminAccess => isAdmin || isSuperAdmin;
  bool get hasSmrAccess => isSmr || hasAdminAccess;

  /// Initialize session from persisted storage.
  /// Called at app startup.
  Future<void> init() async {
    try {
      final token = await _secureStorage.read(AppConstants.keySessionToken);

      if (token != null && token.isNotEmpty) {
        _userId = _preferenceManager.getString(AppConstants.keyUserId);
        _userName = _preferenceManager.getString(AppConstants.keyUserName);
        _userEmail = _preferenceManager.getString(AppConstants.keyUserEmail);
        _userRole = _preferenceManager.getString(AppConstants.keyUserRole);
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

  /// Save session after successful login.
  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
    String? userAvatar,
  }) async {
    await _secureStorage.write(AppConstants.keySessionToken, token);
    if (refreshToken != null) {
      await _secureStorage.write(AppConstants.keyRefreshToken, refreshToken);
    }

    await _preferenceManager.setString(AppConstants.keyUserId, userId);
    await _preferenceManager.setString(AppConstants.keyUserName, userName);
    await _preferenceManager.setString(AppConstants.keyUserEmail, userEmail);
    await _preferenceManager.setString(AppConstants.keyUserRole, userRole);
    if (userAvatar != null) {
      await _preferenceManager.setString(
        AppConstants.keyUserAvatar,
        userAvatar,
      );
    }

    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userRole = userRole;
    _userAvatar = userAvatar;
    _isAuthenticated = true;

    _authStateController.add(true);
    _logger.i('Session saved for user: $userName ($userRole)');
  }

  /// Clear session on logout.
  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    await _preferenceManager.remove(AppConstants.keyUserId);
    await _preferenceManager.remove(AppConstants.keyUserName);
    await _preferenceManager.remove(AppConstants.keyUserEmail);
    await _preferenceManager.remove(AppConstants.keyUserRole);
    await _preferenceManager.remove(AppConstants.keyUserAvatar);

    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    _userAvatar = null;
    _isAuthenticated = false;

    _authStateController.add(false);
    _logger.i('Session cleared');
  }

  /// Get the current session token.
  Future<String?> getToken() async {
    return _secureStorage.read(AppConstants.keySessionToken);
  }

  void dispose() {
    _authStateController.close();
  }

  /// For testing only
  void resetForTest() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    _userAvatar = null;
    _isAuthenticated = false;
    _authStateController = StreamController<bool>.broadcast();
  }
}
