import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

class _LoadingAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthLoading();
}

class _NetworkErrorAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthError(AuthFailureKind.network);
}

Widget _testApp({
  required Widget home,
  required ThemeData theme,
  double textScale = 1.3,
  AuthNotifier Function() authNotifier = _FakeAuthNotifier.new,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(authNotifier),
    ],
    child: MaterialApp(
      theme: theme,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
      home: home,
    ),
  );
}

void main() {
  Future<void> setCompactViewport(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final brightness in Brightness.values) {
    final theme =
        brightness == Brightness.light ? AppTheme.light : AppTheme.dark;

    testWidgets(
      'login is overflow-free in compact ${brightness.name} theme',
      (tester) async {
        await setCompactViewport(tester);
        await tester.pumpWidget(
          _testApp(
            home: const LoginScreen(),
            theme: theme,
          ),
        );
        await tester.pump();

        expect(find.text('Masuk ke TRIVA'), findsOneWidget);
        expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'onboarding is overflow-free in compact ${brightness.name} theme',
      (tester) async {
        await setCompactViewport(tester);
        await tester.pumpWidget(
          _testApp(
            home: const OnboardingScreen(),
            theme: theme,
          ),
        );
        await tester.pump();

        expect(find.text('Kenali nilai kendaraan'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'splash is overflow-free in compact ${brightness.name} theme',
      (tester) async {
        await setCompactViewport(tester);
        await tester.pumpWidget(
          _testApp(
            home: const SplashScreen(),
            theme: theme,
          ),
        );
        await tester.pump(Durations.short2);

        expect(find.text('Upload, Appraise, Upgrade'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('onboarding remains usable at 2.0 text scaling', (tester) async {
    await setCompactViewport(tester);
    await tester.pumpWidget(
      _testApp(
        home: const OnboardingScreen(),
        theme: AppTheme.light,
        textScale: 2,
      ),
    );
    await tester.pump();

    expect(find.text('Selanjutnya'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google login loading state is compact and disabled',
      (tester) async {
    await setCompactViewport(tester);
    await tester.pumpWidget(
      _testApp(
        home: const LoginScreen(),
        theme: AppTheme.light,
        authNotifier: _LoadingAuthNotifier.new,
      ),
    );

    expect(find.text('Menghubungkan akun Google…'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('google-sign-in-button')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google login network error explains retry', (tester) async {
    await setCompactViewport(tester);
    await tester.pumpWidget(
      _testApp(
        home: const LoginScreen(),
        theme: AppTheme.dark,
        authNotifier: _NetworkErrorAuthNotifier.new,
      ),
    );

    expect(
      find.text(
        'Koneksi ke Google terputus. Periksa internet Anda lalu coba lagi.',
      ),
      findsOneWidget,
    );
    expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
