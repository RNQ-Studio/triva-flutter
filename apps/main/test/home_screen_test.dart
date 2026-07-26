import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';
import 'package:triva_app/features/home/presentation/home_screen.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.initialState);

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required ThemeData theme,
    required AuthState authState,
    double textScale = 1.3,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _FakeAuthNotifier(authState),
          ),
          appraisalsProvider.overrideWith((ref) async => const []),
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
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'renders compact guest home without overflow in ${brightness.name}',
      (tester) async {
        await pumpHome(
          tester,
          theme:
              brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
          authState: const AuthUnauthenticated(),
        );

        expect(find.text('Apa kebutuhan kendaraan Anda hari ini?'),
            findsOneWidget);
        expect(find.text('Mulai appraisal'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('remains usable at 2.0 text scaling', (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthAuthenticated(
        User(
          id: 'user-1',
          name: 'Ramadhan',
          email: 'ramadhan@example.com',
          profileCompleted: true,
        ),
      ),
      textScale: 2,
    );

    expect(find.text('Halo, Ramadhan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
