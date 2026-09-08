import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/json_value.dart';
import '../models/course_dto.dart';
import '../models/lesson_dto.dart';

class LearningApiService {
  final ApiClient _apiClient;

  LearningApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<CourseDto>>> fetchStudentCourses() async {
    return _apiClient.get<List<CourseDto>>(
      ApiEndpoints.enrolledCourses,
      fromJson: (json) {
        final raw = json is List
            ? json
            : jsonList(jsonMap(json)['enrolledCourses']);
        return raw.map((e) => CourseDto.fromJson(jsonMap(e))).toList();
      },
    );
  }

  Future<ApiResponse<List<ModuleDto>>> fetchCourseModules(
    String courseId,
  ) async {
    return _apiClient.get<List<ModuleDto>>(
      ApiEndpoints.withParams(ApiEndpoints.courseContent, {'id': courseId}),
      fromJson: (json) {
        final map = jsonMap(json);
        final content = jsonMap(map['content']);
        final raw =
            map['modules'] ??
            content['modules'] ??
            map['courseContent'] ??
            const [];
        return jsonList(
          raw,
        ).map((e) => ModuleDto.fromJson(jsonMap(e))).toList();
      },
    );
  }
}
