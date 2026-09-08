import '../../../../core/auth/capabilities.dart';
import '../../../../core/auth/capabilities_store.dart';
import '../../../../core/auth/gate_store.dart';
import '../../../../core/config/client_origin.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/managers/session_manager.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request_dto.dart';
import '../models/registration_status_dto.dart';
import '../models/signup_request_dto.dart';
import '../services/auth_api_service.dart';
import '../services/registration_api_service.dart';
import '../services/users_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final UsersApiService _usersApi;
  final RegistrationApiService _registrationApi;
  final SessionManager _sessionManager;
  final CapabilitiesStore _capabilitiesStore;
  final GateStore _gateStore;

  AuthRepository({
    required AuthApiService apiService,
    required UsersApiService usersApi,
    required RegistrationApiService registrationApi,
    required SessionManager sessionManager,
    required CapabilitiesStore capabilitiesStore,
    required GateStore gateStore,
  }) : _apiService = apiService,
       _usersApi = usersApi,
       _registrationApi = registrationApi,
       _sessionManager = sessionManager,
       _capabilitiesStore = capabilitiesStore,
       _gateStore = gateStore;

  Future<void> login(String email, String password) async {
    if (DemoMode().isActive) {
      await _applyDemoSession();
      return;
    }
    try {
      final request = LoginRequestDto(email: email, password: password);
      final response = await _apiService.login(request);
      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Login failed. Please try again.',
        );
      }
      await _hydrateFromMe();
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
      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Sign up failed. Please try again.',
        );
      }
      // OTP is sent by the server; do not create a session until verified.
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerificationOtp(String email) async {
    final response = await _apiService.sendEmailVerificationOtp(email);
    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Could not send verification code.',
      );
    }
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    final response = await _apiService.verifyEmailOtp(email, otp);
    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Invalid or expired code.',
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Could not change password.',
      );
    }
    final caps = _capabilitiesStore.current;
    if (caps != null) {
      _capabilitiesStore.set(caps.copyWith(mustChangePassword: false));
    }
  }

  Future<RegistrationStatusDto> registrationStatus() async {
    var response = await _registrationApi.fetchStatus();
    if (!response.success || response.data == null) {
      response = await _registrationApi.fetchStatus();
    }
    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Could not load registration status.',
      );
    }
    if (response.data!.paid) {
      _gateStore.setRegFeeRequired(false);
    }
    return response.data!;
  }

  Future<void> submitRegistrationReceipt(String filePath) async {
    var response = await _registrationApi.submitReceiptImage(filePath);
    if (!response.success) {
      response = await _registrationApi.submitReceiptImage(filePath);
    }
    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Could not submit receipt.',
      );
    }
    // SUBMITTED still waits on staff — keep the registration gate.
  }

  Future<String?> startRegistrationCheckout() async {
    var response = await _registrationApi.startCheckout(clientOrigin());
    if (!response.success || response.data?.checkoutUrl == null) {
      try {
        await _registrationApi.reportAbandoned();
      } on ApiException {
        // Abandoned is best-effort so a second checkout can start.
      }
      response = await _registrationApi.startCheckout(clientOrigin());
    }
    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Could not start payment.',
      );
    }
    return response.data!.checkoutUrl;
  }

  Future<void> refreshCapabilities() async {
    if (DemoMode().isActive) {
      _capabilitiesStore.set(Capabilities.demo(DemoMode().selectedRole));
      return;
    }
    await _hydrateFromMe(persistSession: false);
  }

  Future<void> _hydrateFromMe({bool persistSession = true}) async {
    final meResponse = await _usersApi.fetchMe();
    if (!meResponse.success || meResponse.data == null) {
      throw ApiException(
        message: meResponse.message ?? 'Could not load account.',
      );
    }
    final me = meResponse.data!;
    final caps = Capabilities.fromMe(me);
    _capabilitiesStore.set(caps);
    if (!persistSession) return;

    final token = await _sessionManager.token;
    await _sessionManager.saveSession(
      token: token ?? '',
      userId: me.user.id,
      userName: me.user.name,
      userEmail: me.user.email,
      userAvatar: me.user.image,
    );
  }

  Future<void> _applyDemoSession() async {
    _capabilitiesStore.set(Capabilities.demo(DemoMode().selectedRole));
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Clear local session even if the server call fails.
    } finally {
      _capabilitiesStore.clear();
      _gateStore.clear();
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
