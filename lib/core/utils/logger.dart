import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final sanitized = _sanitize(message);
      debugPrint('[INFO] $sanitized');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stacktrace: $stackTrace');
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final sanitized = _sanitize(message);
      debugPrint('[WARNING] $sanitized');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stacktrace: $stackTrace');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final sanitized = _sanitize(message);
      debugPrint('[ERROR] $sanitized');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stacktrace: $stackTrace');
    }
  }

  static String _sanitize(String input) {
    // Replace access_token/refresh_token/token patterns with [MASKED]
    final tokenRegex = RegExp(
      r'(access_token|refresh_token|token|authorization)[:=]\s*[^\s,\}\]]+',
      caseSensitive: false,
    );
    return input.replaceAllMapped(tokenRegex, (match) {
      final key = match.group(1);
      return '$key: [MASKED]';
    });
  }
}
