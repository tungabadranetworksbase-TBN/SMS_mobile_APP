// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentDto _$AssessmentDtoFromJson(Map<String, dynamic> json) =>
    AssessmentDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      totalMarks: (json['totalMarks'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssessmentDtoToJson(AssessmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'totalMarks': instance.totalMarks,
      'questions': instance.questions,
    };

QuestionDto _$QuestionDtoFromJson(Map<String, dynamic> json) => QuestionDto(
  id: json['id'] as String,
  text: json['text'] as String,
  type: json['type'] as String,
  options:
      (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  correctAnswer: json['correctAnswer'] as String?,
  marks: (json['marks'] as num).toInt(),
);

Map<String, dynamic> _$QuestionDtoToJson(QuestionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'type': instance.type,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'marks': instance.marks,
    };
