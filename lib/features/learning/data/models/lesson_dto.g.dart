// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonDto _$LessonDtoFromJson(Map<String, dynamic> json) => LessonDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: json['type'] as String,
  url: json['url'] as String?,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool,
);

Map<String, dynamic> _$LessonDtoToJson(LessonDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': instance.type,
  'url': instance.url,
  'durationMinutes': instance.durationMinutes,
  'isCompleted': instance.isCompleted,
};

ModuleDto _$ModuleDtoFromJson(Map<String, dynamic> json) => ModuleDto(
  id: json['id'] as String,
  title: json['title'] as String,
  lessons: (json['lessons'] as List<dynamic>)
      .map((e) => LessonDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCompleted: json['isCompleted'] as bool,
);

Map<String, dynamic> _$ModuleDtoToJson(ModuleDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'lessons': instance.lessons,
  'isCompleted': instance.isCompleted,
};
