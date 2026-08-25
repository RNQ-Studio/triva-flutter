import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/maintenance_estimate/data/maintenance_estimate_repository.dart';
import 'package:triva_app/features/maintenance_estimate/domain/maintenance_estimate_models.dart';
import 'package:triva_app/features/maintenance_estimate/presentation/maintenance_estimate_controller.dart';
import 'package:triva_app/features/maintenance_estimate/presentation/maintenance_estimate_screen.dart';

class _FakeRepository implements MaintenanceEstimateRepository {
  _FakeRepository(this.payload);

  final Map<String, dynamic> payload;
  int? lastMileage;
  String? lastModel;

  @override
  Future<MaintenanceEstimate> estimate({
    String? vehicleModel,
    int? mileage,
  }) async {
    lastModel = vehicleModel;
    lastMileage = mileage;
    return MaintenanceEstimate.fromJson(payload);
  }
}

Map<String, dynamic> _package({
  required String id,
  required int km,
  required int parts,
  required int labor,
}) =>
    {
      'id': id,
      'code': 'berkala-$km',
      'name': 'Servis berkala $km km',
      'description': 'Ganti oli dan pemeriksaan menyeluruh.',
      'km_interval': km,
      'parts_cost': parts,
      'labor_cost': labor,
      'total_cost': parts + labor,
      'includes': ['Oli mesin', 'Filter oli'],
      'duration_min_minutes': 60,
      'duration_max_minutes': 120,
      'disclaimer': 'Perkiraan biaya paket reguler.',
    };

Future<void> _pump(WidgetTester tester, _FakeRepository repository) async {
  tester.view
    ..physicalSize = const Size(390, 1200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        maintenanceEstimateRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MaintenanceEstimateScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the recommended package shows its parts, labour, and total',
      (tester) async {
    final repository = _FakeRepository({
      'vehicle_model': 'Avanza',
      'mileage': 23000,
      'recommended':
          _package(id: 'p-40', km: 40000, parts: 1800000, labor: 900000),
      'packages': [
        _package(id: 'p-10', km: 10000, parts: 650000, labor: 350000),
        _package(id: 'p-40', km: 40000, parts: 1800000, labor: 900000),
      ],
    });
    await _pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Model kendaraan'),
      'Avanza',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Kilometer saat ini'),
      '23000',
    );
    await tester.tap(find.text('Hitung perkiraan'));
    await tester.pumpAndSettle();

    expect(repository.lastModel, 'Avanza');
    expect(repository.lastMileage, 23000);
    expect(find.text('Rp 1.800.000'), findsOneWidget);
    expect(find.text('Rp 900.000'), findsOneWidget);
    expect(find.text('Rp 2.700.000'), findsOneWidget);
    expect(find.text('Paket lainnya'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty catalogue says so instead of showing a fake total',
      (tester) async {
    final repository = _FakeRepository({
      'vehicle_model': null,
      'mileage': 15000,
      'recommended': null,
      'packages': <Map<String, dynamic>>[],
    });
    await _pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextField, 'Kilometer saat ini'),
      '15000',
    );
    await tester.tap(find.text('Hitung perkiraan'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Data paket servis belum tersedia'),
      findsOneWidget,
    );
    expect(find.text('Perkiraan total'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
