import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/profile_dto.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService({required ApiClient apiClient}) : _apiClient = apiClient;
  
  Future<ApiResponse<ProfileDto>> getProfile() async {
    return _apiClient.get<ProfileDto>(
      ApiEndpoints.profile,
      fromJson: (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileDto>> updateProfile(Map<String, dynamic> data) async {
    return _apiClient.post<ProfileDto>(
      ApiEndpoints.updateProfile,
      data: data,
      fromJson: (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileDto>> uploadAvatar(String path) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(path),
    });
    return _apiClient.upload<ProfileDto>(
      ApiEndpoints.uploadAvatar,
      formData: formData,
      fromJson: (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
