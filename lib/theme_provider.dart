import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/logger.dart';

enum AppThemeMode { system, light, dark, oled }

class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    AppLogger.debug('Loading theme mode');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? theme = prefs.getString('themeMode');
      if (theme == 'light') {
        _themeMode = AppThemeMode.light;
      } else if (theme == 'dark') {
        _themeMode = AppThemeMode.dark;
      } else if (theme == 'oled') {
        _themeMode = AppThemeMode.oled;
      } else {
        _themeMode = AppThemeMode.system;
      }
      notifyListeners();
      AppLogger.info('Theme mode loaded: ${_themeMode.name}');
    } catch (e, stack) {
      AppLogger.error('Failed to load theme mode', e, stack);
    }
  }

  void setThemeMode(AppThemeMode mode) async {
    if (mode == _themeMode) return;
    AppLogger.debug('Setting theme mode: ${mode.name}');
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case AppThemeMode.light:
        prefs.setString('themeMode', 'light');
        break;
      case AppThemeMode.dark:
        prefs.setString('themeMode', 'dark');
        break;
      case AppThemeMode.oled:
        prefs.setString('themeMode', 'oled');
        break;
      case AppThemeMode.system:
        prefs.setString('themeMode', 'system');
        break;
    }
    notifyListeners();
  }
}
