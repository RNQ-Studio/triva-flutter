import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Callback handler for background messages.
///
/// Must be a **top-level function** (not a class method)
/// because it runs in its own isolate on Android.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Service layer for Firebase Cloud Messaging (FCM).
///
/// Handles permission request, token management, and message listeners
/// for foreground, background, and terminated-state notifications.
class FCMNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  /// Initializes FCM: requests permission, retrieves token,
  /// and registers foreground/background listeners.
  Future<void> init({
    required void Function(RemoteMessage) onForegroundMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
    Future<void> Function(String token)? onTokenChanged,
  }) async {
    // 1. Request permission (iOS & Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _fcm.getToken();
      if (token != null && onTokenChanged != null) {
        await onTokenChanged(token);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) async {
        await onTokenChanged?.call(newToken);
      });

      await _foregroundSubscription?.cancel();
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(onForegroundMessage);

      await _openedAppSubscription?.cancel();
      _openedAppSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        onMessageOpenedApp(initialMessage);
      }
    }
  }

  /// Returns the current FCM device token, or `null` if unavailable.
  Future<String?> getToken() => _fcm.getToken();

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
  }
}
