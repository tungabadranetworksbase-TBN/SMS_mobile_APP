// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignmentDto _$AssignmentDtoFromJson(Map<String, dynamic> json) =>
    AssignmentDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      totalMarks: (json['totalMarks'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
    );

Map<String, dynamic> _$AssignmentDtoToJson(AssignmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'dueDate': instance.dueDate.toIso8601String(),
      'totalMarks': instance.totalMarks,
      'fileUrl': instance.fileUrl,
    };
