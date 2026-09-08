import '../../../../core/network/json_value.dart';

class StudentDashboardDto {
  final DashboardStatsDto stats;
  final List<DashboardCourseDto> courses;
  final DashboardCourseDto? continueLearning;

  StudentDashboardDto({
    required this.stats,
    required this.courses,
    this.continueLearning,
  });

  factory StudentDashboardDto.fromJson(Map<String, dynamic> json) {
    return StudentDashboardDto(
      stats: DashboardStatsDto.fromJson(jsonMap(json['stats'])),
      courses: jsonList(json['courses'])
          .map((e) => DashboardCourseDto.fromJson(jsonMap(e)))
          .toList(),
      continueLearning: json['continueLearning'] == null
          ? null
          : DashboardCourseDto.fromJson(jsonMap(json['continueLearning'])),
    );
  }

  factory StudentDashboardDto.empty() {
    return StudentDashboardDto(
      stats: DashboardStatsDto.empty(),
      courses: const [],
    );
  }
}

class DashboardStatsDto {
  final int enrolledCourses;
  final int completedLectures;
  final int purchases;

  DashboardStatsDto({
    required this.enrolledCourses,
    required this.completedLectures,
    required this.purchases,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    return DashboardStatsDto(
      enrolledCourses: jsonInt(json['enrolledCourses']),
      completedLectures: jsonInt(json['completedLectures']),
      purchases: jsonInt(json['purchases']),
    );
  }

  factory DashboardStatsDto.empty() => DashboardStatsDto(
    enrolledCourses: 0,
    completedLectures: 0,
    purchases: 0,
  );
}

class DashboardCourseDto {
  final String id;
  final String courseTitle;
  final String? courseThumbnail;
  final String educatorName;
  final int completedLectures;
  final int totalLectures;

  DashboardCourseDto({
    required this.id,
    required this.courseTitle,
    this.courseThumbnail,
    required this.educatorName,
    required this.completedLectures,
    required this.totalLectures,
  });

  double get progress =>
      totalLectures == 0 ? 0 : completedLectures / totalLectures;

  factory DashboardCourseDto.fromJson(Map<String, dynamic> json) {
    final educator = json['educator'];
    return DashboardCourseDto(
      id: jsonStr(json['_id'] ?? json['id']),
      courseTitle: jsonStr(json['courseTitle'] ?? json['title']),
      courseThumbnail: json['courseThumbnail']?.toString() ??
          json['thumbnailUrl']?.toString(),
      educatorName: educator is Map
          ? jsonStr(educator['name'], 'Instructor')
          : jsonStr(educator, 'Instructor'),
      completedLectures: jsonInt(json['completedLectures']),
      totalLectures: jsonInt(json['totalLectures']),
    );
  }
}
