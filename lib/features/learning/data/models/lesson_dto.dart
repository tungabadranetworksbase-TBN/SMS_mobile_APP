import 'package:json_annotation/json_annotation.dart';

part 'lesson_dto.g.dart';

@JsonSerializable()
class LessonDto {
  final String id;
  final String title;
  final String description;
  final String type; // 'video', 'pdf', 'quiz'
  final String? url;
  final int durationMinutes;
  final bool isCompleted;

  LessonDto({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    required this.durationMinutes,
    required this.isCompleted,
  });

  factory LessonDto.fromJson(Map<String, dynamic> json) =>
      _$LessonDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LessonDtoToJson(this);
}

@JsonSerializable()
class ModuleDto {
  final String id;
  final String title;
  final List<LessonDto> lessons;
  final bool isCompleted;

  ModuleDto({
    required this.id,
    required this.title,
    required this.lessons,
    required this.isCompleted,
  });

  factory ModuleDto.fromJson(Map<String, dynamic> json) =>
      _$ModuleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleDtoToJson(this);
}
