import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_paths.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_activity_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_complete_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_detail_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_result_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_review_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_submitted_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/vehicle_condition_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/vehicle_details_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/vehicle_identity_screen.dart';
import 'package:triva_app/features/appraisal/presentation/screens/vehicle_photos_screen.dart';
import 'package:triva_app/features/credit/presentation/credit_controller.dart';
import 'package:triva_app/features/body_paint/presentation/body_paint_controller.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';
import 'package:triva_app/features/otoxpert/presentation/otoxpert_controller.dart';

class _FakeFlowController extends AppraisalFlowController {
  _FakeFlowController(this.draft);

  final AppraisalDraft draft;

  @override
  Future<AppraisalFlowState> build() async => AppraisalFlowState(draft: draft);
}

const _draft = AppraisalDraft(
  makeId: 1,
  modelId: 10,
  variantId: 100,
  make: 'Toyota',
  model: 'Avanza',
  variant: '1.5 G',
  year: 2022,
  transmission: 'automatic',
  fuelType: 'gasoline',
  mileage: 42000,
  color: 'Putih',
  licensePlate: 'L 1234 TRV',
  provinceId: 35,
  cityId: 3578,
  city: 'Surabaya',
  taxStatus: 'active',
  floodHistory: 'no',
  majorAccidentHistory: 'no',
  serviceHistory: 'complete',
  ownership: 'first',
  conditionGrade: 'b',
  engineCondition: 'normal',
  tyreCondition: 'normal',
  photoPaths: {
    'front': 'C:\\missing-front.jpg',
    'rear': 'C:\\missing-rear.jpg',
    'left_side': 'C:\\missing-left.jpg',
    'right_side': 'C:\\missing-right.jpg',
    'dashboard_odometer': 'C:\\missing-dashboard.jpg',
  },
);

const _vehicle = VehicleData(
  id: 'vehicle-1',
  makeId: 1,
  modelId: 10,
  variantId: 100,
  make: 'Toyota',
  model: 'Avanza',
  variant: '1.5 G',
  year: 2022,
  transmission: 'automatic',
  fuelType: 'gasoline',
  mileage: 42000,
  color: 'Putih',
  licensePlate: 'L 1234 TRV',
  provinceId: 35,
  cityId: 3578,
  city: 'Surabaya',
);

const _vehicleMake = VehicleMakeOption(
  id: 1,
  slug: 'toyota',
  name: 'Toyota',
);

const _hondaMake = VehicleMakeOption(
  id: 2,
  slug: 'honda',
  name: 'Honda',
);

const _vehicleModel = VehicleModelOption(
  id: 10,
  makeId: 1,
  slug: 'avanza',
  name: 'Avanza',
);

const _calyaModel = VehicleModelOption(
  id: 289,
  makeId: 1,
  slug: 'calya',
  name: 'Calya',
);

const _hondaModel = VehicleModelOption(
  id: 20,
  makeId: 2,
  slug: 'brio',
  name: 'Brio',
);

const _vehicleVariant = VehicleVariantOption(
  id: 100,
  modelId: 10,
  name: '1.5 G',
  transmission: 'automatic',
  fuelType: 'gasoline',
);

const _calyaVariants = [
  VehicleVariantOption(
    id: 1,
    modelId: 289,
    name: '1.2 E MT STD',
    transmission: 'manual',
    fuelType: 'gasoline',
  ),
  VehicleVariantOption(
    id: 2,
    modelId: 289,
    name: '1.2 E MT',
    transmission: 'manual',
    fuelType: 'gasoline',
  ),
  VehicleVariantOption(
    id: 3,
    modelId: 289,
    name: '1.2 G MT',
    transmission: 'manual',
    fuelType: 'gasoline',
  ),
  VehicleVariantOption(
    id: 4,
    modelId: 289,
    name: '1.2 G AT',
    transmission: 'automatic',
    fuelType: 'gasoline',
  ),
];

const _provinces = [
  ProvinceOption(
    id: 35,
    code: '35',
    name: 'Jawa Timur',
    cities: [
      CityOption(id: 3578, code: '3578', name: 'Kota Surabaya'),
    ],
  ),
];

