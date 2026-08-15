import 'package:json_annotation/json_annotation.dart';

part 'submission_dto.g.dart';

@JsonSerializable()
class SubmissionDto {
  final String id;
  final String entityId; // Assessment ID or Assignment ID
  final String type; // 'ASSESSMENT', 'ASSIGNMENT'
  final DateTime submittedAt;
  final int? score;
  final String status; // 'PENDING', 'GRADED'

  SubmissionDto({
    required this.id,
    required this.entityId,
    required this.type,
    required this.submittedAt,
    this.score,
    required this.status,
  });

  factory SubmissionDto.fromJson(Map<String, dynamic> json) =>
      _$SubmissionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionDtoToJson(this);
}
