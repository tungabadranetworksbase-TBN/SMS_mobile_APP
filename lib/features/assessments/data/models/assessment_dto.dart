import 'package:json_annotation/json_annotation.dart';

part 'assessment_dto.g.dart';

@JsonSerializable()
class AssessmentDto {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final int totalMarks;
  final List<QuestionDto> questions;

  AssessmentDto({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.totalMarks,
    required this.questions,
  });

  factory AssessmentDto.fromJson(Map<String, dynamic> json) =>
      _$AssessmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentDtoToJson(this);
}

@JsonSerializable()
class QuestionDto {
  final String id;
  final String text;
  final String type; // 'MULTIPLE_CHOICE', 'TRUE_FALSE'
  final List<String> options;
  final String?
  correctAnswer; // Nullable if not sending to client until submission
  final int marks;

  QuestionDto({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer,
    required this.marks,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionDtoToJson(this);
}
