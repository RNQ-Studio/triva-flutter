import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfileAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        User(
          id: 'user-1',
          name: 'Ramadhan Rosihadi',
          email: 'ramadhan@example.com',
        ),
      );
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'profile setup is compact and overflow-free in ${brightness.name}',
      (tester) async {
        tester.view
          ..physicalSize = const Size(360, 690)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(_ProfileAuthNotifier.new),
            ],
            child: MaterialApp(
              theme: brightness == Brightness.light
                  ? AppTheme.light
                  : AppTheme.dark,
              locale: const Locale('id'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              ),
              home: const CompleteProfileScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Lengkapi profil Anda'), findsOneWidget);
        expect(find.text('Nomor ponsel'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
