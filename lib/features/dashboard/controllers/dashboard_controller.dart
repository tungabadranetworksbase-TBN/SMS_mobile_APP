import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../data/models/admin_dashboard_dto.dart';
import '../data/models/crm_insights_dto.dart';
import '../data/models/smr_dashboard_dto.dart';
import '../data/models/staff_lists_dto.dart';
import '../data/models/student_dashboard_dto.dart';
import '../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return locator<DashboardRepository>();
});

final studentDashboardProvider =
    AsyncNotifierProvider<StudentDashboardNotifier, StudentDashboardDto>(
      StudentDashboardNotifier.new,
    );

class StudentDashboardNotifier extends AsyncNotifier<StudentDashboardDto> {
  @override
  Future<StudentDashboardDto> build() async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return repo.getStudentDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final smrDashboardProvider =
    AsyncNotifierProvider<SmrDashboardNotifier, SmrDashboardDto>(
      SmrDashboardNotifier.new,
    );

class SmrDashboardNotifier extends AsyncNotifier<SmrDashboardDto> {
  @override
  Future<SmrDashboardDto> build() async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return repo.getSmrDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final adminDashboardProvider =
    AsyncNotifierProvider<AdminDashboardNotifier, AdminDashboardDto>(
      AdminDashboardNotifier.new,
    );

class AdminDashboardNotifier extends AsyncNotifier<AdminDashboardDto> {
  @override
  Future<AdminDashboardDto> build() async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return repo.getAdminDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final staffStudentsProvider =
    FutureProvider.autoDispose<List<StaffRosterRowDto>>((ref) {
      return ref.watch(dashboardRepositoryProvider).getStaffStudents();
    });

final staffBatchesProvider =
    FutureProvider.autoDispose<List<StaffBatchRowDto>>((ref) {
      return ref.watch(dashboardRepositoryProvider).getStaffBatches();
    });

final crmInsightsProvider = FutureProvider.autoDispose<CrmInsightsDto>((ref) {
  return ref.watch(dashboardRepositoryProvider).getCrmInsights();
});

