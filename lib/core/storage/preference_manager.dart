import 'package:shared_preferences/shared_preferences.dart';

/// Tungabadra Networks LMS — Preference Manager
///
/// SharedPreferences wrapper for non-sensitive app preferences.
/// Pattern: Zentriva singleton (same as StopwatchManager).
class PreferenceManager {
  static final PreferenceManager _instance = PreferenceManager._internal();
  factory PreferenceManager() => _instance;
  PreferenceManager._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'PreferenceManager.init() must be called first');
    return _prefs!;
  }

  // ── Keys ──
  static const String _keyServerUrl = 'server_url';
  static const String _keyClientOrigin = 'client_origin';

  // ── String ──
  Future<bool> setString(String key, String value) => _p.setString(key, value);
  String? getString(String key) => _p.getString(key);

  // ── Server URL ──
  Future<bool> setServerUrl(String url) => setString(_keyServerUrl, url);
  String? getServerUrl() => getString(_keyServerUrl);

  // ── Web client origin (Stripe return URLs) ──
  Future<bool> setClientOrigin(String origin) =>
      setString(_keyClientOrigin, origin);
  String? getClientOrigin() => getString(_keyClientOrigin);

  // ── Bool ──
  Future<bool> setBool(String key, bool value) => _p.setBool(key, value);
  bool? getBool(String key) => _p.getBool(key);

  // ── Int ──
  Future<bool> setInt(String key, int value) => _p.setInt(key, value);
  int? getInt(String key) => _p.getInt(key);

  // ── Double ──
  Future<bool> setDouble(String key, double value) => _p.setDouble(key, value);
  double? getDouble(String key) => _p.getDouble(key);

  // ── String List ──
  Future<bool> setStringList(String key, List<String> value) =>
      _p.setStringList(key, value);
  List<String>? getStringList(String key) => _p.getStringList(key);

  // ── Remove ──
  Future<bool> remove(String key) => _p.remove(key);
  Future<bool> clear() => _p.clear();
  bool containsKey(String key) => _p.containsKey(key);
}
