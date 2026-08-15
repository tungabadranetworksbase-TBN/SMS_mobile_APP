// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDashboardDto _$StudentDashboardDtoFromJson(Map<String, dynamic> json) =>
    StudentDashboardDto(
      stats: DashboardStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      activeBatches: (json['activeBatches'] as List<dynamic>)
          .map((e) => StudentBatchDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingTasks: (json['upcomingTasks'] as List<dynamic>)
          .map((e) => UpcomingTaskDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentClassName: json['currentClassName'] as String,
    );

Map<String, dynamic> _$StudentDashboardDtoToJson(
  StudentDashboardDto instance,
) => <String, dynamic>{
  'stats': instance.stats,
  'activeBatches': instance.activeBatches,
  'upcomingTasks': instance.upcomingTasks,
  'currentClassName': instance.currentClassName,
};

DashboardStatsDto _$DashboardStatsDtoFromJson(Map<String, dynamic> json) =>
    DashboardStatsDto(
      attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
      pendingTasksCount: (json['pendingTasksCount'] as num).toInt(),
      lastClassDate: json['lastClassDate'] == null
          ? null
          : DateTime.parse(json['lastClassDate'] as String),
      activeCoursesCount: (json['activeCoursesCount'] as num).toInt(),
      classesAttendedCount: (json['classesAttendedCount'] as num).toInt(),
      tasksSubmittedCount: (json['tasksSubmittedCount'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsDtoToJson(DashboardStatsDto instance) =>
    <String, dynamic>{
      'attendancePercentage': instance.attendancePercentage,
      'pendingTasksCount': instance.pendingTasksCount,
      'lastClassDate': instance.lastClassDate?.toIso8601String(),
      'activeCoursesCount': instance.activeCoursesCount,
      'classesAttendedCount': instance.classesAttendedCount,
      'tasksSubmittedCount': instance.tasksSubmittedCount,
    };

StudentBatchDto _$StudentBatchDtoFromJson(Map<String, dynamic> json) =>
    StudentBatchDto(
      id: json['id'] as String,
      name: json['name'] as String,
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String,
      progress: (json['progress'] as num).toDouble(),
    );

Map<String, dynamic> _$StudentBatchDtoToJson(StudentBatchDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'courseId': instance.courseId,
      'courseTitle': instance.courseTitle,
      'progress': instance.progress,
    };

UpcomingTaskDto _$UpcomingTaskDtoFromJson(Map<String, dynamic> json) =>
    UpcomingTaskDto(
      id: json['id'] as String,
      title: json['title'] as String,
      courseName: json['courseName'] as String,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UpcomingTaskDtoToJson(UpcomingTaskDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'courseName': instance.courseName,
      'dueDate': instance.dueDate?.toIso8601String(),
      'status': _$TaskStatusEnumMap[instance.status]!,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.upcoming: 'upcoming',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.critical: 'critical',
};
