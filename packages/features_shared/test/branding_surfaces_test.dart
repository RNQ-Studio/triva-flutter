import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

Widget _testApp({
  required Widget home,
  required ThemeData theme,
  double textScale = 1.3,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuthNotifier.new),
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
}
