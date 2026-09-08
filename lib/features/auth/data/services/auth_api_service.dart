import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/login_request_dto.dart';
import '../models/signup_request_dto.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<void>> login(LoginRequestDto req) async {
    return _apiClient.post<void>(ApiEndpoints.signIn, data: req.toJson());
  }

  Future<ApiResponse<void>> signUp(SignupRequestDto req) async {
    return _apiClient.post<void>(ApiEndpoints.signUp, data: req.toJson());
  }

  Future<ApiResponse<void>> logout() async {
    return _apiClient.post<void>(ApiEndpoints.signOut);
  }

  Future<ApiResponse<void>> checkServerHealth() async {
    return _apiClient.get<void>(ApiEndpoints.serverHealth);
  }

  Future<ApiResponse<void>> sendEmailVerificationOtp(String email) async {
    return _apiClient.post<void>(
      ApiEndpoints.sendVerificationOtp,
      data: {'email': email, 'type': 'email-verification'},
    );
  }

  Future<ApiResponse<void>> verifyEmailOtp(String email, String otp) async {
    return _apiClient.post<void>(
      ApiEndpoints.verifyEmailOtp,
      data: {'email': email, 'otp': otp},
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _apiClient.post<void>(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    return _apiClient.post<void>(
      ApiEndpoints.sendVerificationOtp,
      data: {'email': email, 'type': 'forget-password'},
    );
  }

  Future<ApiResponse<void>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    return _apiClient.post<void>(
      ApiEndpoints.resetPasswordOtp,
      data: {'email': email, 'otp': otp, 'password': newPassword},
    );
  }
}
