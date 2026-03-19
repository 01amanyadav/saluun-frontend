/// Logger Utility for Debugging
///
/// Provides a centralized logging system with support for different log levels.
/// Logs are automatically disabled in release mode.

import 'package:flutter/foundation.dart';

/// Log levels
enum LogLevel {
  /// Detailed information, typically used for debugging
  debug(prefix: '[DEBUG]'),

  /// Confirmation that things are working as expected
  info(prefix: '[INFO]'),

  /// Warning about a potential issue
  warning(prefix: '[WARNING]'),

  /// A serious problem that the application may be able to recover from
  error(prefix: '[ERROR]'),

  /// A very serious error, the application itself may be unable to continue
  fatal(prefix: '[FATAL]');

  final String prefix;

  const LogLevel({required this.prefix});
}

/// Logger utility for consistent logging across the app
class Logger {
  static const String _logTag = 'Saluun';
  static bool _enableLogging = kDebugMode; // Only log in debug mode

  /// Enable or disable logging
  static void setLoggingEnabled(bool enabled) {
    _enableLogging = enabled;
  }

  /// Log debug message
  /// Example: Logger.debug('User loaded', tag: 'Auth')
  static void debug(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    _log(LogLevel.debug, message, error, stackTrace, tag);
  }

  /// Log info message
  /// Example: Logger.info('App started', tag: 'App')
  static void info(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    _log(LogLevel.info, message, error, stackTrace, tag);
  }

  /// Log warning message
  /// Example: Logger.warning('API response slow', tag: 'Network')
  static void warning(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    _log(LogLevel.warning, message, error, stackTrace, tag);
  }

  /// Log error message
  /// Example: Logger.error('Failed to load data', error: exception)
  static void error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    _log(LogLevel.error, message, error, stackTrace, tag);
  }

  /// Log fatal error (highest priority)
  /// Example: Logger.fatal('Auth failed completely', error: exception)
  static void fatal(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    _log(LogLevel.fatal, message, error, stackTrace, tag);
  }

  /// Log network request
  /// Example: Logger.network('GET /users', statusCode: 200, duration: 150)
  static void network(
    String request, {
    int? statusCode,
    int? duration, // in milliseconds
    String tag = 'Network',
  }) {
    String message = request;
    if (statusCode != null) message += ' → $statusCode';
    if (duration != null) message += ' (${duration}ms)';
    _log(LogLevel.info, message, null, null, tag);
  }

  /// Log database operation
  /// Example: Logger.database('INSERT user', duration: 50)
  static void database(
    String operation, {
    int? duration, // in milliseconds
    String tag = 'Database',
  }) {
    String message = operation;
    if (duration != null) message += ' (${duration}ms)';
    _log(LogLevel.debug, message, null, null, tag);
  }

  /// Log performance metric
  /// Example: Logger.performance('Screen render', duration: 250)
  static void performance(
    String metric, {
    required int duration, // in milliseconds
    String tag = 'Performance',
  }) {
    final message = '$metric (${duration}ms${duration > 100 ? ' ⚠️' : ''})';
    final level = duration > 500 ? LogLevel.warning : LogLevel.debug;
    _log(level, message, null, null, tag);
  }

  /// Log API call details
  /// Example: Logger.api('POST /auth/login', {'email': 'user@example.com'})
  static void api(String endpoint, [dynamic requestData, String tag = 'API']) {
    final message = '$endpoint ${requestData != null ? '→ $requestData' : ''}';
    _log(LogLevel.debug, message, null, null, tag);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    dynamic message,
    dynamic error,
    StackTrace? stackTrace,
    String tag,
  ) {
    if (!_enableLogging) return;

    final timestamp = _getTimeestamp();
    final logMessage = '[$timestamp] ${level.prefix} [$tag] $message';

    // Print based on log level
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        debugPrint(logMessage);
      case LogLevel.warning:
        debugPrint('⚠️  $logMessage');
      case LogLevel.error:
        debugPrint('❌ $logMessage');
      case LogLevel.fatal:
        debugPrint('🔴 $logMessage');
    }

    // Print error if provided
    if (error != null) {
      debugPrint('  Error: $error');
    }

    // Print stack trace if provided
    if (stackTrace != null) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }

  /// Get formatted timestamp
  static String _getTimeestamp() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Clear logs (if using persistent logging in the future)
  static void clearLogs() {
    debugPrint('\n${Logger._logTag} Logs Cleared\n');
  }

  /// Print separator line for better log readability
  static void separator() {
    debugPrint(
      '════════════════════════════════════════════════════════════════',
    );
  }

  /// Log app lifecycle events
  static void lifecycle(String event, {String tag = 'Lifecycle'}) {
    _log(LogLevel.info, event, null, null, tag);
  }

  /// Log user actions
  static void action(String action, {dynamic data, String tag = 'Action'}) {
    final message = data != null ? '$action → $data' : action;
    _log(LogLevel.debug, message, null, null, tag);
  }

  /// Log exception with context
  static void logException(
    Object exception, {
    String? context,
    StackTrace? stackTrace,
    String tag = _logTag,
  }) {
    final message = context != null
        ? '$context\n$exception'
        : exception.toString();
    _log(LogLevel.error, message, exception, stackTrace, tag);
  }

  /// Start performance measurement
  static _PerformanceTimer startTimer(
    String label, {
    String tag = 'Performance',
  }) {
    return _PerformanceTimer(label, tag);
  }

  /// Log a debug dump of an object
  static void dump(dynamic object, {String tag = 'Dump'}) {
    _log(LogLevel.debug, object.toString(), null, null, tag);
  }
}

