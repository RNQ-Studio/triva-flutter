import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';
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

class _FakeFlowController extends AppraisalFlowController {
  _FakeFlowController(this.draft);

  final AppraisalDraft draft;

  @override
  Future<AppraisalFlowState> build() async => AppraisalFlowState(draft: draft);
}

const _draft = AppraisalDraft(
  make: 'Toyota',
  model: 'Avanza',
  variant: '1.5 G',
  year: 2022,
  transmission: 'automatic',
  fuelType: 'gasoline',
  mileage: 42000,
  color: 'Putih',
  licensePlate: 'L 1234 TRV',
  city: 'Surabaya',
  taxStatus: 'active',
  floodHistory: 'no',
  majorAccidentHistory: 'no',
  serviceHistory: 'complete',
  ownership: 'first',
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
  make: 'Toyota',
  model: 'Avanza',
  variant: '1.5 G',
  year: 2022,
  transmission: 'automatic',
  fuelType: 'gasoline',
  mileage: 42000,
  color: 'Putih',
  licensePlate: 'L 1234 TRV',
  city: 'Surabaya',
);

final _appraisal = AppraisalData(
  id: 'appraisal-1',
  referenceNo: 'TIA-20260726-00000001',
  status: 'result_ready',
  statusLabel: 'Hasil tersedia',
  vehicle: _vehicle,
  timeline: [
    const AppraisalTimelineItem(
      status: 'submitted',
      title: 'Permintaan diterima',
      description: 'Data kendaraan dan lima foto berhasil dikirim.',
    ),
    const AppraisalTimelineItem(
      status: 'under_appraiser_review',
      title: 'Sedang dinilai',
      description: 'Appraiser memvalidasi data.',
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
    validUntil: DateTime(2026, 8, 2),
    requiresPhysicalInspection: true,
    disclaimer: 'Hasil merupakan indikasi dan belum merupakan penawaran final.',
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
        'Sedang dinilai appraiser',
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
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget widget,
  required Brightness brightness,
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
        appraisalsProvider.overrideWith((ref) async => [_appraisal]),
        appraisalDetailProvider.overrideWith((ref, id) async => _appraisal),
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
