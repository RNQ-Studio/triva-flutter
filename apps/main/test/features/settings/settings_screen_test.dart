import 'package:triva_app/features/settings/presentation/settings_screen.dart';
import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({ThemeMode mode = ThemeMode.system}) => ProviderScope(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(mode)),
          localeProvider
              .overrideWith(() => _FakeLocaleNotifier(const Locale('id'))),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsScreen(),
        ),
      );

  testWidgets('shows Appearance and Language sections', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('shows all three theme options', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('Use system setting'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}

class _FakeThemeNotifier extends ThemeNotifier {
  _FakeThemeNotifier(this._mode);
  final ThemeMode _mode;

  @override
  Future<ThemeMode> build() async => _mode;
}

class _FakeLocaleNotifier extends LocaleNotifier {
  _FakeLocaleNotifier(this._locale);
  final Locale _locale;

  @override
  Future<Locale> build() async => _locale;
}
