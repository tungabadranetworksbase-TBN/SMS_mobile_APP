import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../data/models/course_dto.dart';
import '../data/models/lesson_dto.dart';
import '../data/repositories/learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return locator<LearningRepository>();
});

// Provider for fetching all courses for a student
final studentCoursesProvider = FutureProvider.autoDispose<List<CourseDto>>((
  ref,
) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getStudentCourses();
});

// Family provider to fetch modules for a specific course
final courseModulesProvider = FutureProvider.family
    .autoDispose<List<ModuleDto>, String>((ref, courseId) async {
      final repo = ref.watch(learningRepositoryProvider);
      return repo.getCourseModules(courseId);
    });
