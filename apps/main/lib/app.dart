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

String? notificationTarget(Map<String, dynamic> data) {
  String? safeId(String key) {
    final value = data[key]?.toString();
    return value != null && RegExp(r'^[A-Za-z0-9-]+$').hasMatch(value)
        ? value
        : null;
  }

  final route = data['route']?.toString();
  final type = data['type']?.toString();
  final appraisalId = safeId('appraisal_id');
  final bodyPaintId = safeId('body_paint_estimate_id') ??
      (type == 'body_paint_estimate' ? safeId('estimate_id') : null);
  final otoxpertId = safeId('otoxpert_booking_id') ??
      (type == 'otoxpert_booking' ? safeId('booking_id') : null);
  final toyotaId = safeId('toyota_service_booking_id') ??
      (type == 'toyota_service_booking' ? safeId('booking_id') : null);
  final creditId = safeId('credit_simulation_id') ??
      (type == 'credit_simulation' ? safeId('simulation_id') : null);

  if (appraisalId != null) {
    return type == 'appraisal_result_ready' ||
            route == '/appraisals/$appraisalId/result'
        ? '/appraisals/$appraisalId/result'
        : '/appraisals/$appraisalId';
  }
  if (bodyPaintId != null) return '/body-paint/estimates/$bodyPaintId';
  if (creditId != null) return '/credit/simulations/$creditId';
  if (otoxpertId != null) return '/otoxpert/bookings/$otoxpertId';
  if (toyotaId != null) return '/toyota-service/bookings/$toyotaId';
  if (route == null) return null;

  return [
    RegExp(r'^/appraisals/[A-Za-z0-9-]+(?:/result)?$'),
    RegExp(r'^/body-paint/estimates/[A-Za-z0-9-]+$'),
    RegExp(r'^/toyota-service/bookings/[A-Za-z0-9-]+$'),
    RegExp(r'^/otoxpert/bookings/[A-Za-z0-9-]+$'),
    RegExp(r'^/credit/simulations/[A-Za-z0-9-]+$'),
  ].any((pattern) => pattern.hasMatch(route))
      ? route
      : null;
}

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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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
        onForegroundMessage: _handleForegroundNotification,
        onMessageOpenedApp: _openNotification,
        onTokenChanged: _registerDevice,
      );
    } on Object {
      // Push is best-effort; the API-backed inbox remains available.
    }
  }

  void _handleForegroundNotification(RemoteMessage message) {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
    final appraisalId = message.data['appraisal_id']?.toString();
    if (appraisalId != null) {
      ref.invalidate(appraisalsProvider);
      ref.invalidate(appraisalDetailProvider(appraisalId));
    }

    final notification = message.notification;
    if (notification == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = _scaffoldMessengerKey.currentState;
      final messengerContext = messenger?.context;
      if (messenger == null || messengerContext == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
            content: Text(
              [
                if (notification.title?.isNotEmpty == true) notification.title!,
                if (notification.body?.isNotEmpty == true) notification.body!,
              ].join('\n'),
            ),
            action: notificationTarget(message.data) == null
                ? null
                : SnackBarAction(
                    label: AppLocalizations.of(messengerContext)!
                        .notificationOpenAction,
                    onPressed: () => _openNotification(message),
                  ),
          ),
        );
    });
  }

  void _openNotification(RemoteMessage message) {
    final target = notificationTarget(message.data);
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
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
