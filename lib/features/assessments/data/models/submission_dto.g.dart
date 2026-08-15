// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionDto _$SubmissionDtoFromJson(Map<String, dynamic> json) =>
    SubmissionDto(
      id: json['id'] as String,
      entityId: json['entityId'] as String,
      type: json['type'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      score: (json['score'] as num?)?.toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SubmissionDtoToJson(SubmissionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityId': instance.entityId,
      'type': instance.type,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'score': instance.score,
      'status': instance.status,
    };
