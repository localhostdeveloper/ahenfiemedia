// lib/managers/theme_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static const String _themeKey = 'userThemeMode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeManager() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  // Function to load the saved theme preference
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  // Function to change the theme and save the preference
  void setTheme(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      notifyListeners(); // Notify all listeners (i.e., the entire app)
    }
  }

  // Toggle function specifically for the Settings screen switch
  void toggleDarkMode(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}
