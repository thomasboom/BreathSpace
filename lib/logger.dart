class AppLogger {
  static const bool _kDebugMode = true;

  static void debug(String message) {
    if (_kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  static void info(String message) {
    print('[INFO] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) {
      print('Error details: $error');
    }
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}