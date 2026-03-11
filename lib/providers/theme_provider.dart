import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box<String>('medicines');
      final saved = box.get(_themeKey, defaultValue: 'light');
      _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeProvider: Error loading theme: $e');
    }
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  void _saveTheme() {
    try {
      final box = Hive.box<String>('medicines');
      box.put(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('ThemeProvider: Error saving theme: $e');
    }
  }
}
