import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/visit_analytics/data/admin_play_store_installs_repository.dart';
import 'package:triva_app/features/visit_analytics/domain/play_store_installs_models.dart';
import 'package:triva_app/features/visit_analytics/presentation/admin_play_store_section.dart';
import 'package:triva_app/features/visit_analytics/presentation/visit_analytics_controller.dart';

class _MockDio extends Mock implements Dio {}

class _MockPlayStoreRepository extends Mock
    implements AdminPlayStoreInstallsRepository {}

class _AdminAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        User(
          id: 'admin-play-store',
          name: 'Play Store Admin',
          email: 'playstore@example.com',
          profileCompleted: true,
          roles: ['admin'],
          permissions: ['analytics.viewAny'],
        ),
      );
}

void main() {
  group('repository', () {
    late _MockDio dio;

    setUp(() => dio = _MockDio());

    void respond(Map<String, dynamic> data) {
      when(() => dio.get<dynamic>('v1/admin/analytics/play-store-installs'))
          .thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: 'v1/admin/analytics/play-store-installs',
          ),
          data: {'data': data},
        ),
      );
    }

    test('parses a configured total with its reporting date', () async {
      respond({
        'package_name': 'id.rnq.triva',
        'configured': true,
        'total_installs': 12482,
        'source': 'play_reports',
        'reported_at': '2026-08-30T00:00:00+00:00',
        'generated_at': '2026-08-31T04:00:00+00:00',
      });

      final snapshot = await AdminPlayStoreInstallsRepository(dio).fetch();

      expect(snapshot.isConfigured, isTrue);
      expect(snapshot.totalInstalls, 12482);
      expect(snapshot.source, PlayStoreInstallsSource.playReports);
      expect(snapshot.reportedAt, DateTime.parse('2026-08-30T00:00:00Z'));
      expect(snapshot.packageName, 'id.rnq.triva');
    });

    test('treats a null total as not yet configured', () async {
      respond({
        'package_name': 'id.rnq.triva',
        'configured': false,
        'total_installs': null,
        'source': null,
        'reported_at': null,
        'generated_at': '2026-08-31T04:00:00+00:00',
      });

      final snapshot = await AdminPlayStoreInstallsRepository(dio).fetch();

      expect(snapshot.isConfigured, isFalse);
      expect(snapshot.totalInstalls, isNull);
      expect(snapshot.source, isNull);
    });

    test('keeps zero installs distinct from an unfilled number', () async {
      respond({
        'package_name': 'id.rnq.triva',
        'configured': true,
        'total_installs': 0,
        'source': 'manual',
        'generated_at': '2026-08-31T04:00:00+00:00',
      });

      final snapshot = await AdminPlayStoreInstallsRepository(dio).fetch();

      expect(snapshot.isConfigured, isTrue);
      expect(snapshot.totalInstalls, 0);
    });

    test('rejects an envelope without a data object', () {
      when(() => dio.get<dynamic>('v1/admin/analytics/play-store-installs'))
          .thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: 'v1/admin/analytics/play-store-installs',
          ),
          data: {'data': 'nope'},
        ),
      );

      expect(
        () => AdminPlayStoreInstallsRepository(dio).fetch(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('section', () {
    late _MockPlayStoreRepository repository;

    setUp(() => repository = _MockPlayStoreRepository());

    Future<void> pumpSection(
      WidgetTester tester, {
      ThemeData? theme,
    }) async {
      tester.view
        ..physicalSize = const Size(360, 690)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_AdminAuthNotifier.new),
            adminPlayStoreInstallsRepositoryProvider
                .overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: theme ?? AppTheme.light,
            locale: const Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AdminPlayStoreSection(),
              ),
            ),
          ),
        ),
      );
    }

    for (final brightness in Brightness.values) {
      testWidgets('total renders in ${brightness.name} theme', (tester) async {
        when(() => repository.fetch()).thenAnswer(
          (_) async => PlayStoreInstallsSnapshot(
            packageName: 'id.rnq.triva',
            generatedAt: DateTime.parse('2026-08-31T04:00:00Z'),
            totalInstalls: 12482,
            source: PlayStoreInstallsSource.manual,
            reportedAt: DateTime.parse('2026-08-30T00:00:00Z'),
          ),
        );

        await pumpSection(
          tester,
          theme:
              brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        );
        await tester.pumpAndSettle();

        expect(find.text('Total download Play Store'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('admin-play-store-content')),
          findsOneWidget,
        );
        expect(find.text('12.482'), findsOneWidget);
        expect(find.text('id.rnq.triva'), findsOneWidget);
        expect(find.textContaining('Diisi manual'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('an unfilled number explains where to enter it',
        (tester) async {
      when(() => repository.fetch()).thenAnswer(
        (_) async => PlayStoreInstallsSnapshot(
          packageName: 'id.rnq.triva',
          generatedAt: DateTime.parse('2026-08-31T04:00:00Z'),
        ),
      );

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('admin-play-store-empty')),
        findsOneWidget,
      );
      expect(find.text('Total download belum diisi'), findsOneWidget);
      expect(
        find.textContaining('play_store_total_installs'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('zero downloads render as a real figure, not an empty state',
        (tester) async {
      when(() => repository.fetch()).thenAnswer(
        (_) async => PlayStoreInstallsSnapshot(
          packageName: 'id.rnq.triva',
          generatedAt: DateTime.parse('2026-08-31T04:00:00Z'),
          totalInstalls: 0,
          source: PlayStoreInstallsSource.manual,
        ),
      );

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('admin-play-store-empty')),
        findsNothing,
      );
    });

    testWidgets('an offline failure can be retried', (tester) async {
      var attempt = 0;
      when(() => repository.fetch()).thenAnswer((_) async {
        attempt++;
        if (attempt == 1) throw const NetworkException('offline');
        return PlayStoreInstallsSnapshot(
          packageName: 'id.rnq.triva',
          generatedAt: DateTime.parse('2026-08-31T04:00:00Z'),
          totalInstalls: 7,
          source: PlayStoreInstallsSource.manual,
        );
      });

      await pumpSection(tester);
      await tester.pumpAndSettle();

      expect(find.text('Statistik sedang offline'), findsOneWidget);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
      expect(attempt, 2);
      expect(tester.takeException(), isNull);
    });
  });
}
