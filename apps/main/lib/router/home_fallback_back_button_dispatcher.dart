import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Locations where exiting the application is valid when there is no history.
///
/// Home is the normal app root. Splash and login are also roots because home
/// is not reachable for a signed-out session. Profile completion is
/// intentionally not an exit root: it belongs to an authenticated journey and
/// must consume back instead of closing the app unexpectedly.
const appExitRootPaths = <String>{
  '/',
  '/splash',
  '/login',
};

/// Gives the active router the first chance to handle a system back request.
///
/// When the router has no page to pop (for example, after the app was opened
/// directly on a deep link), a non-home location is replaced with home instead
/// of letting the platform close the application.
class HomeFallbackBackButtonDispatcher extends RootBackButtonDispatcher {
  HomeFallbackBackButtonDispatcher({
    required Uri Function() currentUri,
    required VoidCallback goHome,
    this.exitRootPaths = appExitRootPaths,
  })  : _currentUri = currentUri,
        _goHome = goHome;

  final Uri Function() _currentUri;
  final VoidCallback _goHome;
  final Set<String> exitRootPaths;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (await super.invokeCallback(defaultValue)) return true;
    if (!_canFallBackToHome(_currentUri(), exitRootPaths)) return false;

    _goHome();
    return true;
  }
}

/// Whether Flutter must claim a system back gesture before it starts.
///
/// This complements [HomeFallbackBackButtonDispatcher] on Android versions
/// with predictive back. The platform can otherwise close a single-page deep
/// link without dispatching a back request to Flutter at all.
bool shouldHandleSystemBack({
  required bool notificationCanHandlePop,
  required Uri currentUri,
  Set<String> exitRootPaths = appExitRootPaths,
}) {
  return notificationCanHandlePop ||
      _canFallBackToHome(currentUri, exitRootPaths);
}

/// Reports [shouldHandleSystemBack] to the platform for predictive back.
///
/// Use this as [WidgetsApp.onNavigationNotification] (or
/// [MaterialApp.onNavigationNotification]) so a direct non-home route is not
/// closed by Android before [HomeFallbackBackButtonDispatcher] can run.
bool handleSystemBackNavigationNotification(
  NavigationNotification notification, {
  required Uri currentUri,
  Set<String> exitRootPaths = appExitRootPaths,
}) {
  final lifecycleState = WidgetsBinding.instance.lifecycleState;
  if (!canReportSystemBackToPlatform(lifecycleState)) return true;
  unawaited(
    SystemNavigator.setFrameworkHandlesBack(
      shouldHandleSystemBack(
        notificationCanHandlePop: notification.canHandlePop,
        currentUri: currentUri,
        exitRootPaths: exitRootPaths,
      ),
    ).onError<Object>((_, __) {
      // The engine may detach between the lifecycle check and channel call.
    }),
  );
  return true;
}

bool canReportSystemBackToPlatform(AppLifecycleState? lifecycleState) =>
    lifecycleState != null && lifecycleState != AppLifecycleState.detached;

bool _canFallBackToHome(Uri currentUri, Set<String> exitRootPaths) {
  return !exitRootPaths.contains(currentUri.path);
}
