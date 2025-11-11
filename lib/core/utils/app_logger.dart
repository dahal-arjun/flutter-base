import 'package:logger/logger.dart';

/// Global logger instance for the application
/// Provides structured, colorful logging with proper formatting
class AppLogger {
  static Logger? _instance;

  /// Get the logger instance
  static Logger get instance {
    _instance ??= Logger(
      printer: PrettyPrinter(
        methodCount: 0, // Don't show method calls for cleaner output
        errorMethodCount: 5, // Show method calls only for errors
        lineLength: 100,
        colors: true,
        printEmojis: false, // Remove emojis for cleaner output
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        noBoxingByDefault: false,
        stackTraceBeginIndex: 0,
      ),
      level: _getLogLevel(),
    );
    return _instance!;
  }

  /// Get log level based on environment
  static Level _getLogLevel() {
    // In debug mode, show all logs
    // In release mode, only show warnings and errors
    return const bool.fromEnvironment('dart.vm.product')
        ? Level.warning
        : Level.debug;
  }

  /// Log debug message
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error message
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }
}

