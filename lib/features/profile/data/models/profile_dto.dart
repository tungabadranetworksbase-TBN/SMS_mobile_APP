import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? address;
  final String role;
  final DateTime joinedAt;

  ProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.address,
    required this.role,
    required this.joinedAt,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}
