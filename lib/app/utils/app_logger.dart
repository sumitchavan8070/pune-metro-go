import 'dart:developer' as developer;

class AppLogger {
  void info(String message) => developer.log(message, name: 'pune_metro');

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'pune_metro',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
