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
import 'package:triva_app/features/info_popup/domain/info_popup_models.dart';
import 'package:triva_app/features/info_popup/presentation/info_popup_controller.dart';
import 'package:triva_app/features/info_popup/presentation/info_popup_dialog.dart';
import 'package:triva_app/features/partner_logo/domain/partner_logo_models.dart'
    as partner;
import 'package:triva_app/features/partner_logo/presentation/partner_logo_controller.dart';
import 'package:triva_app/features/partner_logo/presentation/partner_logo_strip.dart';
import 'package:triva_app/features/promotion/domain/promotion_models.dart';
import 'package:triva_app/features/promotion/presentation/promotion_controller.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';

class _MemoryStorage implements StorageService {
  final values = <String, String>{};

  @override
  Future<void> init() async {}

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

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
    List<InfoPopup> infoPopups = const [],
    // null meniru server Mitra resmi yang tidak terjangkau.
    List<partner.PartnerLogo>? partnerLogos,
    StorageService? storage,
  }) async {
    final popupStorage = storage ?? _MemoryStorage();
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
          runningInfoPopupsProvider.overrideWith((ref) async => infoPopups),
          activePartnerLogosProvider.overrideWith((ref) async {
            if (partnerLogos == null) throw StateError('offline');
            return partnerLogos;
          }),
          infoPopupScheduleProvider.overrideWithValue(
            InfoPopupSchedule(popupStorage),
          ),
          seenPromotionPopupsProvider.overrideWithValue(
            SeenPromotionPopups(popupStorage),
          ),
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

  testWidgets(
      'partner strip falls back to all five partners including OLX '
      'when the partner list cannot be loaded', (tester) async {
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

  testWidgets('partner strip shows the logos managed from the admin panel',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
      partnerLogos: const [
        partner.PartnerLogo(
          id: 'p1',
          name: 'Auto2000',
          logoUrl: 'https://example.test/auto2000.png',
          linkUrl: 'https://auto2000.co.id',
        ),
        partner.PartnerLogo(
          id: 'p2',
          name: 'Mitra Baru',
          logoUrl: 'https://example.test/baru.png',
        ),
      ],
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Mitra resmi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(PartnerNetworkLogoPlate), findsNWidgets(2));
    final strip = find.byType(PartnerLogoStrip);
    expect(
      find.descendant(of: strip, matching: find.byType(PartnerLogo)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('partner section hides when every logo is deactivated',
      (tester) async {
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      partnerLogos: const [],
    );
    await tester.pump();

    expect(find.text('Mitra resmi'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'due info pop-ups open as slides once and take priority over the promo '
      'pop-up', (tester) async {
    final storage = _MemoryStorage();
    const promo = Promotion(
      id: 'promo-1',
      category: 'sales',
      categoryLabel: 'Sales',
      title: 'Promo pop-up',
      startsOn: '2026-10-01',
      showAsPopup: true,
    );
    final popups = [
      InfoPopup.fromJson({
        'id': 'second',
        'title': 'Info kedua',
        'image_url': 'https://example.test/second.jpg',
        'sort_order': 2,
        'interval_hours': 24,
        'updated_at': '2026-10-06T01:00:00.000Z',
      }),
      InfoPopup.fromJson({
        'id': 'first',
        'title': 'Info pertama',
        'image_url': 'https://example.test/first.jpg',
        'button_label': 'Lihat promo',
        'button_url': 'https://auto2000.co.id/promo',
        'sort_order': 1,
        'interval_hours': 24,
        'updated_at': '2026-10-06T01:00:00.000Z',
      }),
    ];

    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
      infoPopups: popups,
      promotions: const [promo],
      storage: storage,
    );
    await tester.pumpAndSettle();

    final dialog = tester.widget<InfoPopupDialog>(find.byType(InfoPopupDialog));
    expect(dialog.popups.map((popup) => popup.id), ['first', 'second']);
    expect(find.text('Lihat promo'), findsOneWidget);
    // Pop-up promo memakai AlertDialog; judulnya sendiri juga tampil di
    // carousel beranda.
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(InfoPopupDialog), findsNothing);
    expect(storage.values.keys, contains('info_popup_last_shown_v1'));

    // Masih dalam jeda 24 jam: membuka beranda lagi tidak memunculkan
    // popup yang sama, dan promo pop-up mendapat gilirannya.
    await tester.pumpWidget(const SizedBox());
    await pumpHome(
      tester,
      theme: AppTheme.light,
      authState: const AuthUnauthenticated(),
      textScale: 1,
      infoPopups: popups,
      promotions: const [promo],
      storage: storage,
    );
    await tester.pumpAndSettle();

    expect(find.byType(InfoPopupDialog), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Promo pop-up'),
      ),
      findsOneWidget,
    );
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
