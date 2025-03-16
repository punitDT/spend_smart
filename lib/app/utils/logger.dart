import 'package:flutter/foundation.dart';

class Logger {
  static void i(String tag, String message) {
    if (kDebugMode) {
      print('ℹ️ INFO [$tag] $message');
    }
  }

  static void e(String tag, String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR [$tag] $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      print('⚠️ WARN [$tag] $message');
    }
  }
}
