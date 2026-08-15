import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Tungabadra Networks LMS — Connectivity Manager
///
/// Monitors internet connectivity and exposes a stream for UI banners.
/// Pattern: Zentriva's ConnectivityProvider, upgraded to singleton manager.
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  StreamSubscription? _subscription;
  bool _isConnected = true;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isConnected => _isConnected;

  /// Start monitoring connectivity changes.
  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final connected = !results.contains(ConnectivityResult.none);
        if (connected != _isConnected) {
          _isConnected = connected;
          _connectivityController.add(connected);
          _logger.i('Connectivity changed: ${connected ? "ONLINE" : "OFFLINE"}');
        }
      },
    );
  }

  /// Check current connectivity.
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    return _isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