final _appraisal = AppraisalData(
  id: 'appraisal-1',
  referenceNo: 'TIA-20260726-00000001',
  status: 'result_ready',
  statusLabel: 'Hasil tersedia',
  vehicle: _vehicle,
  condition: const AppraisalConditionData(
    taxStatus: 'active',
    floodHistory: 'no',
    majorAccidentHistory: 'no',
    serviceHistory: 'complete',
    ownership: 'first',
    conditionGrade: 'c',
    engineCondition: 'wet',
    tyreCondition: 'normal',
  ),
  photos: const [
    AppraisalPhoto(
      id: 'photo-front',
      angle: 'front',
      angleLabel: 'Tampak depan',
      reviewStatus: 'approved',
    ),
    AppraisalPhoto(
      id: 'photo-rear',
      angle: 'rear',
      angleLabel: 'Tampak belakang',
      reviewStatus: 'approved',
    ),
    AppraisalPhoto(
      id: 'photo-left',
      angle: 'left_side',
      angleLabel: 'Sisi kiri',
      reviewStatus: 'approved',
    ),
    AppraisalPhoto(
      id: 'photo-right',
      angle: 'right_side',
      angleLabel: 'Sisi kanan',
      reviewStatus: 'approved',
    ),
    AppraisalPhoto(
      id: 'photo-dashboard',
      angle: 'dashboard_odometer',
      angleLabel: 'Dashboard & odometer',
      reviewStatus: 'approved',
    ),
  ],
  timeline: [
    const AppraisalTimelineItem(
      status: 'submitted',
      title: 'Permintaan diterima',
      description: 'Data kendaraan dan lima foto berhasil dikirim.',
    ),
    const AppraisalTimelineItem(
      status: 'collecting_market_data',
      title: 'Memproses data pembanding',
      description: 'TRIVA mencari data OLX dan menyiapkan fallback OpenAI.',
    ),
  ],
  result: AppraisalResultData(
    tradeInLow: 168000000,
    tradeInHigh: 176000000,
    marketLow: 178000000,
    marketMid: 185000000,
    marketHigh: 192000000,
    confidence: 'medium',
    comparableCount: 6,
    sources: const [
      AppraisalResultSource(
        code: 'olx_approved_html',
        label: 'OLX (akses berizin)',
        comparableCount: 6,
      ),
    ],
    adjustments: const [
      AppraisalAdjustment(
        code: 'dealer_margin',
        label: 'Margin dan biaya proses trade-in',
      ),
    ],
    dataAsOf: DateTime(2026, 7, 28),
    validUntil: DateTime(2026, 8, 2),
    requiresPhysicalInspection: true,
    disclaimer: 'Hasil merupakan indikasi dan belum merupakan penawaran final.',
  ),
);

final _acceptedAppraisal = AppraisalData(
  id: _appraisal.id,
  referenceNo: _appraisal.referenceNo,
  status: 'accepted_by_customer',
  statusLabel: 'Harga diterima',
  vehicle: _appraisal.vehicle,
  condition: _appraisal.condition,
  photos: _appraisal.photos,
  timeline: _appraisal.timeline,
  result: _appraisal.result,
  customerDecision: 'accepted',
  continuation: const AppraisalContinuation(
    type: 'credit_simulation',
    vehicleId: 'vehicle-1',
    appraisalId: 'appraisal-1',
  ),
);

