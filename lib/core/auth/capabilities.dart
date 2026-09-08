import '../../features/auth/data/models/me_dto.dart';

enum UserTier { student, staff, superAdmin }

/// Live authorization picture from GET /api/users/me. Never persisted.
class Capabilities {
  final UserTier tier;
  final Set<String> permissions;
  final Map<String, bool> modules;
  final bool mustChangePassword;

  const Capabilities({
    required this.tier,
    required this.permissions,
    required this.modules,
    this.mustChangePassword = false,
  });

  factory Capabilities.fromMe(MeDto me) {
    return Capabilities(
      tier: UserTierParsing.fromWire(me.user.userType),
      permissions: me.permissions.toSet(),
      modules: Map<String, bool>.from(me.modules),
      mustChangePassword: me.user.mustChangePassword,
    );
  }

  /// Demo-only stand-in. Not persisted; DemoMode still owns the role string.
  factory Capabilities.demo(String role) {
    switch (role) {
      case 'smr':
        return const Capabilities(
          tier: UserTier.staff,
          permissions: {'students.account.view', 'batches.batch.view'},
          modules: {},
        );
      case 'admin':
        return const Capabilities(
          tier: UserTier.superAdmin,
          permissions: {
            'students.account.view',
            'batches.batch.view',
            'insights.dashboard.view',
          },
          modules: {},
        );
      default:
        return const Capabilities(
          tier: UserTier.student,
          permissions: {},
          modules: {},
        );
    }
  }

  /// Missing module row means enabled (matches backend ModuleSetting).
  bool moduleEnabled(String module) => modules[module] ?? true;

  bool can(String key) {
    final module = key.split('.').first;
    if (!moduleEnabled(module)) return false;
    return permissions.contains(key);
  }

  Capabilities copyWith({
    UserTier? tier,
    Set<String>? permissions,
    Map<String, bool>? modules,
    bool? mustChangePassword,
  }) {
    return Capabilities(
      tier: tier ?? this.tier,
      permissions: permissions ?? this.permissions,
      modules: modules ?? this.modules,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

class UserTierParsing {
  UserTierParsing._();

  static UserTier fromWire(String userType) {
    switch (userType) {
      case 'STAFF':
        return UserTier.staff;
      case 'SUPER_ADMIN':
        return UserTier.superAdmin;
      default:
        return UserTier.student;
    }
  }
}
