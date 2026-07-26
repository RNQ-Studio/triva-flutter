import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Firebase Crashlytics.
///
/// Provides automatic crash reporting for Flutter framework errors
/// and uncaught platform errors on Firebase Crashlytics-supported platforms.
class CrashlyticsService {
  static bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        true,
      _ => false,
    };
  }

  /// Initialize Crashlytics and register global error handlers.
  ///
  /// Must be called after [FirebaseService.init] in `bootstrap()`.
  static Future<void> init() async {
    if (!_isSupportedPlatform) {
      return;
    }

    // Only enable collection in release mode.
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Catch Flutter framework errors.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch async errors not handled by Flutter.
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Record a non-fatal error for monitoring.
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (!_isSupportedPlatform) {
      return;
    }

    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason ?? 'Non-fatal error',
    );
  }

  /// Set user identifier for crash report grouping.
  static Future<void> setUserIdentifier(String userId) async {
    if (!_isSupportedPlatform) {
      return;
    }

    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Add a custom log entry to the next crash report.
  static void log(String message) {
    if (!_isSupportedPlatform) {
      return;
    }

    FirebaseCrashlytics.instance.log(message);
  }
}
