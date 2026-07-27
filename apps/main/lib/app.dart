import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'router/app_router.dart';
import 'features/appraisal/presentation/appraisal_controller.dart';
import 'features/credit/presentation/credit_controller.dart';
import 'features/toyota_service/presentation/toyota_service_controller.dart';
import 'features/otoxpert/presentation/otoxpert_controller.dart';

Future<void> syncPushTokenSafely({
  required Future<String?> Function() getToken,
  required Future<void> Function(String token) register,
}) async {
  try {
    final token = await getToken();
    if (token != null) await register(token);
  } on Object {
    // APNS/FCM can be unavailable temporarily; token refresh retries later.
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.storage, required this.database});

  final StorageService storage;
  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();

  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter> {
  final _fcm = FCMNotificationService();
  String? _pendingNotificationRoute;
  String? _authenticatedUserId;
  String? _registeredPushIdentity;
  final _pushRegistrationsInFlight = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkCurrentUser();
      _initializeNotifications();
    });
    ref.listenManual(authProvider, (_, next) {
      final nextUserId = next is AuthAuthenticated ? next.user.id : null;
      final identityChanged = _authenticatedUserId != null &&
          nextUserId != null &&
          _authenticatedUserId != nextUserId;
      final signedOut =
          _authenticatedUserId != null && next is AuthUnauthenticated;
      if (identityChanged || signedOut) {
        _invalidateUserScopedState();
        _registeredPushIdentity = null;
      }
      if (nextUserId != null || next is AuthUnauthenticated) {
        _authenticatedUserId = nextUserId;
      }
      appRouter.refresh();
      if (next is AuthAuthenticated) {
        unawaited(_syncPushToken());
        final pending = _pendingNotificationRoute;
        if (pending != null) {
          _pendingNotificationRoute = null;
          appRouter.go(pending);
        }
      }
    });
  }

  Future<void> _syncPushToken() async {
    await syncPushTokenSafely(
      getToken: _fcm.getToken,
      register: _registerDevice,
    );
  }

  void _invalidateUserScopedState() {
    ref.invalidate(appraisalsProvider);
    ref.invalidate(toyotaServiceVehiclesProvider);
    ref.invalidate(toyotaServiceBookingsProvider);
    ref.invalidate(toyotaServiceFlowProvider);
    ref.invalidate(otoxpertVehiclesProvider);
    ref.invalidate(otoxpertBookingsProvider);
    ref.invalidate(otoxpertFlowProvider);
    ref.invalidate(creditProgramsProvider);
    ref.invalidate(creditSimulationsProvider);
    ref.invalidate(creditFlowProvider);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> _initializeNotifications() async {
    try {
      await _fcm.init(
        onForegroundMessage: (_) {
          ref.invalidate(notificationsListProvider);
          ref.invalidate(unreadNotificationCountProvider);
        },
        onMessageOpenedApp: _openNotification,
        onTokenChanged: _registerDevice,
      );
    } on Object {
      // Push is best-effort; the API-backed inbox remains available.
    }
  }

  void _openNotification(RemoteMessage message) {
    final route = message.data['route']?.toString();
    final type = message.data['type']?.toString();
    final otoxpertId = message.data['otoxpert_booking_id']?.toString() ??
        (type == 'otoxpert_booking'
            ? message.data['booking_id']?.toString()
            : null);
    final toyotaId = message.data['toyota_service_booking_id']?.toString() ??
        (type == 'toyota_service_booking'
            ? message.data['booking_id']?.toString()
            : null);
    final creditId = message.data['credit_simulation_id']?.toString() ??
        (type == 'credit_simulation'
            ? message.data['simulation_id']?.toString()
            : null);
    final target = creditId != null
        ? '/credit/simulations/$creditId'
        : otoxpertId != null
            ? '/otoxpert/bookings/$otoxpertId'
            : toyotaId != null
                ? '/toyota-service/bookings/$toyotaId'
                : route != null &&
                        (route.startsWith('/toyota-service/bookings/') ||
                            route.startsWith('/otoxpert/bookings/') ||
                            route.startsWith('/credit/simulations/'))
                    ? route
                    : null;
    if (target == null) return;
    if (ref.read(authProvider) is AuthAuthenticated) {
      appRouter.go(target);
    } else {
      _pendingNotificationRoute = target;
    }
  }

  Future<void> _registerDevice(String token) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    final registrationIdentity = '${auth.user.id}:$token';
    if (_registeredPushIdentity == registrationIdentity ||
        !_pushRegistrationsInFlight.add(registrationIdentity)) {
      return;
    }
    try {
      final storage = ref.read(storageServiceProvider);
      var deviceId = await storage.read('triva.device_id');
      if (deviceId == null) {
        final random = Random.secure();
        deviceId = List.generate(
          32,
          (_) => random.nextInt(16).toRadixString(16),
        ).join();
        await storage.write('triva.device_id', deviceId);
      }
      final package = await PackageInfo.fromPlatform();
      final platform = kIsWeb
          ? 'web'
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => 'android',
              TargetPlatform.iOS => 'ios',
              _ => 'web',
            };
      await DioClient(
        storage,
        onLogout: () => ref.read(authProvider.notifier).expireSession(),
      ).dio.post<dynamic>(
        'v1/auth/device',
        data: {
          'device_id': deviceId,
          'platform': platform,
          'os_version': defaultTargetPlatform.name,
          'app_version': package.version,
          'app_build': package.buildNumber,
          'device_name': kIsWeb ? 'Web browser' : defaultTargetPlatform.name,
          'push_token': token,
        },
      );
      _registeredPushIdentity = registrationIdentity;
    } on Object {
      // Token refresh will retry; do not disturb the signed-in session.
    } finally {
      _pushRegistrationsInFlight.remove(registrationIdentity);
    }
  }

  @override
  void dispose() {
    _fcm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(themeProvider).asData?.value ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).asData?.value;

    return MaterialApp.router(
      title: 'TRIVA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) => WebMobileViewport(
        enabled: kIsWeb,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
