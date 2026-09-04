import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/branding/partner_brands.dart';
import 'package:triva_app/features/home/presentation/home_screen.dart';
import 'package:triva_app/features/home_banner/domain/home_banner_models.dart';
import 'package:triva_app/features/home_banner/presentation/home_banner_controller.dart';
import 'package:triva_app/features/home_banner/presentation/home_banner_slider.dart';
import 'package:triva_app/features/promotion/domain/promotion_models.dart';
import 'package:triva_app/features/promotion/presentation/promotion_controller.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';

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
    bool vehicleLoadFails = false,
    List<Promotion> promotions = const [],
    List<HomeBanner> banners = const [],
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
          toyotaServiceVehiclesProvider.overrideWith((ref) async {
            if (vehicleLoadFails) throw StateError('offline');
            return const [];
          }),
          runningPromotionsProvider.overrideWith((ref) async => promotions),
          runningHomeBannersProvider.overrideWith((ref) async => banners),
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

  testWidgets('tool tiles moved out of home and banner slider shows',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      banners: const [
        HomeBanner(
          id: 'b1',
          title: 'Banner satu',
          imageUrl: 'https://example.test/b1.jpg',
        ),
        HomeBanner(
          id: 'b2',
          title: 'Banner dua',
          imageUrl: 'https://example.test/b2.jpg',
          linkUrl: 'https://auto2000.co.id',
        ),
      ],
    );
    await tester.pump();

    expect(find.text('Cek No. Rangka'), findsNothing);
    expect(find.text('Simulasi biaya servis'), findsNothing);
    expect(find.byType(HomeBannerSlider), findsOneWidget);
    expect(find.text('Booking OtoXpert'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('banner slider is hidden when no banner is running',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
    );
    await tester.pump();

    expect(find.byType(HomeBannerSlider), findsNothing);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('credit simulation row carries both financing partner logos',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
    );

    List<PartnerBrand> brandsOfRow(String title) {
      final row = find
          .ancestor(of: find.text(title), matching: find.byType(InkWell))
          .first;
      return tester
          .widgetList<PartnerLogo>(
            find.descendant(of: row, matching: find.byType(PartnerLogo)),
          )
          .map((logo) => logo.brand)
          .toList();
    }

    expect(
      brandsOfRow('Simulasi kredit'),
      containsAllInOrder(<PartnerBrand>[PartnerBrand.acc, PartnerBrand.taf]),
    );
    // Mitra ganda hanya untuk simulasi kredit; layanan lain tetap satu logo.
    expect(brandsOfRow('Booking servis Toyota'),
        <PartnerBrand>[PartnerBrand.auto2000]);
    expect(
        brandsOfRow('Booking OtoXpert'), <PartnerBrand>[PartnerBrand.otoxpert]);
    expect(brandsOfRow('Estimasi Body & Paint'),
        <PartnerBrand>[PartnerBrand.auto2000]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('partner strip carries all five partners including OLX',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
    );

    final strip = find.ancestor(
      of: find.text('Mitra resmi'),
      matching: find.byType(Column),
    );
    await tester.scrollUntilVisible(
      find.text('Mitra resmi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    final brands = tester
        .widgetList<PartnerLogo>(
          find.descendant(of: strip.first, matching: find.byType(PartnerLogo)),
        )
        .map((logo) => logo.brand)
        .toSet();

    expect(
      brands,
      containsAll(<PartnerBrand>[
        PartnerBrand.auto2000,
        PartnerBrand.otoxpert,
        PartnerBrand.olx,
        PartnerBrand.acc,
        PartnerBrand.taf,
      ]),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('running promos appear as a carousel on the home page',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
      promotions: const [
        Promotion(
          id: 'promo-1',
          category: 'sales',
          categoryLabel: 'Sales',
          title: 'Tukar tambah Agustus',
          subtitle: 'Bonus aksesori senilai 5 juta',
          startsOn: '2026-08-01',
          endsOn: '2026-08-31',
        ),
        Promotion(
          id: 'promo-2',
          category: 'otoxpert',
          categoryLabel: 'OtoXpert',
          title: 'Servis hemat OtoXpert',
          startsOn: '2026-08-01',
          endsOn: '2026-08-31',
        ),
      ],
    );
    await tester.pump();

    expect(find.text('Promo bulan ini'), findsOneWidget);
    expect(find.text('Tukar tambah Agustus'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the home page stays clean when no promo is running',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
    );
    await tester.pump();

    expect(find.text('Promo bulan ini'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vehicle API failure is not misrepresented as an empty garage',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      vehicleLoadFails: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('Data belum dapat dimuat.'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.text('Belum ada kendaraan'), findsNothing);
  });
}
