import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/unsupported_endpoint.dart';
import '../models/admin_dashboard_dto.dart';
import '../models/smr_dashboard_dto.dart';
import '../models/student_dashboard_dto.dart';

/// Tungabadra Networks LMS — Dashboard API Service
class DashboardApiService {
  final ApiClient _apiClient;

  DashboardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<StudentDashboardDto>> fetchStudentDashboard() async {
    return _apiClient.get<StudentDashboardDto>(
      ApiEndpoints.studentDashboardV1,
      fromJson: (json) =>
          StudentDashboardDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// No SMR dashboard exists server-side. "SMR" is not a backend concept — it
  /// is one of many runtime-created staff roles, so there is no single endpoint
  /// to serve it. Stage B composes this view from `/students` and `/batches`
  /// filtered by the caller's permissions.
  Future<ApiResponse<SmrDashboardDto>> fetchSmrDashboard() async {
    throw unsupportedEndpoint('SMR dashboard');
  }

  Future<ApiResponse<AdminDashboardDto>> fetchAdminDashboard() async {
    return _apiClient.get<AdminDashboardDto>(
      ApiEndpoints.insightsDashboard,
      fromJson: (json) =>
          AdminDashboardDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
