import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
}

void main() {
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
    expect(tester.takeException(), isNull);
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
    );

CreditCalculation _calculation() => CreditCalculation(
      program: const {
        'program_name': 'Program Flat',
        'partner_name': 'TAF',
        'source_reference': 'Dokumen program.',
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
