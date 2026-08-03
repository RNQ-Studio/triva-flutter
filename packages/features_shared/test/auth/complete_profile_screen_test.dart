import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _ProfileAuthNotifier extends AuthNotifier {
  int? submittedProvinceId;
  int? submittedCityId;

  @override
  AuthState build() => const AuthAuthenticated(
        User(
          id: 'user-1',
          name: 'Ramadhan Rosihadi',
          email: 'ramadhan@example.com',
        ),
      );

  @override
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? phone,
    String? city,
    int? provinceId,
    int? cityId,
    bool? serviceConsent,
    bool? marketingConsent,
  }) async {
    submittedProvinceId = provinceId;
    submittedCityId = cityId;
  }
}

const _regionOptions = [
  ProvinceOption(
    id: 35,
    code: '35',
    name: 'JAWA TIMUR',
    cities: [
      CityOption(
        id: 3578,
        code: '3578',
        name: 'KOTA SURABAYA',
      ),
    ],
  ),
];

void main() {
  for (final brightness in Brightness.values) {
    for (final textScale in [1.3, 2.0]) {
      testWidgets(
        'profile setup is overflow-free in ${brightness.name} at '
        '${textScale}x text',
        (tester) async {
          tester.view
            ..physicalSize = const Size(360, 690)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authProvider.overrideWith(_ProfileAuthNotifier.new),
                provinceOptionsProvider.overrideWith(
                  (ref) async => _regionOptions,
                ),
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
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                ),
                home: const CompleteProfileScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Lengkapi profil Anda'), findsOneWidget);
          expect(find.text('Nomor ponsel'), findsOneWidget);
          expect(find.text('Provinsi'), findsOneWidget);
          expect(find.text('Kota/kabupaten'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('back preserves return route and profile setup sends region IDs',
      (tester) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late _ProfileAuthNotifier notifier;
    final router = GoRouter(
      initialLocation: '/complete-profile?from=%2Factivity%3Ffilter%3Dpending',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Beranda'),
          ),
        ),
        GoRoute(
          path: '/complete-profile',
          builder: (context, state) => CompleteProfileScreen(
            returnTo: state.uri.queryParameters['from'],
          ),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const Scaffold(
            body: Text('Aktivitas'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() {
            notifier = _ProfileAuthNotifier();
            return notifier;
          }),
          provinceOptionsProvider.overrideWith(
            (ref) async => _regionOptions,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/complete-profile');
    expect(
      router.state.uri.queryParameters['from'],
      '/activity?filter=pending',
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      '+6281234567890',
    );
    final provinceDropdown = find.byType(DropdownButtonFormField<int>).first;
    await tester.ensureVisible(provinceDropdown);
    await tester.tap(provinceDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('JAWA TIMUR').last);
    await tester.pumpAndSettle();
    final cityDropdown = find.byType(DropdownButtonFormField<int>).last;
    await tester.ensureVisible(cityDropdown);
    await tester.tap(cityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('KOTA SURABAYA').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.ensureVisible(find.text('Simpan dan lanjutkan'));
    await tester.tap(find.text('Simpan dan lanjutkan'));
    await tester.pumpAndSettle();

    expect(notifier.submittedProvinceId, 35);
    expect(notifier.submittedCityId, 3578);
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(router.state.uri.toString(), '/activity?filter=pending');
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile setup offers retry when region loading fails',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_ProfileAuthNotifier.new),
          provinceOptionsProvider.overrideWith(
            (ref) => Future<List<ProvinceOption>>.error(
              const NetworkException('offline'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CompleteProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Pilihan wilayah belum dapat dimuat. '
        'Periksa koneksi lalu coba lagi.',
      ),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile setup explains when region master is empty',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_ProfileAuthNotifier.new),
          provinceOptionsProvider.overrideWith(
            (ref) async => const <ProvinceOption>[],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CompleteProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Master provinsi dan kota belum tersedia.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
