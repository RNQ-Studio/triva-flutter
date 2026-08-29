import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_routes.dart';
import 'package:triva_app/router/app_router.dart';

class _MutableAuthNotifier extends AuthNotifier {
  _MutableAuthNotifier(this.initialUser);

  final User initialUser;

  @override
  AuthState build() => AuthAuthenticated(initialUser);

  void replacePermissions(List<String> permissions) {
    state = AuthAuthenticated(
      User(
        id: initialUser.id,
        name: initialUser.name,
        email: initialUser.email,
        profileCompleted: true,
        demographicsCompleted: true,
        permissions: permissions,
      ),
    );
  }
}

void main() {
  testWidgets('Admin Panel exposes user access management to admins',
      (tester) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _MutableAuthNotifier(
              _user(
                const [
                  'users.viewAny',
                  'users.update',
                  'service_bookings.viewAny',
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: const AdminPanelScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kelola akses admin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct admin routes redirect users without exact capability',
      (tester) async {
    final harness = _RouterHarness(
      initialLocation: '/admin',
      user: _user(const []),
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('ADMIN'), findsNothing);
  });

  testWidgets('visit analytics permission grants the Admin Panel dashboard',
      (tester) async {
    final harness = _RouterHarness(
      initialLocation: '/admin',
      user: _user(const ['analytics.viewAny']),
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    expect(find.text('ADMIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('view grants detail only while viewAny grants queue',
      (tester) async {
    final detailHarness = _RouterHarness(
      initialLocation: '/admin/toyota-service/bookings/booking-1',
      user: _user(const ['service_bookings.view']),
    );
    addTearDown(detailHarness.dispose);

    await tester.pumpWidget(detailHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('DETAIL'), findsOneWidget);

    final queueHarness = _RouterHarness(
      initialLocation: '/admin/toyota-service/bookings',
      user: _user(const ['service_bookings.view']),
    );
    addTearDown(queueHarness.dispose);

    await tester.pumpWidget(queueHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('QUEUE'), findsNothing);
  });

  testWidgets('revoked viewAny permission redirects an open admin route',
      (tester) async {
    final harness = _RouterHarness(
      initialLocation: '/admin',
      user: _user(const ['service_bookings.viewAny']),
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();
    expect(find.text('ADMIN'), findsOneWidget);

    harness.notifier.replacePermissions(const []);
    harness.router.refresh();
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('ADMIN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Body Paint capabilities do not grant Toyota queue access',
      (tester) async {
    final bodyPaintHarness = _RouterHarness(
      initialLocation: '/admin/body-paint/estimates',
      user: _user(const ['bp_estimates.viewAny']),
    );
    addTearDown(bodyPaintHarness.dispose);

    await tester.pumpWidget(bodyPaintHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('BP_QUEUE'), findsOneWidget);

    final toyotaHarness = _RouterHarness(
      initialLocation: '/admin/toyota-service/bookings',
      user: _user(const ['bp_estimates.viewAny']),
    );
    addTearDown(toyotaHarness.dispose);

    await tester.pumpWidget(toyotaHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('QUEUE'), findsNothing);
  });

  testWidgets('user management route requires both user permissions',
      (tester) async {
    final allowedHarness = _RouterHarness(
      initialLocation: '/admin/users',
      user: _user(const ['users.viewAny', 'users.update']),
    );
    addTearDown(allowedHarness.dispose);

    await tester.pumpWidget(allowedHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('USERS'), findsOneWidget);

    final deniedHarness = _RouterHarness(
      initialLocation: '/admin/users',
      user: _user(const ['users.viewAny']),
    );
    addTearDown(deniedHarness.dispose);

    await tester.pumpWidget(deniedHarness.app);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('USERS'), findsNothing);
  });
}

User _user(List<String> permissions) => User(
      id: 'user-1',
      name: 'Admin',
      email: 'admin@example.com',
      profileCompleted: true,
      demographicsCompleted: true,
      permissions: permissions,
    );

class _RouterHarness {
  _RouterHarness({
    required String initialLocation,
    required User user,
  }) : container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(() => _MutableAuthNotifier(user)),
          ],
        ) {
    router = GoRouter(
      initialLocation: initialLocation,
      redirect: trivaAppRedirect,
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('HOME')),
        GoRoute(path: '/login', builder: (_, __) => const Text('LOGIN')),
        GoRoute(
          path: '/complete-profile',
          builder: (_, __) => const Text('PROFILE'),
        ),
        GoRoute(path: '/splash', builder: (_, __) => const Text('SPLASH')),
        GoRoute(path: '/admin', builder: (_, __) => const Text('ADMIN')),
        GoRoute(
          path: '/admin/toyota-service/bookings',
          builder: (_, __) => const Text('QUEUE'),
        ),
        GoRoute(
          path: '/admin/toyota-service/bookings/:id',
          builder: (_, __) => const Text('DETAIL'),
        ),
        GoRoute(
          path: '/admin/body-paint/estimates',
          builder: (_, __) => const Text('BP_QUEUE'),
        ),
        GoRoute(
          path: '/admin/body-paint/estimates/:id',
          builder: (_, __) => const Text('BP_DETAIL'),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const Text('USERS'),
        ),
      ],
    );
  }

  final ProviderContainer container;
  late final GoRouter router;
  _MutableAuthNotifier get notifier =>
      container.read(authProvider.notifier) as _MutableAuthNotifier;

  Widget get app => UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );

  void dispose() {
    router.dispose();
    container.dispose();
  }
}
