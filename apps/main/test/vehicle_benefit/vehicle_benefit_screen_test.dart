import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/vehicle_benefit/data/vehicle_benefit_repository.dart';
import 'package:triva_app/features/vehicle_benefit/domain/vehicle_benefit_models.dart';
import 'package:triva_app/features/vehicle_benefit/presentation/vehicle_benefit_check_screen.dart';
import 'package:triva_app/features/vehicle_benefit/presentation/vehicle_benefit_controller.dart';

class _FakeRepository implements VehicleBenefitRepository {
  _FakeRepository(this.payload);

  final Map<String, dynamic> payload;
  String? lastVin;
  int? lastYear;

  @override
  Future<VehicleBenefitCheckResult> check({
    required String vin,
    int? year,
  }) async {
    lastVin = vin;
    lastYear = year;
    return VehicleBenefitCheckResult.fromJson(payload);
  }
}

Map<String, dynamic> _payload({
  required String sscStatus,
  required String tCareStatus,
  required String channel,
}) =>
    {
      'vin': 'MHKA1AA1JNK123456',
      'year': 2024,
      'ssc': {
        'status': sscStatus,
        'label':
            sscStatus == 'affected' ? 'Terlibat SSC' : 'Tidak terlibat SSC',
        'message': 'Pesan status SSC.',
        'campaigns': sscStatus == 'affected'
            ? [
                {
                  'campaign_code': 'SSC-2026-01',
                  'title': 'Penggantian fuel pump',
                  'description': 'Gratis di bengkel resmi.',
                  'recommended_action': 'Booking servis Auto2000.',
                },
              ]
            : <Map<String, dynamic>>[],
      },
      't_care': {
        'status': tCareStatus,
        'label': tCareStatus == 'active' ? 'Masih berlaku' : 'Sudah berakhir',
        'months_remaining': tCareStatus == 'active' ? 17 : 0,
        'expires_on': '2028-01-01',
        'message': 'Pesan status T-Care.',
      },
      'recommendation': {
        'channel': channel,
        'title': channel == 'toyota_service'
            ? 'Booking servis Toyota'
            : 'Booking OtoXpert',
        'message': 'Alasan rekomendasi.',
      },
    };

Future<void> _pump(
  WidgetTester tester,
  _FakeRepository repository,
) async {
  tester.view
    ..physicalSize = const Size(390, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        vehicleBenefitRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const VehicleBenefitCheckScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a chassis number is required before checking', (tester) async {
    final repository = _FakeRepository(
      _payload(
        sscStatus: 'not_affected',
        tCareStatus: 'active',
        channel: 'toyota_service',
      ),
    );
    await _pump(tester, repository);

    await tester.tap(find.text('Periksa sekarang'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masukkan nomor rangka kendaraan Anda.'),
      findsOneWidget,
    );
    expect(repository.lastVin, isNull);
  });

  testWidgets('an active T-Care steers the customer to Auto2000',
      (tester) async {
    final repository = _FakeRepository(
      _payload(
        sscStatus: 'not_affected',
        tCareStatus: 'active',
        channel: 'toyota_service',
      ),
    );
    await _pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nomor rangka'),
      'MHKA1AA1JNK123456',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tahun kendaraan'),
      '2024',
    );
    await tester.tap(find.text('Periksa sekarang'));
    await tester.pumpAndSettle();

    expect(repository.lastVin, 'MHKA1AA1JNK123456');
    expect(repository.lastYear, 2024);
    expect(find.text('Masih berlaku'), findsOneWidget);
    expect(find.text('Sisa sekitar 17 bulan'), findsOneWidget);
    expect(find.text('Booking servis Toyota'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an affected chassis number shows the campaign it belongs to',
      (tester) async {
    final repository = _FakeRepository(
      _payload(
        sscStatus: 'affected',
        tCareStatus: 'expired',
        channel: 'toyota_service',
      ),
    );
    await _pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nomor rangka'),
      'MHKA1AA1JNK123456',
    );
    await tester.tap(find.text('Periksa sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Terlibat SSC'), findsOneWidget);
    expect(
      find.text('SSC-2026-01 - Penggantian fuel pump'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an expired T-Care offers OtoXpert instead', (tester) async {
    final repository = _FakeRepository(
      _payload(
        sscStatus: 'not_affected',
        tCareStatus: 'expired',
        channel: 'otoxpert',
      ),
    );
    await _pump(tester, repository);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nomor rangka'),
      'MHKA1AA1JNK123456',
    );
    await tester.tap(find.text('Periksa sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Sudah berakhir'), findsOneWidget);
    expect(find.text('Booking OtoXpert'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
