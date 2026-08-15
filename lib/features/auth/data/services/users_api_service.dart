// lib/features/auth/data/services/users_api_service.dart
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/me_dto.dart';

/// Identity and capabilities. One call, and it is the only thing the app
/// should ever consult to decide what a user may see.
class UsersApiService {
  final ApiClient _apiClient;

  UsersApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<MeDto>> fetchMe() {
    return _apiClient.get<MeDto>(
      ApiEndpoints.me,
      fromJson: (json) =>
          MeDto.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
