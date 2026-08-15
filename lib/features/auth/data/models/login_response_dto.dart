import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  final String token;
  final String? refreshToken;
  final UserDto user;

  LoginResponseDto({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}

@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatar;

  UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}