void main() {
  final flowScreens = <(String, Widget, String)>[
    ('identity', const VehicleIdentityScreen(), 'Identitas kendaraan'),
    ('details', const VehicleDetailsScreen(), 'Detail kendaraan'),
    ('condition', const VehicleConditionScreen(), 'Kondisi kendaraan'),
    ('photos', const VehiclePhotosScreen(), 'Foto kendaraan'),
    ('review', const AppraisalReviewScreen(), 'Tinjau pengajuan'),
  ];

  for (final brightness in Brightness.values) {
    for (final testCase in flowScreens) {
      testWidgets(
        '${testCase.$1} is compact and overflow-free in ${brightness.name}',
        (tester) async {
          await _pump(
            tester,
            widget: testCase.$2,
            brightness: brightness,
          );

          expect(find.text(testCase.$3), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    final dataScreens = <(String, Widget, String)>[
      (
        'submitted',
        const AppraisalSubmittedScreen(appraisalId: 'appraisal-1'),
        'Appraisal berhasil dikirim',
      ),
      ('activity', const AppraisalActivityScreen(), 'Aktivitas Saya'),
      (
        'detail',
        const AppraisalDetailScreen(appraisalId: 'appraisal-1'),
        'Gunakan hasil appraisal untuk memilih kredit, perbaikan, atau booking layanan.',
      ),
      (
        'result',
        const AppraisalResultScreen(appraisalId: 'appraisal-1'),
        'Estimasi trade-in',
      ),
      (
        'complete',
        const AppraisalCompleteScreen(
          appraisalId: 'appraisal-1',
          outcome: 'accepted',
        ),
        'Harga appraisal diterima',
      ),
    ];

    for (final testCase in dataScreens) {
      testWidgets(
        '${testCase.$1} is compact and overflow-free in ${brightness.name}',
        (tester) async {
          await _pump(
            tester,
            widget: testCase.$2,
            brightness: brightness,
          );

          expect(find.text(testCase.$3), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('shows an honest combined activity empty state', (tester) async {
    await _pump(
      tester,
      widget: const AppraisalActivityScreen(),
      brightness: Brightness.light,
      appraisalItems: const [],
    );

    expect(find.text('Belum ada aktivitas.'), findsOneWidget);
    expect(
      find.text(
        'Appraisal, booking, estimasi Body & Paint, dan simulasi kredit Anda akan muncul di sini.',
      ),
      findsOneWidget,
    );
    expect(find.text('Appraisal Toyota Avanza'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed automatic appraisal never promises a manual review',
      (tester) async {
    final failedAppraisal = AppraisalData(
      id: _appraisal.id,
      referenceNo: _appraisal.referenceNo,
      status: 'failed',
      statusLabel: 'Pemrosesan belum berhasil',
      vehicle: _vehicle,
      timeline: const [
        AppraisalTimelineItem(
          status: 'failed',
          title: 'Pemrosesan data pasar belum berhasil',
          description:
              'OLX dan fallback OpenAI belum menyediakan data yang memadai.',
        ),
      ],
    );

    await _pump(
      tester,
      widget: const AppraisalDetailScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
      detailData: failedAppraisal,
    );

    expect(find.text('Pemrosesan belum berhasil'), findsOneWidget);
    expect(find.textContaining('fallback OpenAI'), findsWidgets);
    expect(find.textContaining('appraiser'), findsNothing);
    expect(find.textContaining('manual'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy review status is rendered as automatic processing',
      (tester) async {
    final processingAppraisal = AppraisalData(
      id: _appraisal.id,
      referenceNo: _appraisal.referenceNo,
      status: 'under_appraiser_review',
      statusLabel: 'Pemrosesan otomatis dilanjutkan',
      vehicle: _vehicle,
      timeline: const [
        AppraisalTimelineItem(
          status: 'collecting_market_data',
          title: 'Mencari data pembanding',
        ),
      ],
    );

    await _pump(
      tester,
      widget: const AppraisalDetailScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
      detailData: processingAppraisal,
    );

    expect(find.text('Memproses data pembanding'), findsOneWidget);
    expect(find.textContaining('appraiser'), findsNothing);
    expect(find.textContaining('manual'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepted appraisal detail keeps the result menu available',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalDetailScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
      detailData: _acceptedAppraisal,
    );

    expect(
      find.widgetWithText(FilledButton, 'Hasil appraisal'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepted appraisal result is displayed without decision actions',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalResultScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
      detailData: _acceptedAppraisal,
    );

    expect(find.text('Estimasi trade-in'), findsOneWidget);
    expect(find.text('Terima harga'), findsNothing);
    expect(find.text('Belum cocok'), findsNothing);
    expect(find.text('Putuskan nanti'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Simulasi kredit'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Simulasi kredit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result shows one trade-in price without market internals',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalResultScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
    );

    // Sales menyampaikan angka tertinggi, jadi itu pula yang dilihat pelanggan.
    expect(find.text('Rp 176.000.000'), findsOneWidget);
    expect(find.textContaining('–'), findsNothing);
    expect(find.textContaining('178.000.000'), findsNothing);

    for (final removed in const [
      'Rentang harga pasar',
      'Tingkat keyakinan',
      '6 kendaraan pembanding',
      'Data pembanding per',
      'Sumber data',
      'Faktor penyesuaian',
      'Putuskan nanti',
    ]) {
      expect(find.text(removed), findsNothing);
    }

    await tester.scrollUntilVisible(
      find.text('Terima harga'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Terima harga'), findsOneWidget);
    expect(find.text('Belum cocok'), findsOneWidget);
    expect(find.text('Putuskan nanti'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result includes all submitted vehicle data and photo slots',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalResultScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
    );

    await tester.scrollUntilVisible(
      find.text('Detail kendaraan'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Otomatis'), findsOneWidget);
    expect(find.text('Bensin'), findsOneWidget);
    expect(find.text('42.000 km'), findsOneWidget);
    expect(find.text('Jawa Timur'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Foto kendaraan'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('90%'), findsNothing);
    expect(
      find.text('Cukup, ada perbaikan yang perlu dikerjakan'),
      findsOneWidget,
    );
    expect(find.text('Basah / rembes'), findsOneWidget);
    expect(find.text('Tampak depan'), findsOneWidget);
    expect(find.text('Tampak belakang'), findsOneWidget);
    expect(find.text('Sisi kiri'), findsOneWidget);
    expect(find.text('Sisi kanan'), findsOneWidget);
    expect(find.text('Dashboard & odometer'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('identity uses model and year bottom sheets', (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
    );

    await tester.tap(find.text('Avanza'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih model Toyota'), findsOneWidget);

    await tester.tap(find.text('Avanza').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2022'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.text('Pilih tahun kendaraan'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('1.5 G'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('variant master is available after model without selecting year',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
      draft: const AppraisalDraft(
        makeId: 1,
        modelId: 10,
        make: 'Toyota',
        model: 'Avanza',
      ),
    );

    final variantField = find.byKey(const ValueKey('vehicle-variant-field'));
    await tester.ensureVisible(variantField);
    await tester.tap(variantField);
    await tester.pumpAndSettle();

    expect(find.text('Pilih varian Avanza'), findsOneWidget);
    expect(find.text('1.5 G'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Calya field exposes four master variants before year selection',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
      draft: const AppraisalDraft(
        makeId: 1,
        modelId: 289,
        make: 'Toyota',
        model: 'Calya',
      ),
    );

    expect(
      find.text('4 varian tersedia. Ketuk untuk memilih.'),
      findsOneWidget,
    );

    final variantField = find.byKey(const ValueKey('vehicle-variant-field'));
    await tester.ensureVisible(variantField);
    await tester.tap(variantField);
    await tester.pumpAndSettle();

    expect(find.text('Pilih varian Calya'), findsOneWidget);
    for (final variant in _calyaVariants) {
      expect(find.text(variant.name), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('identity supports variant master and manual fallback',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('vehicle-variant-field')),
    );
    await tester.tap(find.byKey(const ValueKey('vehicle-variant-field')));
    await tester.pumpAndSettle();

    expect(find.text('Pilih varian Avanza'), findsOneWidget);
    expect(find.text('Otomatis · Bensin'), findsWidgets);
    await tester.tap(find.text('1.5 G').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Varian tidak ditemukan? Isi manual'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('vehicle-variant-manual-field')),
      findsOneWidget,
    );
    expect(find.text('Pilih dari master varian'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty picker hint is owned by the input decoration',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
    );

    await tester.tap(find.text('Toyota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Honda'));
    await tester.pumpAndSettle();

    final modelField = tester.widget<InputDecorator>(
      find.byKey(const ValueKey('vehicle-model-field')),
    );
    expect(modelField.isEmpty, isTrue);
    expect(modelField.child, isNull);
    expect(modelField.decoration.hintText, 'Pilih model mobil');
    expect(tester.takeException(), isNull);
  });

  testWidgets('condition step no longer asks for a percentage', (tester) async {
    await _pump(
      tester,
      widget: const VehicleConditionScreen(),
      brightness: Brightness.light,
    );

    expect(find.byType(Slider), findsNothing);
    expect(find.text('Kondisi kendaraan saat ini'), findsNothing);
    expect(find.text('Kondisi umum mobil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'condition step offers four condition descriptions without grade labels',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleConditionScreen(),
      brightness: Brightness.light,
    );

    expect(find.text('Kondisi umum mobil'), findsOneWidget);
    for (final label in const [
      'Istimewa, siap pakai',
      'Baik, perlu perawatan ringan',
      'Cukup, ada perbaikan yang perlu dikerjakan',
      'Perlu perbaikan menyeluruh',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.textContaining('Grade'), findsNothing);
    for (final code in const ['A', 'B', 'C', 'D']) {
      expect(find.text(code), findsNothing);
    }

    await tester.tap(find.text('Cukup, ada perbaikan yang perlu dikerjakan'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('condition step asks about the engine and the tyres',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleConditionScreen(),
      brightness: Brightness.light,
    );

    expect(find.text('Kondisi mesin'), findsOneWidget);
    expect(find.text('Kondisi ban'), findsOneWidget);

    final engine = find.ancestor(
      of: find.text('Kondisi mesin'),
      matching: find.byType(DropdownButtonFormField<String>),
    );
    await tester.ensureVisible(engine);
    await tester.pumpAndSettle();
    await tester.tap(engine);
    await tester.pumpAndSettle();

    expect(find.text('Basah / rembes'), findsOneWidget);
    await tester.tap(find.text('Basah / rembes').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('vehicle details can edit identity while preserving the draft',
      (tester) async {
    final router = GoRouter(
      initialLocation: appraisalDetailsPath,
      routes: [
        GoRoute(
          path: appraisalIdentityPath,
          builder: (_, __) => const VehicleIdentityScreen(),
        ),
        GoRoute(
          path: appraisalDetailsPath,
          builder: (_, __) => const VehicleDetailsScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router: router);

    expect(find.text('Toyota Avanza'), findsOneWidget);
    await tester.tap(find.text('Ubah identitas'));
    await tester.pumpAndSettle();

    expect(find.text('Identitas kendaraan'), findsOneWidget);
    expect(find.text('Toyota'), findsOneWidget);
    expect(find.text('Avanza'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing make resets model to the dependent master',
      (tester) async {
    await _pump(
      tester,
      widget: const VehicleIdentityScreen(),
      brightness: Brightness.light,
    );

    await tester.tap(find.text('Toyota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Honda'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih model mobil'), findsOneWidget);
    final modelField = find.byKey(const ValueKey('vehicle-model-field'));
    await tester.ensureVisible(modelField);
    await tester.pumpAndSettle();
    await tester.tap(modelField);
    await tester.pumpAndSettle();
    expect(find.text('Pilih model Honda'), findsOneWidget);
    expect(find.text('Brio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back from direct appraisal progress returns to home',
      (tester) async {
    final detailPath = appraisalDetailPath(_appraisal.id);
    final router = GoRouter(
      initialLocation: detailPath,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('Beranda test')),
          ),
        ),
        GoRoute(
          path: '/appraisals/:id',
          builder: (_, state) => AppraisalDetailScreen(
            appraisalId: state.pathParameters['id']!,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appraisalDetailProvider.overrideWith((ref, id) async => _appraisal),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perkembangan appraisal'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Beranda test'), findsOneWidget);

    router.go(detailPath);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Beranda test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back from direct appraisal result returns to home',
      (tester) async {
    final resultPath = appraisalResultPath(_appraisal.id);
    final router = GoRouter(
      initialLocation: resultPath,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('Beranda test')),
          ),
        ),
        GoRoute(
          path: '/appraisals/:id/result',
          builder: (_, state) => AppraisalResultScreen(
            appraisalId: state.pathParameters['id']!,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appraisalDetailProvider.overrideWith((ref, id) async => _appraisal),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estimasi trade-in'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Beranda test'), findsOneWidget);

    router.go(resultPath);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Beranda test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a ready result offers two new units funded by the appraisal',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalResultScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
      upgradeOffer: const AppraisalUpgradeOffer(
        tradeInValue: 176000000,
        options: [
          AppraisalUpgradeOption(
            programId: 'program-veloz',
            programCode: 'SPEKTA-VELOZ-2026',
            partnerName: 'ACC',
            programName: 'SPEKTA DP 20%',
            vehicleModel: 'Veloz',
            vehicleVariant: '1.5 Q CVT TSS',
            modelYear: 2026,
            otrPrice: 360000000,
            tenorMonths: 60,
            downPaymentFromAppraisal: 176000000,
            monthlyInstallment: 3900000,
          ),
          AppraisalUpgradeOption(
            programId: 'program-zenix',
            programCode: 'SPEKTA-INNOVA-2026',
            partnerName: 'TAF',
            programName: 'SPEKTA DP 20%',
            vehicleModel: 'Kijang Innova Zenix',
            vehicleVariant: '2.0 V CVT',
            modelYear: 2026,
            otrPrice: 470000000,
            tenorMonths: 60,
            downPaymentFromAppraisal: 176000000,
            monthlyInstallment: 6100000,
          ),
        ],
      ),
    );

    expect(find.text('Tukar tambah ke unit baru'), findsOneWidget);
    expect(find.text('Veloz 1.5 Q CVT TSS 2026'), findsOneWidget);
    expect(find.text('Kijang Innova Zenix 2.0 V CVT 2026'), findsOneWidget);
    expect(find.text('Rp 3.900.000'), findsOneWidget);
    expect(find.text('Simulasikan'), findsNWidgets(2));

    await tester.tap(find.text('Nanti saja'));
    await tester.pumpAndSettle();

    expect(find.text('Tukar tambah ke unit baru'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('declining the price asks for the expected price first',
      (tester) async {
    await _pump(
      tester,
      widget: const AppraisalResultScreen(appraisalId: 'appraisal-1'),
      brightness: Brightness.light,
    );

    await tester.scrollUntilVisible(
      find.text('Belum cocok'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Belum cocok'));
    await tester.pumpAndSettle();

    expect(find.text('Berapa harga yang Anda harapkan?'), findsOneWidget);

    // Angka di bawah batas minimum ditahan sebelum request dikirim.
    await tester.enterText(find.byType(TextFormField), '500');
    await tester.tap(find.text('Kirim harga harapan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Masukkan harga harapan minimal Rp 1.000.000.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), '210000000');
    await tester.pumpAndSettle();
    expect(find.text('210.000.000'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('rejected appraisal continues to Body Paint with source scope',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/complete',
      routes: [
        GoRoute(
          path: '/complete',
          builder: (_, __) => const AppraisalCompleteScreen(
            appraisalId: 'appraisal-1',
            outcome: 'rejected',
          ),
        ),
        GoRoute(
          path: '/body-paint',
          builder: (_, state) => Scaffold(
            body: Text(
              '${state.uri.queryParameters['appraisal_id']}|'
              '${state.uri.queryParameters['vehicle_id']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appraisalDetailProvider.overrideWith((ref, id) async => _appraisal),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Estimasi Body & Paint'));
    await tester.pumpAndSettle();

    expect(find.text('appraisal-1|vehicle-1'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget widget,
  required Brightness brightness,
  List<AppraisalData>? appraisalItems,
  AppraisalData? detailData,
  AppraisalDraft draft = _draft,
  AppraisalUpgradeOffer upgradeOffer = const AppraisalUpgradeOffer(
    tradeInValue: 0,
    options: [],
  ),
}) async {
  tester.view
    ..physicalSize = const Size(360, 690)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appraisalFlowProvider.overrideWith(
          () => _FakeFlowController(draft),
        ),
        appraisalsProvider.overrideWith(
          (ref) async => appraisalItems ?? [_appraisal],
        ),
        appraisalUpgradeOptionsProvider.overrideWith(
          (ref, id) async => upgradeOffer,
        ),
        toyotaServiceBookingsProvider.overrideWith((ref) async => const []),
        otoxpertBookingsProvider.overrideWith((ref) async => const []),
        creditSimulationsProvider.overrideWith((ref) async => const []),
        bodyPaintEstimatesProvider.overrideWith((ref) async => const []),
        vehicleMakesProvider.overrideWith(
          (ref) async => [_vehicleMake, _hondaMake],
        ),
        vehicleModelsProvider.overrideWith(
          (ref, makeId) async => makeId == _vehicleMake.id
              ? [_vehicleModel, _calyaModel]
              : [_hondaModel],
        ),
        vehicleVariantsProvider.overrideWith(
          (ref, modelId) async => switch (modelId) {
            10 => [_vehicleVariant],
            289 => _calyaVariants,
            _ => const [],
          },
        ),
        provinceOptionsProvider.overrideWith((ref) async => _provinces),
        appraisalDetailProvider.overrideWith(
          (ref, id) async => detailData ?? _appraisal,
        ),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: child!,
        ),
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRouter(
  WidgetTester tester, {
  required GoRouter router,
}) async {
  tester.view
    ..physicalSize = const Size(360, 690)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appraisalFlowProvider.overrideWith(
          () => _FakeFlowController(_draft),
        ),
        vehicleMakesProvider.overrideWith(
          (ref) async => [_vehicleMake, _hondaMake],
        ),
        vehicleModelsProvider.overrideWith(
          (ref, makeId) async => makeId == _vehicleMake.id
              ? [_vehicleModel, _calyaModel]
              : [_hondaModel],
        ),
        vehicleVariantsProvider.overrideWith(
          (ref, modelId) async => switch (modelId) {
            10 => [_vehicleVariant],
            289 => _calyaVariants,
            _ => const [],
          },
        ),
        provinceOptionsProvider.overrideWith((ref) async => _provinces),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