/// Helper class for measuring performance
class _PerformanceTimer {
  final String label;
  final String tag;
  final DateTime _startTime = DateTime.now();

  _PerformanceTimer(this.label, this.tag);

  /// Stop the timer and log the result
  void stop({String? customLabel}) {
    final duration = DateTime.now().difference(_startTime).inMilliseconds;
    final finalLabel = customLabel ?? label;
    Logger.performance(finalLabel, duration: duration, tag: tag);
  }

  /// Get elapsed time in milliseconds
  int get elapsed => DateTime.now().difference(_startTime).inMilliseconds;

  /// Check if elapsed time exceeds threshold
  bool exceedsThreshold(int maxMillis) {
    return elapsed > maxMillis;
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/*
// Debug logging
Logger.debug('Initializing app', tag: 'App');

// Info logging
Logger.info('User logged in: john@example.com');

// Warning logging
Logger.warning('API response time is slow: 5000ms');

// Error logging
Logger.error('Failed to fetch user data', error: exception, stackTrace: st);

// Fatal error
Logger.fatal('Critical authentication failure');

// Network logging
Logger.network('GET /api/users', statusCode: 200, duration: 150);

// Database logging
Logger.database('Query executed', duration: 45);

// Performance monitoring
Logger.performance('Screen render', duration: 250);

// API logging
Logger.api('POST /auth/login', {'email': 'user@example.com'});

// Lifecycle events
Logger.lifecycle('App resumed');

// User actions
Logger.action('Button tapped', data: 'LoginButton');

// Exception logging
Logger.logException(exception, context: 'During user logout');

// Performance timer
final timer = Logger.startTimer('Data fetch');
// ... do some work ...
timer.stop();

// or with custom label
final timer2 = Logger.startTimer('Initial load');
// ... do some work ...
timer2.stop(customLabel: 'Initial app load completed');

// Dump object
Logger.dump({'user': 'John', 'email': 'john@example.com'});

// Separator for readability
Logger.separator();

// Disable logging in release mode (automatic)
// Or disable manually:
Logger.setLoggingEnabled(false);

// Clear logs
Logger.clearLogs();
*/
