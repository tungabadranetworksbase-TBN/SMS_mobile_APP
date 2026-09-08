import '../../../../core/config/api_endpoints.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/managers/offline_sync_manager.dart';
import '../../../../core/network/api_exception.dart';
import '../models/assessment_dto.dart';
import '../models/assignment_dto.dart';
import '../models/submission_dto.dart';
import '../services/assessments_api_service.dart';

class AssessmentsRepository {
  final AssessmentsApiService _apiService;
  final OfflineSyncManager _offlineSyncManager;

  AssessmentsRepository({
    required AssessmentsApiService apiService,
    required OfflineSyncManager offlineSyncManager,
  }) : _apiService = apiService,
       _offlineSyncManager = offlineSyncManager;

  Future<AssessmentDto> getAssessment(String id) async {
    if (DemoMode().isActive) {
      return DemoData.getAssessment(id);
    }
    final response = await _apiService.getAssessment(id);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw ApiException(
      message: response.message ?? 'Failed to load assessment',
    );
  }

  Future<SubmissionDto?> submitAssessment(
    String id,
    Map<String, List<int>> answers,
  ) async {
    if (DemoMode().isActive) {
      return DemoData.getSubmission(id, 'ASSESSMENT');
    }
    try {
      final response = await _apiService.submitAssessment(id, answers);
      if (response.success) {
        return response.data;
      }
      throw ApiException(message: response.message ?? 'Submission failed');
    } on ApiException catch (e) {
      if (e.isNetwork || e.technicalMessage == 'TimeoutException') {
        await _offlineSyncManager.queueAction(
          // Replay sends these verbatim, so the path and body must match
          // exactly what AssessmentsApiService.submitAssessment would send.
          endpoint: ApiEndpoints.withParams(ApiEndpoints.submitAssessment, {
            'id': id,
          }),
          method: 'POST',
          payload: {'answers': answers},
        );
        return null;
      }
      rethrow;
    }
  }

  Future<AssignmentDto> getAssignment(String id) async {
    if (DemoMode().isActive) {
      return DemoData.getAssignment(id);
    }
    try {
      final response = await _apiService.getAssignment(id);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(
        message: response.message ?? 'Failed to load assessment',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmissionDto> submitAssignment(String id, String filePath) async {
    if (DemoMode().isActive) {
      return DemoData.getSubmission(id, 'ASSIGNMENT');
    }
    try {
      final response = await _apiService.submitAssignment(id, filePath);
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw ApiException(
        message: response.message ?? 'Failed to submit assignment',
      );
    } catch (e) {
      rethrow;
    }
  }
}
