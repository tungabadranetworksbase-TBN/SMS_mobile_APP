// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  role: json['role'] as String,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'phone': instance.phone,
      'address': instance.address,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
