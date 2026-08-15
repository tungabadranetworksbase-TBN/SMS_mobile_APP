import 'package:json_annotation/json_annotation.dart';

part 'course_dto.g.dart';

@JsonSerializable()
class CourseDto {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String instructorName;
  final int totalLessons;
  final int completedLessons;
  final double progress; // 0.0 to 1.0

  CourseDto({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.instructorName,
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
  });

  factory CourseDto.fromJson(Map<String, dynamic> json) =>
      _$CourseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CourseDtoToJson(this);
}
