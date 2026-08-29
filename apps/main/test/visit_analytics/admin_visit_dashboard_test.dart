import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_routes.dart';
import 'package:triva_app/features/visit_analytics/data/admin_demographics_repository.dart';
import 'package:triva_app/features/visit_analytics/data/admin_menu_usage_repository.dart';
import 'package:triva_app/features/visit_analytics/data/admin_visit_statistics_repository.dart';
import 'package:triva_app/features/visit_analytics/domain/demographics_models.dart';
import 'package:triva_app/features/visit_analytics/domain/menu_usage_models.dart';
import 'package:triva_app/features/visit_analytics/domain/visit_analytics_models.dart';
import 'package:triva_app/features/visit_analytics/presentation/visit_analytics_controller.dart';

class _AnalyticsAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        User(
          id: 'admin-analytics',
          name: 'Analytics Admin',
          email: 'analytics@example.com',
          profileCompleted: true,
          roles: ['admin'],
          permissions: ['analytics.viewAny', 'appraisals.viewAny'],
        ),
      );
}

class _MockStatisticsRepository extends Mock
    implements AdminVisitStatisticsRepository {}

/// Bagian demografi dan menu ikut termuat di panel yang sama; keduanya
/// dikosongkan supaya test ini tetap menguji statistik kunjungan saja.
class _EmptyDemographicsRepository implements AdminDemographicsRepository {
  @override
  Future<DemographicsSnapshot> fetch() async => DemographicsSnapshot(
        generatedAt: DateTime.parse('2026-08-19T03:00:00Z'),
        totalUsers: 0,
        completedProfiles: 0,
        completionRate: 0,
        gender: const [],
        ageGroups: const [],
      );
}

class _EmptyMenuUsageRepository implements AdminMenuUsageRepository {
  @override
  Future<MenuUsageSnapshot> fetch() async => MenuUsageSnapshot(
        timezone: 'Asia/Jakarta',
        generatedAt: DateTime.parse('2026-08-19T03:00:00Z'),
        periods: {
          for (final period in VisitPeriod.values)
            period: const MenuUsagePeriod(
              total: 0,
              distinctMenus: 0,
              menus: [],
            ),
        },
      );
}

void main() {
  late _MockStatisticsRepository repository;

  setUp(() {
    repository = _MockStatisticsRepository();
  });

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required ThemeData theme,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 690)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_AnalyticsAuthNotifier.new),
          adminVisitStatisticsRepositoryProvider.overrideWithValue(repository),
          adminDemographicsRepositoryProvider
              .overrideWithValue(_EmptyDemographicsRepository()),
          adminMenuUsageRepositoryProvider
              .overrideWithValue(_EmptyMenuUsageRepository()),
        ],
        child: MaterialApp(
          theme: theme,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: const AdminPanelScreen(),
        ),
      ),
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'visit dashboard is compact in ${brightness.name} theme',
      (tester) async {
        when(() => repository.fetch()).thenAnswer((_) async => _snapshot());
        await pumpDashboard(
          tester,
          theme:
              brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        );
        await tester.pumpAndSettle();

        expect(find.text('Statistik kunjungan'), findsOneWidget);
        expect(find.text('Hari ini'), findsOneWidget);
        expect(find.text('Minggu ini'), findsOneWidget);
        expect(find.text('Bulan ini'), findsOneWidget);
        expect(find.text('Keseluruhan'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('admin-visit-statistics-content')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('zero statistics render an honest empty state', (tester) async {
    when(() => repository.fetch())
        .thenAnswer((_) async => _snapshot(empty: true));
    await pumpDashboard(tester, theme: AppTheme.light);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kunjungan tercatat'), findsOneWidget);
    expect(
      find.textContaining('Angka akan muncul setelah Android'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline statistics retry without blocking admin menus',
      (tester) async {
    var attempt = 0;
    when(() => repository.fetch()).thenAnswer((_) async {
      attempt++;
      if (attempt == 1) throw const NetworkException('offline');
      return _snapshot();
    });
    await pumpDashboard(tester, theme: AppTheme.light);
    await tester.pumpAndSettle();

    expect(find.text('Statistik sedang offline'), findsOneWidget);
    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Hari ini'), findsOneWidget);
    expect(attempt, 2);

    // Menu operasional tetap terjangkau meski statistik sempat gagal.
    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(find.text('Daftar appraisal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

VisitAnalyticsSnapshot _snapshot({bool empty = false}) {
  VisitPeriodStatistics period(int total) => VisitPeriodStatistics(
        total: total,
        startsAt: DateTime.parse('2026-08-18T17:00:00Z'),
        endsAt: DateTime.parse('2026-08-19T03:00:00Z'),
        bySource: {
          VisitSource.android: total ~/ 2,
          VisitSource.web: total ~/ 4,
          VisitSource.landingPage: total - (total ~/ 2) - (total ~/ 4),
        },
      );
  final total = empty ? 0 : 40;
  return VisitAnalyticsSnapshot(
    timezone: 'Asia/Jakarta',
    trackingStartedAt: empty ? null : DateTime.parse('2026-08-19T01:00:00Z'),
    generatedAt: DateTime.parse('2026-08-19T03:00:00Z'),
    periods: {
      VisitPeriod.daily: period(total ~/ 4),
      VisitPeriod.weekly: period(total ~/ 2),
      VisitPeriod.monthly: period(total * 3 ~/ 4),
      VisitPeriod.overall: period(total),
    },
  );
}
