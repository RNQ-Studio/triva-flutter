import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/visit_analytics/data/admin_demographics_repository.dart';
import 'package:triva_app/features/visit_analytics/data/admin_menu_usage_repository.dart';
import 'package:triva_app/features/visit_analytics/domain/demographics_models.dart';
import 'package:triva_app/features/visit_analytics/domain/menu_usage_models.dart';
import 'package:triva_app/features/visit_analytics/domain/visit_analytics_models.dart';
import 'package:triva_app/features/visit_analytics/presentation/admin_demographics_section.dart';
import 'package:triva_app/features/visit_analytics/presentation/admin_menu_usage_section.dart';
import 'package:triva_app/features/visit_analytics/presentation/visit_analytics_controller.dart';

class _MockDemographicsRepository extends Mock
    implements AdminDemographicsRepository {}

class _MockMenuUsageRepository extends Mock
    implements AdminMenuUsageRepository {}

void main() {
  late _MockDemographicsRepository demographics;
  late _MockMenuUsageRepository menuUsage;

  setUp(() {
    demographics = _MockDemographicsRepository();
    menuUsage = _MockMenuUsageRepository();
  });

  Future<void> pump(WidgetTester tester, Widget section) async {
    tester.view
      ..physicalSize = const Size(360, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDemographicsRepositoryProvider.overrideWithValue(demographics),
          adminMenuUsageRepositoryProvider.overrideWithValue(menuUsage),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: section,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('demographics section shows gender and age breakdown',
      (tester) async {
    when(() => demographics.fetch()).thenAnswer((_) async => _demographics());
    await pump(tester, const AdminDemographicsSection());

    expect(find.text('Gender & usia pengguna'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('admin-demographics-content')),
      findsOneWidget,
    );
    expect(find.text('Laki-laki'), findsOneWidget);
    expect(find.text('25–34 tahun'), findsOneWidget);
    // Segmen tanpa data tetap tampil supaya kelengkapan datanya terbaca.
    expect(find.text('Belum diisi'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('demographics without users renders an empty state',
      (tester) async {
    when(() => demographics.fetch()).thenAnswer(
      (_) async => DemographicsSnapshot(
        generatedAt: DateTime.parse('2026-08-29T03:00:00Z'),
        totalUsers: 0,
        completedProfiles: 0,
        completionRate: 0,
        gender: const [],
        ageGroups: const [],
      ),
    );
    await pump(tester, const AdminDemographicsSection());

    expect(find.text('Belum ada pengguna'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu usage section ranks menus and switches period',
      (tester) async {
    when(() => menuUsage.fetch()).thenAnswer((_) async => _menuUsage());
    await pump(tester, const AdminMenuUsageSection());

    expect(find.text('Menu yang sering dipilih'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('admin-menu-usage-content')), findsOneWidget);
    // Default periode bulanan.
    expect(find.text('Taksir Harga Mobil'), findsOneWidget);
    expect(find.text('Simulasi Kredit'), findsOneWidget);

    await tester.tap(find.text('Hari ini'));
    await tester.pumpAndSettle();
    expect(find.text('Taksir Harga Mobil'), findsOneWidget);
    expect(find.text('Simulasi Kredit'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu usage offline state offers a retry', (tester) async {
    var attempt = 0;
    when(() => menuUsage.fetch()).thenAnswer((_) async {
      attempt++;
      if (attempt == 1) throw const NetworkException('offline');
      return _menuUsage();
    });
    await pump(tester, const AdminMenuUsageSection());

    expect(find.text('Statistik sedang offline'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Taksir Harga Mobil'), findsOneWidget);
    expect(attempt, 2);
    expect(tester.takeException(), isNull);
  });
}

DemographicsSnapshot _demographics() => DemographicsSnapshot(
      generatedAt: DateTime.parse('2026-08-29T03:00:00Z'),
      totalUsers: 10,
      completedProfiles: 6,
      completionRate: 0.6,
      gender: const [
        DemographicsSegment(
          key: 'male',
          label: 'Laki-laki',
          total: 4,
          share: 0.4,
        ),
        DemographicsSegment(
          key: 'female',
          label: 'Perempuan',
          total: 2,
          share: 0.2,
        ),
        DemographicsSegment(
          key: 'unknown',
          label: 'Belum diisi',
          total: 4,
          share: 0.4,
        ),
      ],
      ageGroups: const [
        DemographicsSegment(
          key: '25_34',
          label: '25–34 tahun',
          total: 5,
          share: 0.5,
        ),
        DemographicsSegment(
          key: '35_44',
          label: '35–44 tahun',
          total: 1,
          share: 0.1,
        ),
        DemographicsSegment(
          key: 'unknown',
          label: 'Belum diisi',
          total: 4,
          share: 0.4,
        ),
      ],
    );

MenuUsageSnapshot _menuUsage() => MenuUsageSnapshot(
      timezone: 'Asia/Jakarta',
      generatedAt: DateTime.parse('2026-08-29T03:00:00Z'),
      trackingStartedAt: DateTime.parse('2026-08-01T03:00:00Z'),
      periods: const {
        VisitPeriod.daily: MenuUsagePeriod(
          total: 3,
          distinctMenus: 1,
          menus: [
            MenuUsageEntry(
              key: 'appraisal',
              label: 'Taksir Harga Mobil',
              total: 3,
              share: 1,
            ),
          ],
        ),
        VisitPeriod.weekly: MenuUsagePeriod(
          total: 8,
          distinctMenus: 2,
          menus: [
            MenuUsageEntry(
              key: 'appraisal',
              label: 'Taksir Harga Mobil',
              total: 5,
              share: 0.625,
            ),
            MenuUsageEntry(
              key: 'credit',
              label: 'Simulasi Kredit',
              total: 3,
              share: 0.375,
            ),
          ],
        ),
        VisitPeriod.monthly: MenuUsagePeriod(
          total: 20,
          distinctMenus: 2,
          menus: [
            MenuUsageEntry(
              key: 'appraisal',
              label: 'Taksir Harga Mobil',
              total: 12,
              share: 0.6,
            ),
            MenuUsageEntry(
              key: 'credit',
              label: 'Simulasi Kredit',
              total: 8,
              share: 0.4,
            ),
          ],
        ),
        VisitPeriod.overall: MenuUsagePeriod(
          total: 30,
          distinctMenus: 2,
          menus: [
            MenuUsageEntry(
              key: 'appraisal',
              label: 'Taksir Harga Mobil',
              total: 18,
              share: 0.6,
            ),
            MenuUsageEntry(
              key: 'credit',
              label: 'Simulasi Kredit',
              total: 12,
              share: 0.4,
            ),
          ],
        ),
      },
    );
