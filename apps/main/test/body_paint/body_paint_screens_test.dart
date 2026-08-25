import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/body_paint/domain/body_paint_models.dart';
import 'package:triva_app/features/body_paint/presentation/body_paint_controller.dart';
import 'package:triva_app/features/body_paint/presentation/screens/body_paint_customer_screens.dart';
import 'package:triva_app/features/body_paint/presentation/screens/body_paint_admin_screens.dart';
import 'package:triva_app/features/body_paint/presentation/screens/body_paint_intake_screen.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

class _FakeBodyPaintFlowController extends BodyPaintFlowController {
  @override
  Future<BodyPaintFlowState> build() async =>
      const BodyPaintFlowState(draft: BodyPaintDraft());
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'compact intake is usable in ${brightness.name} theme',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 690));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bodyPaintFlowProvider.overrideWith(
                _FakeBodyPaintFlowController.new,
              ),
              bodyPaintOptionsProvider.overrideWith((_) async => _options()),
              bodyPaintVehiclesProvider.overrideWith(
                (_) async => const [_vehicle],
              ),
            ],
            child: _app(
              const BodyPaintIntakeScreen(),
              brightness: brightness,
              textScale: 1.3,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Estimasi Body & Paint'), findsWidgets);
        expect(find.text('Kendaraan'), findsWidgets);
        await tester.scrollUntilVisible(
          find.text('Tambah panel rusak'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Tambah panel rusak'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('first-time intake offers vehicle creation instead of dead end',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bodyPaintFlowProvider.overrideWith(
            _FakeBodyPaintFlowController.new,
          ),
          bodyPaintOptionsProvider.overrideWith((_) async => _options()),
          bodyPaintVehiclesProvider.overrideWith((_) async => const []),
        ],
        child: _app(const BodyPaintIntakeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kendaraan tersimpan'), findsOneWidget);
    expect(find.byKey(const Key('body-paint-add-vehicle')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an insured estimate replaces the cost with claim guidance',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bodyPaintEstimateProvider('estimate-1').overrideWith(
            (_) async => _insuredEstimate(),
          ),
        ],
        child: _app(
          const BodyPaintEstimateScreen(estimateId: 'estimate-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Rp1.500.000'), findsNothing);
    expect(find.textContaining('Rp2.100.000'), findsNothing);
    expect(find.text('Asuransi Astra'), findsOneWidget);
    expect(
      find.textContaining('diproses lewat klaim asuransi'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('published detail shows range, item, and customer decisions',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bodyPaintEstimateProvider('estimate-1').overrideWith(
            (_) async => _publishedEstimate(),
          ),
        ],
        child: _app(
          const BodyPaintEstimateScreen(estimateId: 'estimate-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp1.500.000 - Rp2.100.000'), findsNWidgets(2));
    expect(find.text('Terima estimasi'), findsOneWidget);
    expect(find.text('Tidak lanjut'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin publish form renders engine-backed panel fields',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 690));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminBodyPaintEstimateProvider('estimate-1').overrideWith(
            (_) async => _adminEstimate(),
          ),
        ],
        child: _app(
          const AdminBodyPaintPublishScreen(estimateId: 'estimate-1'),
          textScale: 1.3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terbitkan estimasi'), findsWidgets);
    expect(find.text('Kap mesin - Penyok'), findsOneWidget);
    expect(find.text('Jasa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(
  Widget home, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) =>
    MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    );

const _vehicle = ToyotaServiceVehicle(
  id: 'vehicle-1',
  make: 'Honda',
  model: 'Brio',
  variant: 'RS',
  year: 2024,
  mileage: 12000,
  licensePlate: 'L 1234 AB',
);

BodyPaintOptions _options() => const BodyPaintOptions(
      panels: [BodyPaintOption(value: 'hood', label: 'Kap mesin')],
      damageTypes: [BodyPaintOption(value: 'dent', label: 'Penyok')],
      severities: [
        BodyPaintOption(value: 'medium', label: 'Sedang'),
        BodyPaintOption(value: 'unsure', label: 'Tidak yakin'),
      ],
      workTypes: [BodyPaintOption(value: 'repair', label: 'Perbaikan')],
      locations: [
        ToyotaServiceLocation(
          id: 'location-1',
          name: 'TRIVA Surabaya',
          address: 'Surabaya',
          city: 'Surabaya',
        ),
      ],
      maximumPhotos: 10,
      disclaimer: 'Estimasi indikatif.',
      serviceTypeId: 'service-1',
    );

BodyPaintEstimate _insuredEstimate() {
  final payload = _publishedPayload();
  payload['is_insured'] = true;
  payload['insurance_provider'] = 'Asuransi Astra';
  final estimate = payload['estimate'] as Map<String, dynamic>;
  estimate
    ..remove('low')
    ..remove('high')
    ..['is_insured'] = true
    ..['cost_hidden_reason'] = 'insurance_claim'
    ..['insurance_provider'] = 'Asuransi Astra'
    ..['insurance_notice'] =
        'Perbaikan kendaraan Anda diproses lewat klaim asuransi.';
  for (final item in estimate['items'] as List<dynamic>) {
    (item as Map<String, dynamic>).remove('cost');
  }

  return BodyPaintEstimate.fromJson(payload);
}

BodyPaintEstimate _publishedEstimate() =>
    BodyPaintEstimate.fromJson(_publishedPayload());

Map<String, dynamic> _publishedPayload() => {
      'id': 'estimate-1',
      'reference_no': 'BP-001',
      'status': 'estimate_ready',
      'status_label': 'Estimasi siap',
      'allowed_customer_actions': ['accept', 'decline'],
      'vehicle': {
        'id': 'vehicle-1',
        'make': 'Honda',
        'model': 'Brio',
        'variant': 'RS',
        'year': 2024,
        'mileage': 12000,
        'license_plate': 'L 1234 AB',
      },
      'requires_physical_inspection': true,
      'damages': [
        {
          'id': 'damage-1',
          'panel_code': 'hood',
          'panel_label': 'Kap mesin',
          'damage_type': 'dent',
          'damage_type_label': 'Penyok',
          'customer_severity': 'medium',
          'is_high_risk': false,
          'photos': <Map<String, dynamic>>[],
        },
      ],
      'context_photos': <Map<String, dynamic>>[],
      'timeline': <Map<String, dynamic>>[],
      'estimate': {
        'version': 1,
        'low': 1500000,
        'high': 2100000,
        'duration': {'min_days': 2, 'max_days': 3},
        'assumptions': ['Tidak ada kerusakan struktur.'],
        'disclaimer':
            'Nilai final mengikuti inspeksi fisik kendaraan secara langsung.',
        'items': [
          {
            'damage_id': 'damage-1',
            'panel_code': 'hood',
            'panel_label': 'Kap mesin',
            'damage_type': 'dent',
            'severity': 'medium',
            'work_type': 'repair',
            'work_type_label': 'Perbaikan panel',
            'cost': {'total_low': 1500000, 'total_high': 2100000},
            'duration_min_hours': 8,
            'duration_max_hours': 16,
          },
        ],
      },
    };

BodyPaintEstimate _adminEstimate() => BodyPaintEstimate.fromJson({
      'id': 'estimate-1',
      'reference_no': 'BP-001',
      'status': 'under_review',
      'status_label': 'Sedang direview',
      'allowed_customer_actions': <String>[],
      'requires_physical_inspection': true,
      'has_high_risk_damage': false,
      'damages': [
        {
          'id': 'damage-1',
          'panel_code': 'hood',
          'panel_label': 'Kap mesin',
          'damage_type': 'dent',
          'damage_type_label': 'Penyok',
          'customer_severity': 'medium',
          'is_high_risk': false,
          'photos': <Map<String, dynamic>>[],
        },
      ],
      'context_photos': <Map<String, dynamic>>[],
      'timeline': <Map<String, dynamic>>[],
      'engine_estimate': {
        'low': 1500000,
        'high': 2100000,
        'items': [
          {
            'damage_id': 'damage-1',
            'panel_code': 'hood',
            'damage_type': 'dent',
            'severity': 'medium',
            'work_type': 'repair',
            'labor_low': 500000,
            'labor_high': 700000,
            'material_low': 1000000,
            'material_high': 1400000,
            'parts_low': 0,
            'parts_high': 0,
            'other_low': 0,
            'other_high': 0,
            'duration_min_hours': 8,
            'duration_max_hours': 16,
          },
        ],
      },
      'available_actions': [
        {'value': 'publish', 'label': 'Terbitkan estimasi'},
      ],
    });
