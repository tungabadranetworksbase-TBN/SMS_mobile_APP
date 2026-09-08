import '../../../../core/network/json_value.dart';

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

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? jsonMap(json['user']) : json;
    final profile = json['profile'] is Map ? jsonMap(json['profile']) : json;
    return ProfileDto(
      id: jsonStr(user['id'] ?? json['id']),
      name: jsonStr(user['name'] ?? json['name']),
      email: jsonStr(user['email'] ?? json['email']),
      avatarUrl: user['image']?.toString() ??
          profile['photoUrl']?.toString() ??
          json['avatarUrl']?.toString(),
      phone: profile['phone']?.toString() ?? json['phone']?.toString(),
      address: json['address']?.toString(),
      role: jsonStr(json['role'] ?? user['userType'], 'student'),
      joinedAt: jsonDate(json['joinedAt'] ?? user['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
