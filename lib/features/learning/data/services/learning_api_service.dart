import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/course_dto.dart';
import '../models/lesson_dto.dart';

/// Tungabadra Networks LMS — Learning API Service
class LearningApiService {
  final ApiClient _apiClient;

  LearningApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<CourseDto>>> fetchStudentCourses() async {
    // Note: Assuming endpoint /student/courses returns a list inside 'data'
    return _apiClient.get<List<CourseDto>>(
      '/student/courses', // Replace with ApiEndpoints.studentCourses when added
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => CourseDto.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<List<ModuleDto>>> fetchCourseModules(String courseId) async {
    return _apiClient.get<List<ModuleDto>>(
      '/student/courses/$courseId/modules', // Replace with ApiEndpoints.courseModules when added
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => ModuleDto.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }
}
