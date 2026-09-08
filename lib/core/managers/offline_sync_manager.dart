import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/service_locator.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'connectivity_manager.dart';

/// Tungabadra Networks LMS — Offline Sync Manager
///
/// Queues write actions taken while offline and replays them on reconnect.
///
/// The queue holds work the user believes is saved, so an entry is only ever
/// discarded for a reason: the server rejected it, or it cannot be read back.
/// Anything transient stays queued.
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  // Resolved lazily so the queue survives being read before the network layer
  // is up. Matches SessionManager's accessor pattern.
  ApiClient get _apiClient => locator<ApiClient>();

  final Logger _logger = Logger();
  static const String _syncQueueKey = 'offline_sync_queue';

  late SharedPreferences _prefs;
  ConnectivityManager? _connectivityManager;

  Future<void> init(ConnectivityManager connectivityManager) async {
    _prefs = await SharedPreferences.getInstance();
    _connectivityManager = connectivityManager;

    // Listen to network changes and trigger sync when coming back online
    _connectivityManager!.connectivityStream.listen((isOnline) {
      if (isOnline) {
        syncPendingData();
      }
    });
  }

  /// Queue an action to be performed when online.
  ///
  /// [endpoint] must be the fully-resolved path and [payload] the exact request
  /// body, because replay sends them verbatim.
  Future<void> queueAction({
    required String endpoint,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    final currentQueueStr = _prefs.getStringList(_syncQueueKey) ?? [];

    final action = {
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    currentQueueStr.add(jsonEncode(action));
    await _prefs.setStringList(_syncQueueKey, currentQueueStr);

    _logger.i('Action queued for offline sync: $endpoint');
  }

  /// Whether a failed replay should stay queued for another attempt.
  ///
  /// Transient transport failures are worth retrying. A server rejection is
  /// final — requeuing a 4xx would pin the queue and retry it on every single
  /// reconnect, forever.
  static bool shouldRequeue(Object error) {
    if (error is! ApiException) return true;
    if (error.isNetwork || error.technicalMessage == 'TimeoutException') {
      return true;
    }
    final status = error.statusCode;
    if (status == null) return true;
    return status >= 500;
  }

  /// Replay every queued action. Survivors are written back to the queue.
  Future<void> syncPendingData() async {
    if (_connectivityManager?.isConnected != true) return;

    final queuedActions = _prefs.getStringList(_syncQueueKey) ?? [];
    if (queuedActions.isEmpty) return;

    _logger.i('Starting offline sync of ${queuedActions.length} items...');

    final List<String> remaining = [];

    for (final actionStr in queuedActions) {
      final Map<String, dynamic> action;
      try {
        action = jsonDecode(actionStr) as Map<String, dynamic>;
      } catch (e) {
        // An entry that will not parse can never replay. Dropping it is the
        // only way it ever leaves the queue.
        _logger.e('Dropping unreadable queue entry: $e');
        continue;
      }

      try {
        await _replay(action);
        _logger.i('Successfully synced: ${action['endpoint']}');
      } catch (e) {
        if (shouldRequeue(e)) {
          remaining.add(actionStr);
          _logger.w('Sync deferred for ${action['endpoint']}: $e');
        } else {
          // ponytail: the user was told this was saved and never learns it was
          // refused. Surface rejections in the UI if this queue ever carries
          // more than assessment submissions.
          _logger.e('Server rejected ${action['endpoint']}, dropping: $e');
        }
      }
    }

    await _prefs.setStringList(_syncQueueKey, remaining);
    _logger.i(
      'Offline sync completed. ${remaining.length} items remaining.',
    );
  }

  Future<void> _replay(Map<String, dynamic> action) {
    final endpoint = action['endpoint'] as String;
    final payload = (action['payload'] as Map?)?.cast<String, dynamic>();

    switch ((action['method'] as String? ?? 'POST').toUpperCase()) {
      case 'PUT':
        return _apiClient.put<void>(endpoint, data: payload);
      case 'PATCH':
        return _apiClient.patch<void>(endpoint, data: payload);
      case 'DELETE':
        return _apiClient.delete<void>(endpoint, data: payload);
      default:
        return _apiClient.post<void>(endpoint, data: payload);
    }
  }
}
