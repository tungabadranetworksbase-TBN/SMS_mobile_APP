import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/config/api_endpoints.dart';

void main() {
  group('withParams', () {
    test('substitutes a single parameter', () {
      expect(
        ApiEndpoints.withParams(ApiEndpoints.batchDetail, {'id': 'b1'}),
        '/batches/b1',
      );
    });

    test('substitutes every occurrence of a parameter', () {
      expect(
        ApiEndpoints.withParams('/a/{id}/b/{id}', {'id': 'x'}),
        '/a/x/b/x',
      );
    });

    test('leaves an unsupplied placeholder in place', () {
      // Loud failure at the HTTP layer beats a silently malformed URL.
      expect(ApiEndpoints.withParams('/a/{id}', const {}), '/a/{id}');
    });
  });

  group('endpoint hygiene', () {
    test('the routes v1 depends on are correct', () {
      expect(ApiEndpoints.serverHealth, '/health');
      expect(ApiEndpoints.signIn, '/auth/sign-in/email');
      expect(ApiEndpoints.me, '/users/me');
      expect(ApiEndpoints.studentDashboardV1, '/student/dashboard');
      expect(ApiEndpoints.notifications, '/notifications');
      expect(ApiEndpoints.unreadCount, '/notifications/unread-count');
      expect(ApiEndpoints.markAllNotificationsRead, '/notifications/read-all');
      expect(ApiEndpoints.staffRegistry, '/staff/registry');
    });

    test(
      'no endpoint carries the /api prefix — the base URL already has it',
      () {
        for (final path in ApiEndpoints.all) {
          expect(
            path.startsWith('/api/'),
            isFalse,
            reason: '$path double-prefixes /api',
          );
        }
      },
    );

    test('every endpoint starts with a slash', () {
      for (final path in ApiEndpoints.all) {
        expect(path.startsWith('/'), isTrue, reason: '$path is not rooted');
      }
    });
  });
}
