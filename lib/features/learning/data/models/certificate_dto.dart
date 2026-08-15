import 'package:json_annotation/json_annotation.dart';

part 'certificate_dto.g.dart';

@JsonSerializable()
class CertificateDto {
  final String id;
  final String studentId;
  final String courseId;
  final String courseTitle;
  final String issueDate;
  final String downloadUrl;

  CertificateDto({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseTitle,
    required this.issueDate,
    required this.downloadUrl,
  });

  factory CertificateDto.fromJson(Map<String, dynamic> json) =>
      _$CertificateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateDtoToJson(this);
}
