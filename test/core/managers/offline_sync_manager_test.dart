import 'package:flutter_test/flutter_test.dart';
import 'package:tbn_lms/core/managers/offline_sync_manager.dart';
import 'package:tbn_lms/core/network/api_error_code.dart';
import 'package:tbn_lms/core/network/api_exception.dart';

/// The queue holds work the student was told is saved. Before this, every
/// replay outcome dropped the entry — these pin down what may leave the queue.
void main() {
  group('OfflineSyncManager.shouldRequeue', () {
    test('keeps a submission queued when the network is still down', () {
      expect(
        OfflineSyncManager.shouldRequeue(const ApiException.network()),
        isTrue,
      );
    });

    test('keeps a submission queued on timeout', () {
      expect(
        OfflineSyncManager.shouldRequeue(const ApiException.timeout()),
        isTrue,
      );
    });

    test('keeps a submission queued when the server is broken', () {
      expect(
        OfflineSyncManager.shouldRequeue(const ApiException.server()),
        isTrue,
      );
    });

    test('drops a submission the server refused', () {
      // A 4xx is final. Requeuing it would retry on every reconnect forever.
      expect(
        OfflineSyncManager.shouldRequeue(
          ApiException.fromStatusCode(400, body: 'attempt already submitted'),
        ),
        isFalse,
      );
      expect(
        OfflineSyncManager.shouldRequeue(const ApiException.forbidden()),
        isFalse,
      );
      expect(
        OfflineSyncManager.shouldRequeue(
          const ApiException(
            message: 'Time limit exceeded',
            statusCode: 422,
            code: ApiErrorCode.timeLimitExceeded,
          ),
        ),
        isFalse,
      );
    });

    test('keeps anything it cannot classify rather than losing it', () {
      expect(
        OfflineSyncManager.shouldRequeue(const ApiException.unknown()),
        isTrue,
      );
      expect(OfflineSyncManager.shouldRequeue(StateError('boom')), isTrue);
    });
  });
}
