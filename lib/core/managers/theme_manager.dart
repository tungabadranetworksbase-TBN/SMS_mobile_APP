import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../storage/preference_manager.dart';

/// Tungabadra Networks LMS — Theme Manager
///
/// Manages application theme mode (light/dark/system).
/// Pattern: Zentriva singleton manager.
class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final PreferenceManager _preferenceManager = PreferenceManager();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load saved theme mode from preferences on startup.
  Future<void> init() async {
    final savedThemeStr = _preferenceManager.getString(AppConstants.keyThemeMode);
    if (savedThemeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedThemeStr,
        orElse: () => ThemeMode.system,
      );
    } else {
      // Default to dark mode for this app as requested
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  /// Update and save theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _preferenceManager.setString(AppConstants.keyThemeMode, mode.toString());
    notifyListeners();
  }

  /// Toggle between light and dark mode.
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
