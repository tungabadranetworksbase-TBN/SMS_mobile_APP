import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/network/api_exception.dart';
import '../models/admin_dashboard_dto.dart';
import '../models/crm_insights_dto.dart';
import '../models/staff_lists_dto.dart';
import '../models/student_dashboard_dto.dart';
import '../services/dashboard_api_service.dart';

class DashboardRepository {
  final DashboardApiService _apiService;

  DashboardRepository({required DashboardApiService apiService})
    : _apiService = apiService;

  Future<StudentDashboardDto> getStudentDashboard() async {
    if (DemoMode().isActive) {
      return DemoData.studentDashboard;
    }
    try {
      final response = await _apiService.fetchStudentDashboard();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return StudentDashboardDto.empty();
    } catch (e) {
      rethrow;
    }
  }

  Future<AdminDashboardDto> getAdminDashboard() async {
    if (DemoMode().isActive) {
      return DemoData.adminDashboard;
    }
    try {
      final response = await _apiService.fetchAdminDashboard();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return AdminDashboardDto.empty();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StaffRosterRowDto>> getStaffStudents({String? search}) async {
    if (DemoMode().isActive) {
      return DemoData.staffStudents;
    }
    final response = await _apiService.fetchStaffStudents(search: search);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return const [];
  }

  Future<List<StaffBatchRowDto>> getStaffBatches() async {
    if (DemoMode().isActive) {
      return DemoData.staffBatches;
    }
    final response = await _apiService.fetchStaffBatches();
    if (response.success && response.data != null) {
      return response.data!;
    }
    return const [];
  }

  Future<CrmInsightsDto> getCrmInsights() async {
    if (DemoMode().isActive) {
      return const CrmInsightsDto(
        totalLeads: 12,
        convertedLeads: 3,
        conversionRatePct: 25,
        pipeline: {'NEW': 5, 'CONTACTED': 4, 'CONVERTED': 3},
        stuckRecords: 1,
        pendingFollowUps: 2,
        overdueFollowUps: 0,
      );
    }
    final response = await _apiService.fetchCrmInsights();
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw ApiException(message: response.message ?? 'Could not load analytics.');
  }
}
