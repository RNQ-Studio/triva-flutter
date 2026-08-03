import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/credit/data/credit_repository.dart';
import 'package:triva_app/features/credit/domain/credit_models.dart';
import 'package:triva_app/features/credit/presentation/credit_controller.dart';
import 'package:triva_app/features/credit/presentation/screens/credit_simulation_detail_screen.dart';
import 'package:triva_app/features/credit/presentation/screens/credit_simulation_screen.dart';

class _FakeCreditFlowController extends CreditFlowController {
  @override
  Future<CreditFlowState> build() async => CreditFlowState(
        draft: const CreditSimulationDraft(
          programId: 'program-1',
          otrPrice: 320000000,
          cashDownPayment: 70000000,
          tenorMonths: 60,
        ),
        calculation: _calculation(),
        scenarios: [_calculation()],
      );

  @override
  Future<void> updateInputs({
    required int cashDownPayment,
    required int manualTradeInValue,
    required bool useTradeInAsDp,
    required int oldVehiclePayoff,
    required int tenorMonths,
    required bool acceptExpiredAppraisal,
  }) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          cashDownPayment: cashDownPayment,
          manualTradeInValue: manualTradeInValue,
          useTradeInAsDp: useTradeInAsDp,
          oldVehiclePayoff: oldVehiclePayoff,
          tenorMonths: tenorMonths,
          acceptExpiredAppraisal: acceptExpiredAppraisal,
        ),
        clearCalculation: true,
        clearSaved: true,
      ),
    );
  }

  @override
  Future<void> persistInputsOnExit({
    required int cashDownPayment,
    required int manualTradeInValue,
    required bool useTradeInAsDp,
    required int oldVehiclePayoff,
    required int tenorMonths,
    required bool acceptExpiredAppraisal,
  }) async {}
}

class _MockCreditRepository extends Mock implements CreditRepository {}

void main() {
  test('input revision discards a calculation completed for stale inputs',
      () async {
    final repository = _MockCreditRepository();
    const draft = CreditSimulationDraft(
      programId: 'program-1',
      otrPrice: 320000000,
      cashDownPayment: 70000000,
      tenorMonths: 60,
    );
    final calculation = Completer<CreditCalculation>();
    when(repository.loadDraft).thenAnswer((_) async => draft);
    when(() => repository.calculate(draft))
        .thenAnswer((_) => calculation.future);
    final container = ProviderContainer(
      overrides: [creditRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(creditFlowProvider.future);

    final pending = container.read(creditFlowProvider.notifier).calculate();
    container.read(creditFlowProvider.notifier).markInputsDirty();
    calculation.complete(_calculation());

    expect(await pending, isNull);
    expect(container.read(creditFlowProvider).requireValue.calculation, isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'credit flow is usable at compact size with 1.3 text scale in '
      '${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 690));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              creditFlowProvider.overrideWith(
                _FakeCreditFlowController.new,
              ),
              creditProgramsProvider.overrideWith(
                (_) async => [_program()],
              ),
            ],
            child: _app(
              const CreditSimulationScreen(),
              brightness: brightness,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Simulasi kredit'), findsOneWidget);
        expect(find.text('Rp 5.050.000'), findsWidgets);
        expect(find.text('Perbandingan skenario'), findsOneWidget);
        expect(
          find.textContaining('data demo untuk pengujian'),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('saved detail shows expired program and complete breakdown',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 690));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final simulation = CreditSimulation(
      id: 'simulation-1',
      referenceNo: 'SK-001',
      status: 'saved',
      statusLabel: 'Simulasi tersimpan',
      calculation: _calculation(),
      isProgramExpired: true,
      savedAt: DateTime(2026, 7, 27),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditSimulationProvider('simulation-1').overrideWith(
            (_) async => simulation,
          ),
        ],
        child: _app(
          const CreditSimulationDetailScreen(
            simulationId: 'simulation-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SK-001'), findsOneWidget);
    expect(
      find.textContaining('Program pada snapshot ini sudah berakhir'),
      findsOneWidget,
    );
    expect(find.text('Total pembayaran estimasi'), findsOneWidget);
    expect(find.text('Minta dihubungi sales'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid down payment is blocked before calculation',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 690));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditFlowProvider.overrideWith(_FakeCreditFlowController.new),
          creditProgramsProvider.overrideWith((_) async => [_program()]),
        ],
        child: _app(const CreditSimulationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final cashField = find.widgetWithText(TextFormField, 'DP tunai');
    await tester.enterText(cashField, '1000000');
    final calculate = find.widgetWithText(FilledButton, 'Hitung simulasi');
    await tester.ensureVisible(calculate);
    await tester.pumpAndSettle();
    await tester.tap(calculate);
    await tester.pump();

    expect(
      find.textContaining('Total DP minimum adalah Rp 64.000.000'),
      findsOneWidget,
    );
  });

  testWidgets('editing a money input clears the stale result', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditFlowProvider.overrideWith(_FakeCreditFlowController.new),
          creditProgramsProvider.overrideWith((_) async => [_program()]),
        ],
        child: _app(const CreditSimulationScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan estimasi'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'DP tunai'),
      '75000000',
    );
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Ringkasan estimasi'), findsNothing);
  });

  testWidgets('program error can retry into content', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditFlowProvider.overrideWith(_FakeCreditFlowController.new),
          creditProgramsProvider.overrideWith((_) async {
            attempts += 1;
            if (attempts == 1) throw Exception('offline');
            return [_program()];
          }),
        ],
        child: _app(const CreditSimulationScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
        find.text('Data simulasi kredit belum dapat dimuat.'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Coba lagi'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Program dan mobil target'), findsOneWidget);
  });

  testWidgets('empty catalog explains the state and offers retry',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditFlowProvider.overrideWith(_FakeCreditFlowController.new),
          creditProgramsProvider.overrideWith((_) async => []),
        ],
        child: _app(const CreditSimulationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Program kredit belum tersedia'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Coba lagi'), findsOneWidget);
  });

  testWidgets('saved detail can request an idempotent sales follow-up',
      (tester) async {
    final repository = _MockCreditRepository();
    final simulation = _savedSimulation();
    final updated = _savedSimulation(
      followUp: CreditFollowUp(
        id: 'lead-1',
        referenceNo: 'SKL-001',
        status: 'new',
        statusLabel: 'Baru',
        contactChannel: 'whatsapp',
        requestedAt: DateTime(2026, 8, 3),
      ),
    );
    when(
      () => repository.requestFollowUp(
        'simulation-1',
        contactChannel: any(named: 'contactChannel'),
      ),
    ).thenAnswer((_) async => updated);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditRepositoryProvider.overrideWithValue(repository),
          creditSimulationProvider('simulation-1').overrideWith(
            (_) async => simulation,
          ),
        ],
        child: _app(
          const CreditSimulationDetailScreen(simulationId: 'simulation-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final followUpButton =
        find.widgetWithText(FilledButton, 'Minta dihubungi sales');
    await tester.ensureVisible(followUpButton);
    await tester.pumpAndSettle();
    await tester.tap(followUpButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Minta dihubungi sales').last,
    );
    await tester.pumpAndSettle();

    verify(
      () => repository.requestFollowUp(
        'simulation-1',
        contactChannel: 'whatsapp',
      ),
    ).called(1);
    expect(find.textContaining('SKL-001 · Baru'), findsOneWidget);
  });
}

