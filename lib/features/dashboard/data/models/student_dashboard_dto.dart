import 'package:json_annotation/json_annotation.dart';

part 'student_dashboard_dto.g.dart';

@JsonSerializable()
class StudentDashboardDto {
  final DashboardStatsDto stats;
  final List<StudentBatchDto> activeBatches;
  final List<UpcomingTaskDto> upcomingTasks;
  final String currentClassName;

  StudentDashboardDto({
    required this.stats,
    required this.activeBatches,
    required this.upcomingTasks,
    required this.currentClassName,
  });

  factory StudentDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$StudentDashboardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentDashboardDtoToJson(this);

  factory StudentDashboardDto.empty() {
    return StudentDashboardDto(
      stats: DashboardStatsDto.empty(),
      activeBatches: [],
      upcomingTasks: [],
      currentClassName: 'No active class',
    );
  }
}

@JsonSerializable()
class DashboardStatsDto {
  final double attendancePercentage;
  final int pendingTasksCount;
  final DateTime? lastClassDate;
  final int activeCoursesCount;
  final int classesAttendedCount;
  final int tasksSubmittedCount;

  DashboardStatsDto({
    required this.attendancePercentage,
    required this.pendingTasksCount,
    this.lastClassDate,
    required this.activeCoursesCount,
    required this.classesAttendedCount,
    required this.tasksSubmittedCount,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsDtoToJson(this);

  factory DashboardStatsDto.empty() {
    return DashboardStatsDto(
      attendancePercentage: 0.0,
      pendingTasksCount: 0,
      lastClassDate: null,
      activeCoursesCount: 0,
      classesAttendedCount: 0,
      tasksSubmittedCount: 0,
    );
  }
}

@JsonSerializable()
class StudentBatchDto {
  final String id;
  final String name;
  final String courseId;
  final String courseTitle;
  final double progress;

  StudentBatchDto({
    required this.id,
    required this.name,
    required this.courseId,
    required this.courseTitle,
    required this.progress,
  });

  factory StudentBatchDto.fromJson(Map<String, dynamic> json) =>
      _$StudentBatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentBatchDtoToJson(this);
}

@JsonSerializable()
class UpcomingTaskDto {
  final String id;
  final String title;
  final String courseName;
  final DateTime? dueDate;
  final TaskStatus status;

  UpcomingTaskDto({
    required this.id,
    required this.title,
    required this.courseName,
    this.dueDate,
    required this.status,
  });

  factory UpcomingTaskDto.fromJson(Map<String, dynamic> json) =>
      _$UpcomingTaskDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpcomingTaskDtoToJson(this);
}

enum TaskStatus { upcoming, inProgress, critical }
