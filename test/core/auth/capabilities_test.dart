import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/auth/capabilities.dart';
import 'package:tbn_lms/core/auth/destinations.dart';
import 'package:tbn_lms/core/router/route_names.dart';
import 'package:tbn_lms/features/auth/data/models/me_dto.dart';

Capabilities _caps({
  required UserTier tier,
  List<String> permissions = const [],
  Map<String, bool> modules = const {},
}) {
  return Capabilities(
    tier: tier,
    permissions: permissions.toSet(),
    modules: modules,
  );
}

void main() {
  group('Capabilities.can', () {
    test('module gate denies even when the permission is present', () {
      final caps = _caps(
        tier: UserTier.superAdmin,
        permissions: ['crm.lead.view'],
        modules: {'crm': false},
      );
      expect(caps.can('crm.lead.view'), isFalse);
    });

    test('missing module row means enabled', () {
      final caps = _caps(
        tier: UserTier.staff,
        permissions: ['students.account.view'],
      );
      expect(caps.can('students.account.view'), isTrue);
    });

    test('unknown permission key is ignored', () {
      final caps = _caps(
        tier: UserTier.staff,
        permissions: ['invented.permission.view'],
      );
      expect(caps.can('invented.permission.view'), isTrue);
      expect(
        visibleStaffDestinations(caps),
        isEmpty,
      );
    });
  });

  group('visibleStaffDestinations', () {
    test('student with empty permissions sees no staff destinations', () {
      final caps = _caps(tier: UserTier.student);
      expect(visibleStaffDestinations(caps), isEmpty);
      expect(homeRouteFor(caps), RoutePaths.studentDashboard);
    });

    test('staff with students.account.view only sees Students', () {
      final caps = _caps(
        tier: UserTier.staff,
        permissions: ['students.account.view'],
      );
      final dests = visibleStaffDestinations(caps);
      expect(dests, hasLength(1));
      expect(dests.single.route, RoutePaths.staffStudents);
      expect(homeRouteFor(caps), RoutePaths.staffStudents);
    });

    test('super admin with every v1 key sees every destination', () {
      final caps = _caps(
        tier: UserTier.superAdmin,
        permissions: [
          'students.account.view',
          'batches.batch.view',
          'insights.dashboard.view',
        ],
      );
      expect(
        visibleStaffDestinations(caps).map((d) => d.route),
        [
          RoutePaths.staffStudents,
          RoutePaths.staffBatches,
          RoutePaths.staffInsights,
        ],
      );
      expect(homeRouteFor(caps), RoutePaths.staffStudents);
    });

    test('super admin with crm disabled does not gain a CRM tab', () {
      final caps = _caps(
        tier: UserTier.superAdmin,
        permissions: [
          'students.account.view',
          'crm.lead.view',
        ],
        modules: {'crm': false},
      );
      expect(
        visibleStaffDestinations(caps).map((d) => d.route),
        [RoutePaths.staffStudents],
      );
    });

    test('staff with no mobile destination lands on the empty state', () {
      final caps = _caps(
        tier: UserTier.staff,
        permissions: ['website.page.view'],
      );
      expect(visibleStaffDestinations(caps), isEmpty);
      expect(homeRouteFor(caps), RoutePaths.staffUnavailable);
    });
  });

  group('Capabilities.fromMe', () {
    test('maps STUDENT STAFF SUPER_ADMIN userType', () {
      expect(
        Capabilities.fromMe(
          const MeDto(
            user: MeUserDto(
              id: '1',
              name: 'A',
              email: 'a@x.com',
              emailVerified: true,
              image: null,
              userType: 'STUDENT',
              status: 'ACTIVE',
              mustChangePassword: false,
            ),
            permissions: [],
            modules: {},
          ),
        ).tier,
        UserTier.student,
      );
      expect(
        Capabilities.fromMe(
          const MeDto(
            user: MeUserDto(
              id: '1',
              name: 'A',
              email: 'a@x.com',
              emailVerified: true,
              image: null,
              userType: 'STAFF',
              status: 'ACTIVE',
              mustChangePassword: false,
            ),
            permissions: [],
            modules: {},
          ),
        ).tier,
        UserTier.staff,
      );
      expect(
        Capabilities.fromMe(
          const MeDto(
            user: MeUserDto(
              id: '1',
              name: 'A',
              email: 'a@x.com',
              emailVerified: true,
              image: null,
              userType: 'SUPER_ADMIN',
              status: 'ACTIVE',
              mustChangePassword: false,
            ),
            permissions: [],
            modules: {},
          ),
        ).tier,
        UserTier.superAdmin,
      );
    });
  });
}
