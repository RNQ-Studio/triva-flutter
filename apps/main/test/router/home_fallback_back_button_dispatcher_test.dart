import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/router/home_fallback_back_button_dispatcher.dart';

void main() {
  testWidgets('normal router pop takes priority over the home fallback',
      (tester) async {
    late GoRouter router;
    var fallbackCalls = 0;
    final dispatcher = HomeFallbackBackButtonDispatcher(
      currentUri: () => router.state.uri,
      goHome: () {
        fallbackCalls++;
        router.go('/');
      },
    );
    router = _router();
    addTearDown(router.dispose);

    await _pumpRouter(tester, router, dispatcher);
    unawaited(router.push<void>('/details'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(fallbackCalls, 0);
  });

  testWidgets('direct non-home route falls back to home instead of exiting',
      (tester) async {
    late GoRouter router;
    var fallbackCalls = 0;
    final dispatcher = HomeFallbackBackButtonDispatcher(
      currentUri: () => router.state.uri,
      goHome: () {
        fallbackCalls++;
        router.go('/');
      },
    );
    router = _router(initialLocation: '/details');
    addTearDown(router.dispose);

    await _pumpRouter(tester, router, dispatcher);
    expect(find.text('Details'), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(fallbackCalls, 1);
  });

  testWidgets('back at home remains unhandled so the app may exit',
      (tester) async {
    late GoRouter router;
    var fallbackCalls = 0;
    final dispatcher = HomeFallbackBackButtonDispatcher(
      currentUri: () => router.state.uri,
      goHome: () {
        fallbackCalls++;
        router.go('/');
      },
    );
    router = _router();
    addTearDown(router.dispose);

    await _pumpRouter(tester, router, dispatcher);

    expect(await tester.binding.handlePopRoute(), isFalse);
    expect(find.text('Home'), findsOneWidget);
    expect(fallbackCalls, 0);
  });

  test('splash and authentication roots do not redirect to home on back',
      () async {
    for (final path in appExitRootPaths.where((path) => path != '/')) {
      var fallbackCalls = 0;
      final dispatcher = HomeFallbackBackButtonDispatcher(
        currentUri: () => Uri.parse('$path?from=%2Fdetails'),
        goHome: () => fallbackCalls++,
      );

      expect(
        await dispatcher.invokeCallback(Future.value(false)),
        isFalse,
        reason: '$path is a valid app root',
      );
      expect(fallbackCalls, 0);
    }
  });

  test('predictive back is claimed for a single-page non-home route', () {
    expect(
      shouldHandleSystemBack(
        notificationCanHandlePop: false,
        currentUri: Uri.parse('/details?source=notification'),
      ),
      isTrue,
    );
  });

  test('predictive back is not claimed at valid app roots', () {
    for (final path in appExitRootPaths) {
      expect(
        shouldHandleSystemBack(
          notificationCanHandlePop: false,
          currentUri: Uri.parse('$path?source=launcher'),
        ),
        isFalse,
        reason: '$path is allowed to exit when it has no route history',
      );
    }
  });

  test('profile completion is protected from an immediate app exit', () {
    expect(
      shouldHandleSystemBack(
        notificationCanHandlePop: false,
        currentUri: Uri.parse('/complete-profile'),
      ),
      isTrue,
    );
  });

  test('navigator pop still claims predictive back at an app root', () {
    expect(
      shouldHandleSystemBack(
        notificationCanHandlePop: true,
        currentUri: Uri.parse('/'),
      ),
      isTrue,
    );
  });

  test('predictive back channel is skipped before attach and after detach', () {
    expect(canReportSystemBackToPlatform(null), isFalse);
    expect(
      canReportSystemBackToPlatform(AppLifecycleState.detached),
      isFalse,
    );
    expect(
      canReportSystemBackToPlatform(AppLifecycleState.resumed),
      isTrue,
    );
  });

  testWidgets(
      'navigation notification reports deep-link back handling to Android',
      (tester) async {
    final frameworkHandlesBack = <bool>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
        frameworkHandlesBack.add(call.arguments as bool);
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    late GoRouter router;
    final dispatcher = HomeFallbackBackButtonDispatcher(
      currentUri: () => router.state.uri,
      goHome: () => router.go('/'),
    );
    router = _router(initialLocation: '/details');
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        backButtonDispatcher: dispatcher,
        onNavigationNotification: (notification) =>
            handleSystemBackNavigationNotification(
          notification,
          currentUri: router.state.uri,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(frameworkHandlesBack.last, isTrue);

    router.go('/');
    await tester.pumpAndSettle();

    expect(frameworkHandlesBack.last, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

GoRouter _router({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
      GoRoute(
        path: '/details',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Details')),
        ),
      ),
    ],
  );
}

Future<void> _pumpRouter(
  WidgetTester tester,
  GoRouter router,
  BackButtonDispatcher dispatcher,
) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: dispatcher,
    ),
  );
  await tester.pumpAndSettle();
}
