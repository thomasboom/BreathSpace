import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setLevel(LogLevel level) => _currentLevel = level;

  static void debug(String message, [dynamic data]) {
    if (_currentLevel.index <= LogLevel.debug.index) {
      _print('[DEBUG]', message, data);
    }
  }

  static void info(String message, [dynamic data]) {
    if (_currentLevel.index <= LogLevel.info.index) {
      _print('[INFO]', message, data);
    }
  }

  static void warning(String message, [dynamic data]) {
    if (_currentLevel.index <= LogLevel.warning.index) {
      _print('[WARNING]', message, data);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_currentLevel.index <= LogLevel.error.index) {
      _print('[ERROR]', message, error, stackTrace);
    }
  }

  static void _print(
    String level,
    String message, [
    dynamic data,
    StackTrace? stackTrace,
  ]) {
    final buffer = StringBuffer()
      ..write(level)
      ..write(' ')
      ..write(message);
    if (data != null) buffer.write(' | Data: $data');
    print(buffer.toString());
    if (stackTrace != null) print(stackTrace);
  }
}
