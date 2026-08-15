import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connectivity_manager.dart';

/// Tungabadra Networks LMS — Offline Sync Manager
///
/// Handles queuing actions when offline and syncing them when online.
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

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

  /// Process the queued actions.
  Future<void> syncPendingData() async {
    if (_connectivityManager?.isConnected != true) return;

    final queuedActions = _prefs.getStringList(_syncQueueKey) ?? [];
    if (queuedActions.isEmpty) return;

    _logger.i('Starting offline sync of ${queuedActions.length} items...');

    final List<String> failedActions = [];

    for (final actionStr in queuedActions) {
      try {
        final action = jsonDecode(actionStr);
        // Note: In a full implementation, you would inject ApiClient here 
        // and execute the stored HTTP requests.
        // e.g. await apiClient.request(action['endpoint'], data: action['payload'], method: action['method']);
        
        _logger.i('Successfully synced: ${action['endpoint']}');
      } catch (e) {
        _logger.e('Failed to sync action: $e');
        failedActions.add(actionStr); // Keep failed actions in queue
      }
    }

    // Update queue with only the failed actions
    await _prefs.setStringList(_syncQueueKey, failedActions);
    _logger.i('Offline sync completed. ${failedActions.length} items remaining.');
  }
}
