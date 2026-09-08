import '../../../../core/network/json_value.dart';

class StaffRosterRowDto {
  final String id;
  final String name;
  final String email;
  final String status;
  final String? course;
  final String? batchLabel;

  StaffRosterRowDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.course,
    this.batchLabel,
  });

  factory StaffRosterRowDto.fromJson(Map<String, dynamic> json) {
    final account = jsonMap(json['account']);
    return StaffRosterRowDto(
      id: jsonStr(json['id']),
      name: jsonStr(json['name']),
      email: jsonStr(json['email']),
      status: jsonStr(account['status'] ?? json['status'], 'ACTIVE'),
      course: json['course']?.toString(),
      batchLabel: json['batchLabel']?.toString(),
    );
  }
}

class StaffBatchRowDto {
  final String id;
  final String name;
  final String courseTitle;
  final int memberCount;
  final String status;
  final String trainerName;

  StaffBatchRowDto({
    required this.id,
    required this.name,
    required this.courseTitle,
    required this.memberCount,
    required this.status,
    required this.trainerName,
  });

  factory StaffBatchRowDto.fromJson(Map<String, dynamic> json) {
    final course = jsonMap(json['course']);
    final createdBy = jsonMap(json['createdBy']);
    final count = jsonMap(json['_count']);
    return StaffBatchRowDto(
      id: jsonStr(json['id']),
      name: jsonStr(json['name']),
      courseTitle: jsonStr(course['title']),
      memberCount: jsonInt(count['members']),
      status: jsonStr(json['status']),
      trainerName: jsonStr(createdBy['name'], 'Staff'),
    );
  }
}
