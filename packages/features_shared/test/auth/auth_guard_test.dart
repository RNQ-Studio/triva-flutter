import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _LoginFlowAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();

  @override
  Future<void> loginWithGoogle() async {
    state = const AuthAuthenticated(
      User(
        id: 'user-1',
        name: 'TRIVA Customer',
        email: 'customer@example.com',
      ),
    );
  }

  void completeProfile() {
    state = const AuthAuthenticated(
      User(
        id: 'user-1',
        name: 'TRIVA Customer',
        email: 'customer@example.com',
        profileCompleted: true,
        demographicsCompleted: true,
      ),
    );
  }
}

void main() {
  group('safeAuthReturnLocation', () {
    test('keeps internal paths including query and fragment', () {
      expect(
        safeAuthReturnLocation('/activity?filter=pending#timeline'),
        '/activity?filter=pending#timeline',
      );
      expect(safeAuthReturnLocation('/'), '/');
    });

    test('rejects external, malformed, and authentication destinations', () {
      for (final destination in <String?>[
        null,
        '',
        ' /activity',
        'activity',
        'https://evil.example/steal',
        '//evil.example/steal',
        r'/\evil.example',
        '/activity\next',
        '/activity\n',
        '/login',
        '/login?from=%2Factivity',
        '/complete-profile',
        '/splash',
      ]) {
        expect(
          safeAuthReturnLocation(destination),
          isNull,
          reason: '$destination must not be used as a post-auth route',
        );
      }
    });
  });

  testWidgets(
    'deep link survives login and required profile completion',
    (tester) async {
      late _LoginFlowAuthNotifier notifier;
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() {
            notifier = _LoginFlowAuthNotifier();
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/activity?filter=pending',
        redirect: authRedirect,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Text('HOME'),
          ),
          GoRoute(
            path: authLoginPath,
            builder: (_, state) => LoginScreen(
              returnTo: state.uri.queryParameters['from'],
            ),
          ),
          GoRoute(
            path: completeProfilePath,
            builder: (_, __) => const Text('PROFILE'),
          ),
          GoRoute(
            path: '/activity',
            builder: (_, __) => const Text('ACTIVITY'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            locale: const Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.path, authLoginPath);
      expect(
        router.state.uri.queryParameters['from'],
        '/activity?filter=pending',
      );

      await tester.tap(find.byKey(const ValueKey('google-sign-in-button')));
      await tester.pumpAndSettle();

      expect(find.text('PROFILE'), findsOneWidget);
      expect(router.state.uri.path, completeProfilePath);
      expect(
        router.state.uri.queryParameters['from'],
        '/activity?filter=pending',
      );

      notifier.completeProfile();
      router.refresh();
      await tester.pumpAndSettle();

      expect(find.text('ACTIVITY'), findsOneWidget);
      expect(router.state.uri.toString(), '/activity?filter=pending');
      expect(tester.takeException(), isNull);
    },
  );
}
