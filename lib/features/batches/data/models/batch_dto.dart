import '../../../../core/network/json_value.dart';

/// A batch as the `/batches/*` family returns it.
///
/// The field shape is the one already proven against the backend by
/// StaffBatchRowDto (dashboard/data/models/staff_lists_dto.dart) — same
/// entity, different projection. Nothing speculative is parsed here.
class BatchDto {
  final String id;
  final String name;
  final String courseTitle;
  final int memberCount;
  final String status;
  final String trainerName;

  const BatchDto({
    required this.id,
    required this.name,
    required this.courseTitle,
    required this.memberCount,
    required this.status,
    required this.trainerName,
  });

  factory BatchDto.fromJson(Map<String, dynamic> json) {
    final course = jsonMap(json['course']);
    final createdBy = jsonMap(json['createdBy']);
    final count = jsonMap(json['_count']);
    return BatchDto(
      id: jsonStr(json['id']),
      name: jsonStr(json['name']),
      courseTitle: jsonStr(course['title']),
      memberCount: jsonInt(count['members']),
      status: jsonStr(json['status']),
      trainerName: jsonStr(createdBy['name'], 'Staff'),
    );
  }

  /// Both a bare array and a `{batches: [...]}` envelope are accepted, matching
  /// how the learning and orders services read their list endpoints.
  static List<BatchDto> listFrom(dynamic json) {
    final raw = json is List ? json : jsonList(jsonMap(json)['batches']);
    return raw.map((e) => BatchDto.fromJson(jsonMap(e))).toList();
  }
}
