import 'package:connectivity_plus/connectivity_plus.dart';

/// Tungabadra Networks LMS — Network Info
///
/// Checks current connectivity status.
/// Used by interceptors and the ConnectivityManager.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Check if device has any network connection.
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream of connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
