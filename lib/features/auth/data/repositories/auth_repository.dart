import '../../../../core/managers/session_manager.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request_dto.dart';
import '../models/signup_request_dto.dart';
import '../services/auth_api_service.dart';

/// Tungabadra Networks LMS — Auth Repository
///
/// Orchestrates API calls and local session management.
class AuthRepository {
  final AuthApiService _apiService;
  final SessionManager _sessionManager;

  AuthRepository({
    required AuthApiService apiService,
    required SessionManager sessionManager,
  }) : _apiService = apiService,
       _sessionManager = sessionManager;

  Future<void> login(String email, String password) async {
    try {
      final request = LoginRequestDto(email: email, password: password);
      final response = await _apiService.login(request);

      if (response.success && response.data != null) {
        final data = response.data!;

        // Save to secure storage and preferences via SessionManager
        await _sessionManager.saveSession(
          token: data.token,
          refreshToken: data.refreshToken,
          userId: data.user.id,
          userName: data.user.name,
          userEmail: data.user.email,
          userRole: data.user.role,
          userAvatar: data.user.avatar,
        );
      } else {
        throw ApiException(
          message: response.message ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      final request = SignupRequestDto(
        name: name,
        email: email,
        password: password,
      );
      final response = await _apiService.signUp(request);

      if (response.success && response.data != null) {
        final data = response.data!;

        // Save to secure storage and preferences via SessionManager
        await _sessionManager.saveSession(
          token: data.token,
          refreshToken: data.refreshToken,
          userId: data.user.id,
          userName: data.user.name,
          userEmail: data.user.email,
          userRole: data.user.role,
          userAvatar: data.user.avatar,
        );
      } else {
        throw ApiException(
          message: response.message ?? 'Sign up failed. Please try again.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Call API to invalidate session on server
      await _apiService.logout();
    } catch (e) {
      // Even if API call fails (e.g. offline), we still want to clear local session
    } finally {
      await _sessionManager.clearSession();
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await _apiService.checkServerHealth();
      return response.statusCode == 200 || response.success;
    } catch (e) {
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to send reset link.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.resetPassword(email, otp, newPassword);
      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to reset password.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
