import 'package:json_annotation/json_annotation.dart';

part 'signup_request_dto.g.dart';

@JsonSerializable()
class SignupRequestDto {
  final String name;
  final String email;
  final String password;

  SignupRequestDto({
    required this.name,
    required this.email,
    required this.password,
  });

  factory SignupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestDtoToJson(this);
}
