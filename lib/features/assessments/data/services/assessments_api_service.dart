import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/unsupported_endpoint.dart';
import '../models/assessment_dto.dart';
import '../models/assignment_dto.dart';
import '../models/submission_dto.dart';

class AssessmentsApiService {
  final ApiClient _apiClient;

  AssessmentsApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Starting an assessment is what returns its questions — the backend has no
  /// plain GET for one (`learning.routes.ts`: `POST /assessments/:id/start`).
  Future<ApiResponse<AssessmentDto>> getAssessment(String id) async {
    return _apiClient.post<AssessmentDto>(
      ApiEndpoints.withParams(ApiEndpoints.startAssessment, {'id': id}),
      fromJson: (json) => AssessmentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Reads the graded result. The backend grades on `start` + answer capture and
  /// exposes only `GET /assessments/:id/result`; there is no submit route, so
  /// `answers` is not sent anywhere yet.
  Future<ApiResponse<SubmissionDto>> submitAssessment(
    String id,
    Map<String, String> answers,
  ) async {
    return _apiClient.get<SubmissionDto>(
      ApiEndpoints.withParams(ApiEndpoints.assessmentResult, {'id': id}),
      fromJson: (json) => SubmissionDto.fromJson(json as Map<String, dynamic>),
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
