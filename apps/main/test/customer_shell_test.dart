import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/router/customer_shell.dart';

void main() {
  testWidgets('keeps bottom navigation visible across customer tabs',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => CustomerShell(
            navigationShell: navigationShell,
            unreadNotificationCount: 0,
          ),
          branches: [
            _branch('/', 'Beranda aktif'),
            _branch('/activity', 'Aktivitas aktif'),
            _branch('/notifications', 'Notifikasi aktif'),
            _branch('/profile', 'Profil aktif'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beranda aktif'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Aktivitas'));
    await tester.pumpAndSettle();
    expect(find.text('Aktivitas aktif'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi aktif'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profil aktif'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('bottom navigation never exposes Admin Panel', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => CustomerShell(
            navigationShell: navigationShell,
            unreadNotificationCount: 0,
          ),
          branches: [
            _branch('/', 'Beranda aktif'),
            _branch('/activity', 'Aktivitas aktif'),
            _branch('/notifications', 'Notifikasi aktif'),
            _branch('/profile', 'Profil aktif'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil aktif'), findsOneWidget);
    expect(find.text('Admin Panel'), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
      hasLength(4),
    );
    expect(tester.takeException(), isNull);
  });
}

StatefulShellBranch _branch(String path, String label) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => Scaffold(
          body: Center(child: Text(label)),
        ),
      ),
    ],
  );
}
