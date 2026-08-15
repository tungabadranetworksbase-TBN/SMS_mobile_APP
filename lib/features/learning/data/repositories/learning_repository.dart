import 'dart:convert';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/storage/cache_manager.dart';
import '../models/course_dto.dart';
import '../models/lesson_dto.dart';
import '../services/learning_api_service.dart';

/// Tungabadra Networks LMS — Learning Repository
class LearningRepository {
  final LearningApiService _apiService;
  final CacheManager _cacheManager;

  LearningRepository({
    required LearningApiService apiService,
    required CacheManager cacheManager,
  }) : _apiService = apiService,
       _cacheManager = cacheManager;

  Future<List<CourseDto>> getStudentCourses() async {
    if (DemoMode().isActive) {
      return DemoData.studentCourses;
    }
    const cacheKey = 'student_courses';

    // 1. Try to fetch from API
    try {
      final response = await _apiService.fetchStudentCourses();
      if (response.success && response.data != null) {
        final courses = response.data!;
        // Cache the raw JSON data
        final jsonList = courses.map((c) => c.toJson()).toList();
        await _cacheManager.writeCache(cacheKey, jsonEncode(jsonList));
        return courses;
      }
    } catch (e) {
      // API Failed. Fall through to cache.
    }

    // 2. Fallback to Cache
    final cachedData = _cacheManager.readCache(cacheKey);
    if (cachedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData as String);
        return decoded
            .map((e) => CourseDto.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Cache is corrupted
      }
    }

    return [];
  }

  Future<List<ModuleDto>> getCourseModules(String courseId) async {
    if (DemoMode().isActive) {
      return DemoData.getCourseModules(courseId);
    }
    try {
      final response = await _apiService.fetchCourseModules(courseId);
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
