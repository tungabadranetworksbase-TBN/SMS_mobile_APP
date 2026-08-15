import 'package:dio/dio.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/assessment_dto.dart';
import '../models/assignment_dto.dart';
import '../models/submission_dto.dart';

class AssessmentsApiService {
  final ApiClient _apiClient;

  AssessmentsApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<AssessmentDto>> getAssessment(String id) async {
    return _apiClient.get<AssessmentDto>(
      ApiEndpoints.withParams(ApiEndpoints.assessmentDetail, {'id': id}),
      fromJson: (json) => AssessmentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SubmissionDto>> submitAssessment(String id, Map<String, String> answers) async {
    return _apiClient.post<SubmissionDto>(
      ApiEndpoints.withParams(ApiEndpoints.submitAssessment, {'id': id}),
      data: {'answers': answers},
      fromJson: (json) => SubmissionDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AssignmentDto>> getAssignment(String id) async {
    return _apiClient.get<AssignmentDto>(
      ApiEndpoints.withParams(ApiEndpoints.assignmentDetail, {'id': id}),
      fromJson: (json) => AssignmentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<SubmissionDto>> submitAssignment(String id, String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    return _apiClient.upload<SubmissionDto>(
      ApiEndpoints.withParams(ApiEndpoints.submitAssignment, {'id': id}),
      formData: formData,
      fromJson: (json) => SubmissionDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
