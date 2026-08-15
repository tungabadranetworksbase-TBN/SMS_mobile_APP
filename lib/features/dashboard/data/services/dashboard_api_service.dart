import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/admin_dashboard_dto.dart';
import '../models/smr_dashboard_dto.dart';
import '../models/student_dashboard_dto.dart';

/// Tungabadra Networks LMS — Dashboard API Service
class DashboardApiService {
  final ApiClient _apiClient;

  DashboardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<StudentDashboardDto>> fetchStudentDashboard() async {
    return _apiClient.get<StudentDashboardDto>(
      ApiEndpoints.studentDashboard,
      fromJson: (json) => StudentDashboardDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SmrDashboardDto>> fetchSmrDashboard() async {
    return _apiClient.get<SmrDashboardDto>(
      ApiEndpoints.smrDashboard,
      fromJson: (json) => SmrDashboardDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AdminDashboardDto>> fetchAdminDashboard() async {
    return _apiClient.get<AdminDashboardDto>(
      ApiEndpoints.adminDashboard,
      fromJson: (json) => AdminDashboardDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