Widget _app(
  Widget home, {
  Brightness brightness = Brightness.light,
}) =>
    MaterialApp(
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
      home: home,
    );

CreditProgram _program() => CreditProgram(
      id: 'program-1',
      programCode: 'TAF-001',
      version: 1,
      partnerName: 'TAF',
      programName: 'Program Flat',
      city: 'Surabaya',
      vehicleModel: 'Avanza',
      vehicleVariant: '1.5 G CVT',
      modelYear: 2026,
      otrPrice: 320000000,
      approvedDiscount: 10000000,
      minimumDpAmount: 64000000,
      maximumDpAmount: 256000000,
      tenorOptions: const [
        CreditTenorOption(
          tenorMonths: 60,
          annualFlatRateBasisPoints: 525,
          administrationFee: 2500000,
          provisionFee: 1000000,
          upfrontInsurance: 7500000,
          otherUpfrontCosts: 500000,
        ),
      ],
      formulaVersion: 'flat-v1',
      effectiveFrom: DateTime(2026, 7),
      effectiveTo: DateTime(2026, 8, 31),
      sourceReference: 'Dokumen program.',
      disclaimer: 'Estimasi.',
      isDemo: true,
    );

CreditCalculation _calculation() => CreditCalculation(
      program: const {
        'program_name': 'Program Flat',
        'partner_name': 'TAF',
        'source_reference': 'Dokumen program.',
        'is_demo': true,
      },
      otrPrice: 320000000,
      cashDownPayment: 70000000,
      tradeInValue: 0,
      useTradeInAsDp: false,
      oldVehiclePayoff: 0,
      tenorMonths: 60,
      tradeInEquity: 0,
      approvedDiscount: 10000000,
      totalDownPayment: 80000000,
      principal: 240000000,
      annualFlatRateBasisPoints: 525,
      totalFlatInterest: 63000000,
      monthlyInstallment: 5050000,
      administrationFee: 2500000,
      provisionFee: 1000000,
      upfrontInsurance: 7500000,
      otherUpfrontCosts: 500000,
      initialPayment: 81500000,
      totalPayment: 384500000,
      formulaVersion: 'flat-v1',
      validUntil: DateTime(2026, 8, 31),
      warnings: const [],
      disclaimer: 'Estimasi ini bukan persetujuan kredit.',
    );

CreditSimulation _savedSimulation({CreditFollowUp? followUp}) =>
    CreditSimulation(
      id: 'simulation-1',
      referenceNo: 'SK-001',
      status: followUp == null ? 'saved' : 'lead_created',
      statusLabel:
          followUp == null ? 'Simulasi tersimpan' : 'Menunggu follow-up sales',
      calculation: _calculation(),
      isProgramExpired: false,
      followUp: followUp,
      savedAt: DateTime(2026, 7, 27),
    );
