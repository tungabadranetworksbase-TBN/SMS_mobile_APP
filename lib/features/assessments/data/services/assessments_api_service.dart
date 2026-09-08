import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/json_value.dart';
import '../../../../core/network/unsupported_endpoint.dart';
import '../models/assessment_dto.dart';
import '../models/assignment_dto.dart';
import '../models/submission_dto.dart';

class AssessmentsApiService {
  final ApiClient _apiClient;

  AssessmentsApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// `POST /learning/assessments/:id/start` returns questions (no answer key).
  Future<ApiResponse<AssessmentDto>> getAssessment(String id) {
    return _apiClient.post<AssessmentDto>(
      ApiEndpoints.withParams(ApiEndpoints.startAssessment, {'id': id}),
      fromJson: (json) => AssessmentDto.fromJson(jsonMap(json)),
    );
  }

  /// `POST /learning/assessments/:id/submit` with option-index answers.
  Future<ApiResponse<SubmissionDto>> submitAssessment(
    String id,
    Map<String, List<int>> answers,
  ) {
    return _apiClient.post<SubmissionDto>(
      ApiEndpoints.withParams(ApiEndpoints.submitAssessment, {'id': id}),
      data: {'answers': answers},
      fromJson: (json) => SubmissionDto.fromJson(jsonMap(json)),
    );
  }

  Future<ApiResponse<AssignmentDto>> getAssignment(String id) async {
    throw unsupportedEndpoint('Assignments');
  }

  Future<ApiResponse<SubmissionDto>> submitAssignment(
    String id,
    String filePath,
  ) async {
    throw unsupportedEndpoint('Assignments');
  }
}
