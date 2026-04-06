import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A centralized logging service that handles debug printing and Sentry reporting
class AppLogger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void info(String message, {String? tag}) {
    debug(message, tag: tag);
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.info,
      ),
    );
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String? tag}) async {
    if (kDebugMode) {
      print('❌ ERROR ${tag != null ? '[$tag] ' : ''}$message');
      if (error != null) print('Detail: $error');
    }
    
    await Sentry.captureException(
      error ?? message,
      stackTrace: stackTrace,
      hint: Hint.withMap({'message': message, 'tag': tag ?? 'None'}),
    );
  }

  static void warning(String message, {String? tag}) {
    debug('⚠️ $message', tag: tag);
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: tag,
        level: SentryLevel.warning,
      ),
    );
  }
}
