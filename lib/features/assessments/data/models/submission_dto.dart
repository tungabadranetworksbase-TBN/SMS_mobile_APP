import '../../../../core/network/json_value.dart';

class SubmissionDto {
  final String id;
  final String entityId;
  final String type;
  final DateTime submittedAt;
  final int? score;
  final int? maxScore;
  final bool? passed;
  final String status;

  const SubmissionDto({
    required this.id,
    required this.entityId,
    required this.type,
    required this.submittedAt,
    this.score,
    this.maxScore,
    this.passed,
    required this.status,
  });

  factory SubmissionDto.fromJson(Map<String, dynamic> json) {
    final submittedAt =
        jsonDate(json['submittedAt']) ?? DateTime.now().toUtc();
    final score = json['score'] == null ? null : jsonInt(json['score']);
    final graded = score != null || json['passed'] != null;
    return SubmissionDto(
      id: jsonStr(json['id']),
      entityId: jsonStr(json['entityId'] ?? json['quizId']),
      type: jsonStr(json['type'], 'ASSESSMENT'),
      submittedAt: submittedAt,
      score: score,
      maxScore: json['maxScore'] == null ? null : jsonInt(json['maxScore']),
      passed: json['passed'] as bool?,
      status: graded ? 'GRADED' : jsonStr(json['status'], 'PENDING'),
    );
  }
}
