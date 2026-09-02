import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepository implements MaintenanceRepository {
  _StubRepository(this._responses);

  final List<MaintenanceStatus?> _responses;
  int calls = 0;

  @override
  Future<MaintenanceStatus?> fetch() async {
    final index = calls < _responses.length ? calls : _responses.length - 1;
    calls++;
    return _responses[index];
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  setUp(() => MaintenanceSignal.instance.resetForTest());
  tearDown(() => MaintenanceSignal.instance.resetForTest());

  testWidgets('shows the app when the backend is healthy', (tester) async {
    final repository = _StubRepository([const MaintenanceStatus.inactive()]);

    await tester.pumpWidget(
      _wrap(
        MaintenanceGate(
          repository: repository,
          child: const Text('konten aplikasi'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('konten aplikasi'), findsOneWidget);
    expect(find.byType(MaintenanceScreen), findsNothing);
  });

  /// Kasus "sistem sudah mati sebelum app dibuka": tidak ada request lain yang
  /// memicu 503, jadi gate harus menanyakannya sendiri saat start.
  testWidgets('checks on startup and covers the app when disabled',
      (tester) async {
    final repository = _StubRepository([
      const MaintenanceStatus(
        isActive: true,
        title: 'Sedang Perawatan',
        message: 'Kembali sebentar lagi.',
      ),
    ]);

    await tester.pumpWidget(
      _wrap(
        MaintenanceGate(
          repository: repository,
          child: const Text('konten aplikasi'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(find.byType(MaintenanceScreen), findsOneWidget);
    expect(find.text('Sedang Perawatan'), findsOneWidget);
    expect(find.text('Kembali sebentar lagi.'), findsOneWidget);
    expect(find.text('konten aplikasi'), findsNothing);
  });

  /// Sistem yang mati di tengah pemakaian ditangkap interceptor jaringan.
  testWidgets('reacts to a 503 raised while the app is already open',
      (tester) async {
    final repository = _StubRepository([const MaintenanceStatus.inactive()]);

    await tester.pumpWidget(
      _wrap(
        MaintenanceGate(
          repository: repository,
          child: const Text('konten aplikasi'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('konten aplikasi'), findsOneWidget);

    MaintenanceSignal.instance.report(
      const MaintenanceStatus(isActive: true, message: 'Sistem dimatikan.'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaintenanceScreen), findsOneWidget);
    expect(find.text('Sistem dimatikan.'), findsOneWidget);
  });

  testWidgets('retry restores the app once the backend recovers',
      (tester) async {
    final repository = _StubRepository([
      const MaintenanceStatus(isActive: true, message: 'Sedang perawatan.'),
      const MaintenanceStatus.inactive(),
    ]);

    await tester.pumpWidget(
      _wrap(
        MaintenanceGate(
          repository: repository,
          child: const Text('konten aplikasi'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaintenanceScreen), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.byType(MaintenanceScreen), findsNothing);
    expect(find.text('konten aplikasi'), findsOneWidget);
  });

  /// Jaringan mati bukan bukti sistem sedang maintenance; menebaknya akan
  /// mengunci user di layar yang salah.
  testWidgets('an unknown status leaves the current state untouched',
      (tester) async {
    final repository = _StubRepository([null]);

    await tester.pumpWidget(
      _wrap(
        MaintenanceGate(
          repository: repository,
          child: const Text('konten aplikasi'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('konten aplikasi'), findsOneWidget);
    expect(find.byType(MaintenanceScreen), findsNothing);
  });

  testWidgets('falls back to localized copy when the server sends none',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        MaintenanceScreen(
          status: const MaintenanceStatus(isActive: true),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sistem Sedang Dalam Perawatan'), findsOneWidget);
    expect(find.textContaining('perawatan terjadwal'), findsOneWidget);
  });

  testWidgets('shows the estimated return time when announced', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MaintenanceScreen(
          status: MaintenanceStatus(
            isActive: true,
            until: DateTime(2026, 9, 2, 17),
          ),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Diperkirakan kembali normal'), findsOneWidget);
    expect(find.textContaining('17:00'), findsOneWidget);
  });

  testWidgets('omits the estimate row when not announced', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MaintenanceScreen(
          status: const MaintenanceStatus(isActive: true),
          onRetry: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Diperkirakan kembali normal'), findsNothing);
  });
}
