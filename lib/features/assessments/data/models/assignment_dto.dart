import 'package:json_annotation/json_annotation.dart';

part 'assignment_dto.g.dart';

@JsonSerializable()
class AssignmentDto {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int totalMarks;
  final String? fileUrl;

  AssignmentDto({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalMarks,
    this.fileUrl,
  });

  factory AssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentDtoToJson(this);
}
