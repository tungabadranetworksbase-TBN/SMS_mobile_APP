/// `GET /api/users/me` — the identity plus the full authorization picture.
///
/// The backend's RBAC doc is explicit that the client derives ALL staff
/// navigation from this response and never from tier names, and that
/// permissions must not be cached across requests.
class MeDto {
  final MeUserDto user;

  /// Effective permission keys. Empty for students; every key for
  /// SUPER_ADMIN — the backend expands that server-side, so the client
  /// needs no special case.
  final List<String> permissions;

  /// Module key -> enabled. A missing key means enabled.
  final Map<String, bool> modules;

  const MeDto({
    required this.user,
    required this.permissions,
    required this.modules,
  });

  factory MeDto.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'] as Map? ?? const {};
    return MeDto(
      user: MeUserDto.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      permissions: (json['permissions'] as List? ?? const [])
          .map((p) => p.toString())
          .toList(growable: false),
      modules: {
        for (final entry in rawModules.entries)
          entry.key.toString(): entry.value == true,
      },
    );
  }
}

class MeUserDto {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String? image;

  /// `STUDENT` | `STAFF` | `SUPER_ADMIN`.
  final String userType;

  /// `ACTIVE` | `SUSPENDED` | …
  final String status;

  /// Account is on an administrator-set password; every non-GET is blocked
  /// until it is changed.
  final bool mustChangePassword;

  const MeUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.image,
    required this.userType,
    required this.status,
    required this.mustChangePassword,
  });

  factory MeUserDto.fromJson(Map<String, dynamic> json) => MeUserDto(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    emailVerified: json['emailVerified'] == true,
    image: json['image'] as String?,
    userType: json['userType'] as String,
    status: json['status'] as String,
    mustChangePassword: json['mustChangePassword'] == true,
  );
}
