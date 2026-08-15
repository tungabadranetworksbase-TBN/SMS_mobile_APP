// test/features/auth/me_dto_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/features/auth/data/models/me_dto.dart';

/// Shape recorded from `GET /api/users/me`
/// (`server/src/modules/users/users.routes.ts`).
const _staffPayload = {
  'user': {
    'id': 'usr_1',
    'name': 'Asha Rao',
    'email': 'asha@example.com',
    'emailVerified': true,
    'image': null,
    'userType': 'STAFF',
    'status': 'ACTIVE',
    'createdAt': '2026-01-04T09:12:00.000Z',
    'mustChangePassword': false,
  },
  'permissions': ['students.account.view', 'batches.batch.view'],
  'modules': {'students': true, 'batches': true, 'crm': false},
};

void main() {
  test('parses a staff payload', () {
    final me = MeDto.fromJson(Map<String, dynamic>.from(_staffPayload));

    expect(me.user.id, 'usr_1');
    expect(me.user.name, 'Asha Rao');
    expect(me.user.userType, 'STAFF');
    expect(me.user.mustChangePassword, isFalse);
    expect(me.permissions, ['students.account.view', 'batches.batch.view']);
    expect(me.modules['crm'], isFalse);
  });

  test('parses a student payload with no permissions', () {
    final me = MeDto.fromJson({
      'user': {
        'id': 'usr_2',
        'name': 'Ravi K',
        'email': 'ravi@example.com',
        'emailVerified': true,
        'userType': 'STUDENT',
        'status': 'ACTIVE',
        'mustChangePassword': false,
      },
      'permissions': <dynamic>[],
      'modules': <String, dynamic>{},
    });

    expect(me.permissions, isEmpty);
    expect(me.user.userType, 'STUDENT');
    expect(me.user.image, isNull);
  });

  test('defaults mustChangePassword to false when the key is absent', () {
    final me = MeDto.fromJson({
      'user': {
        'id': 'usr_3',
        'name': 'X',
        'email': 'x@example.com',
        'emailVerified': true,
        'userType': 'SUPER_ADMIN',
        'status': 'ACTIVE',
      },
      'permissions': ['staff.user.view'],
      'modules': {'staff': true},
    });

    expect(me.user.mustChangePassword, isFalse);
  });

  test('a module key absent from the payload stays absent, not false', () {
    // An absent key means ENABLED. Collapsing it to false would silently
    // hide navigation for every staff user.
    final me = MeDto.fromJson({
      'user': {
        'id': 'usr_4',
        'name': 'Y',
        'email': 'y@example.com',
        'emailVerified': true,
        'userType': 'STAFF',
        'status': 'ACTIVE',
        'mustChangePassword': false,
      },
      'permissions': ['crm.lead.view'],
      'modules': {'crm': false},
    });

    expect(me.modules['crm'], isFalse);
    expect(me.modules.containsKey('students'), isFalse);
    expect(me.modules['students'], isNull);
  });
}
