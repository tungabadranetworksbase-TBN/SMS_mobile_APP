// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateDto _$CertificateDtoFromJson(Map<String, dynamic> json) =>
    CertificateDto(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String,
      issueDate: json['issueDate'] as String,
      downloadUrl: json['downloadUrl'] as String,
    );

Map<String, dynamic> _$CertificateDtoToJson(CertificateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'courseId': instance.courseId,
      'courseTitle': instance.courseTitle,
      'issueDate': instance.issueDate,
      'downloadUrl': instance.downloadUrl,
    };
