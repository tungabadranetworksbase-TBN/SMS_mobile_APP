import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/json_value.dart';
import '../models/admin_dashboard_dto.dart';
import '../models/crm_insights_dto.dart';
import '../models/staff_lists_dto.dart';
import '../models/student_dashboard_dto.dart';

/// Rows fetched per staff list request.
///
/// ponytail: single page, no infinite scroll. The screens say so when a
/// result fills it; wire page/cursor through if a roster outgrows one page
/// often enough that searching is not enough.
const int kStaffPageSize = 50;

class DashboardApiService {
  final ApiClient _apiClient;

  DashboardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<StudentDashboardDto>> fetchStudentDashboard() async {
    return _apiClient.get<StudentDashboardDto>(
      ApiEndpoints.studentDashboardV1,
      fromJson: (json) =>
          StudentDashboardDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<AdminDashboardDto>> fetchAdminDashboard() async {
    return _apiClient.get<AdminDashboardDto>(
      ApiEndpoints.insightsDashboard,
      fromJson: (json) => AdminDashboardDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<List<StaffRosterRowDto>>> fetchStaffStudents({
    String? search,
  }) async {
    return _apiClient.get<List<StaffRosterRowDto>>(
      ApiEndpoints.students,
      queryParameters: {
        'page': 1,
        'pageSize': kStaffPageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: (json) => jsonList(jsonMap(json)['students'])
          .map((e) => StaffRosterRowDto.fromJson(jsonMap(e)))
          .toList(),
    );
  }

  Future<ApiResponse<List<StaffBatchRowDto>>> fetchStaffBatches() async {
    return _apiClient.get<List<StaffBatchRowDto>>(
      ApiEndpoints.batches,
      queryParameters: {'page': 1, 'pageSize': kStaffPageSize},
      fromJson: (json) => jsonList(jsonMap(json)['batches'])
          .map((e) => StaffBatchRowDto.fromJson(jsonMap(e)))
          .toList(),
    );
  }

  Future<ApiResponse<CrmInsightsDto>> fetchCrmInsights() {
    return _apiClient.get<CrmInsightsDto>(
      ApiEndpoints.analyticsCrm,
      fromJson: (json) => CrmInsightsDto.fromJson(jsonMap(json)),
    );
  }
}
