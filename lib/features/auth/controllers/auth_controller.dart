import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../data/repositories/auth_repository.dart';

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return locator<AuthRepository>();
});

/// Provider for the AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(repository: ref.watch(authRepositoryProvider));
});

/// Tungabadra Networks LMS — Auth Controller
///
/// Manages the UI state for authentication processes (loading, success, error).
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController({required AuthRepository repository})
      : _repository = repository,
        super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(email, password);
      state = const AsyncValue.data(null);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(name, email, password);
      state = const AsyncValue.data(null);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      // Even if it fails, we treat it as success locally as SessionManager clears it
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> checkServerHealth() async {
    return _repository.checkServerHealth();
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.forgotPassword(email);
      state = const AsyncValue.data(null);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetPassword(email, otp, newPassword);
      state = const AsyncValue.data(null);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncValue.error(const ApiException.unknown(), StackTrace.current);
      rethrow;
    }
  }
}
