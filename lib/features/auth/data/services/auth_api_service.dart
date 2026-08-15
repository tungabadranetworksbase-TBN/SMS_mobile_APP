import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/login_request_dto.dart';
import '../models/signup_request_dto.dart';
import '../models/login_response_dto.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<LoginResponseDto>> login(LoginRequestDto req) async {
    return _apiClient.post<LoginResponseDto>(
      ApiEndpoints.signIn,
      data: req.toJson(),
      fromJson: (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<LoginResponseDto>> signUp(SignupRequestDto req) async {
    return _apiClient.post<LoginResponseDto>(
      ApiEndpoints.signUp,
      data: req.toJson(),
      fromJson: (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> logout() async {
    return _apiClient.post<void>(ApiEndpoints.signOut);
  }

  Future<ApiResponse<void>> checkServerHealth() async {
    return _apiClient.get<void>(ApiEndpoints.serverHealth);
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    return _apiClient.post<void>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<ApiResponse<void>> resetPassword(String email, String otp, String newPassword) async {
    return _apiClient.post<void>(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': newPassword,
      },
    );
  }
}
