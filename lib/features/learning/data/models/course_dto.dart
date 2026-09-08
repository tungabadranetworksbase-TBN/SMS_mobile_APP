import '../../../../core/network/json_value.dart';
import 'lesson_dto.dart';

class CourseDto {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String instructorName;
  final int totalLessons;
  final int completedLessons;
  final double progress;
  final List<ModuleDto> modules;

  CourseDto({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.instructorName,
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
    this.modules = const [],
  });

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    final educator = json['educator'];
    final modulesRaw = json['courseContent'] ?? json['modules'] ?? const [];
    final modules = jsonList(modulesRaw)
        .map((e) => ModuleDto.fromJson(jsonMap(e)))
        .toList();
    final fromTree = modules.fold<int>(0, (n, m) => n + m.lessons.length);
    final total = jsonInt(json['totalLectures'] ?? json['totalLessons'], fromTree);
    final completed = jsonInt(json['completedLectures'] ?? json['completedLessons']);
    return CourseDto(
      id: jsonStr(json['_id'] ?? json['id']),
      title: jsonStr(json['courseTitle'] ?? json['title']),
      description: jsonStr(
        json['courseDescription'] ?? json['courseSummary'] ?? json['description'],
      ),
      thumbnailUrl:
          json['courseThumbnail']?.toString() ?? json['thumbnailUrl']?.toString(),
      instructorName: educator is Map
          ? jsonStr(educator['name'], 'Instructor')
          : jsonStr(json['instructorName'] ?? educator, 'Instructor'),
      totalLessons: total,
      completedLessons: completed,
      progress: json['progress'] is num
          ? (json['progress'] as num).toDouble()
          : (total == 0 ? 0 : completed / total),
      modules: modules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'instructorName': instructorName,
    'totalLessons': totalLessons,
    'completedLessons': completedLessons,
    'progress': progress,
  };
}
