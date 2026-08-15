// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseDto _$CourseDtoFromJson(Map<String, dynamic> json) => CourseDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  instructorName: json['instructorName'] as String,
  totalLessons: (json['totalLessons'] as num).toInt(),
  completedLessons: (json['completedLessons'] as num).toInt(),
  progress: (json['progress'] as num).toDouble(),
);

Map<String, dynamic> _$CourseDtoToJson(CourseDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'thumbnailUrl': instance.thumbnailUrl,
  'instructorName': instance.instructorName,
  'totalLessons': instance.totalLessons,
  'completedLessons': instance.completedLessons,
  'progress': instance.progress,
};
