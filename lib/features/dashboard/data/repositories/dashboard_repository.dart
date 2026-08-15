import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../models/admin_dashboard_dto.dart';
import '../models/smr_dashboard_dto.dart';
import '../models/student_dashboard_dto.dart';
import '../services/dashboard_api_service.dart';

/// Tungabadra Networks LMS — Dashboard Repository
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
      // Offline fallback can be implemented here via CacheManager later
      rethrow;
    }
  }

  Future<SmrDashboardDto> getSmrDashboard() async {
    if (DemoMode().isActive) {
      return DemoData.smrDashboard;
    }
    try {
      final response = await _apiService.fetchSmrDashboard();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return SmrDashboardDto.empty();
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
}

