import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/unsupported_endpoint.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/profile_dto.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<ProfileDto>> getProfile() async {
    return _apiClient.get<ProfileDto>(
      ApiEndpoints.studentProfile,
      fromJson: (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// PATCH, not POST — `student.routes.ts` mounts this as a partial update.
  Future<ApiResponse<ProfileDto>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return _apiClient.patch<ProfileDto>(
      ApiEndpoints.studentProfile,
      data: data,
      fromJson: (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileDto>> uploadAvatar(String path) async {
    throw unsupportedEndpoint('Avatar upload');
  }
}
