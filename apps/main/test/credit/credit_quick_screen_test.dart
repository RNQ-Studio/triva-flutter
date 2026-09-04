import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/credit/data/credit_repository.dart';
import 'package:triva_app/features/credit/domain/acc_credit_formula.dart';
import 'package:triva_app/features/credit/domain/credit_models.dart';
import 'package:triva_app/features/credit/presentation/credit_controller.dart';
import 'package:triva_app/features/credit/presentation/screens/credit_quick_screen.dart';
import 'package:triva_app/features/sales_contact/domain/sales_contact_models.dart';
import 'package:triva_app/features/sales_contact/presentation/sales_contact_controller.dart';

class _MockCreditRepository extends Mock implements CreditRepository {}

CreditProgram _program({
  String id = 'program-veloz',
  String model = 'Veloz Hybrid',
  int otr = 183260000,
}) =>
    CreditProgram.fromJson({
      'id': id,
      'program_code': 'UNIT-$id',
      'version': 1,
      'partner_name': 'ACC',
      'program_name': 'Unit rekomendasi',
      'city': 'Surabaya',
      'vehicle': {
        'model': model,
        'variant': '1.5 Q HEV CVT TSS',
        'model_year': 2026,
        'otr_price': otr,
        'approved_discount': 0,
      },
      'minimum_dp_amount': 20000000,
      'maximum_dp_amount': 160000000,
      'tenor_options': [
        {
          'tenor_months': 60,
          'annual_flat_rate_basis_points': 900,
          'administration_fee': 1000000,
          'provision_fee': 0,
          'upfront_insurance': 400000,
          'other_upfront_costs': 0,
        },
      ],
      'formula_version': 'flat-v1',
      'effective_from': '2026-09-01',
      'source_reference': 'test',
      'disclaimer': 'estimasi',
      'unit_key': 'veloz_hybrid',
    });

AccRateCard _card() => AccRateCard.fromJson({
      'formula_version': 'acc-flat-v1',
      'dp_percent_options': [20, 25, 30],
      'tenor_years_options': [1, 2, 3, 4, 5],
      'administration_fee': 1000000,
      'liability_insurance_fee': 400000,
      'rounding': 1000,
      'default_vehicle_class': 'reg2',
      'vehicle_classes': {
        'reg2': ['veloz'],
      },
      'interest_rates': {
        'reg2': {
          '25': {'1': 620, '2': 720, '3': 770, '4': 920, '5': 970},
          '30': {'1': 620, '2': 695, '3': 735, '4': 850, '5': 900},
        },
      },
      'insurance_rates': [
        {
          'max': null,
          'rates': {'1': 278, '2': 347, '3': 416, '4': 476, '5': 536},
        },
      ],
    });

CreditSimulation _saved() => CreditSimulation.fromJson({
      'id': 'sim-1',
      'reference_no': 'SK-260904-ABCDEFGH',
      'status': 'saved',
      'status_label': 'Tersimpan',
      'program': {'vehicle_model': 'Veloz Hybrid'},
      'inputs': {
        'otr_price': 183260000,
        'cash_down_payment': 54978000,
        'trade_in_value': 0,
        'use_trade_in_as_dp': false,
        'old_vehicle_payoff': 0,
        'tenor_months': 60,
      },
      'calculation': {
        'trade_in_equity': 0,
        'approved_discount': 0,
        'total_down_payment': 54978000,
        'principal': 128282000,
        'annual_flat_rate_basis_points': 900,
        'total_flat_interest': 62147250,
        'monthly_installment': 3339000,
        'administration_fee': 1000000,
        'provision_fee': 0,
        'upfront_insurance': 400000,
        'other_upfront_costs': 3339000,
        'initial_payment': 59717000,
        'total_payment': 256718000,
      },
      'formula_version': 'acc-flat-v1',
      'valid_until': null,
      'is_program_expired': false,
      'disclaimer': 'estimasi',
      'saved_at': '2026-09-04T03:00:00Z',
    });

void main() {
  late _MockCreditRepository repository;

  setUp(() {
    repository = _MockCreditRepository();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditRepositoryProvider.overrideWithValue(repository),
          creditProgramsProvider.overrideWith(
            (_) async => [
              _program(),
              _program(id: 'program-raize', model: 'Raize', otr: 275000000)
            ],
          ),
          creditRateCardProvider.overrideWith((_) async => _card()),
          salesDirectoryProvider.overrideWith(
            (_) async => const SalesDirectory([
              SalesContact(
                id: 'spv',
                name: 'Sari SPV',
                role: 'spv',
                whatsappNumber: '6281300001111',
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreditQuickScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the installment instantly and updates with DP and tenor',
      (tester) async {
    await pump(tester);

    expect(find.text('Veloz Hybrid 1.5 Q HEV CVT TSS 2026'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('quick-otr')))
          .controller!
          .text,
      '183.260.000',
    );
    // DP 20% (kolom 25%, 9,70%) tenor 5 tahun untuk OTR 183.260.000:
    // pokok 146.608.000 + asuransi 9.823.000, bunga 48,5% -> 3.872.000.
    final installment = find.byKey(const ValueKey('quick-installment'));
    expect(tester.widget<Text>(installment).data, 'Rp 3.872.000');

    await tester.tap(find.text('30%'));
    await tester.pumpAndSettle();
    // DP 54.978.000, bunga 9,00% x 5 tahun -> 3.338.000.
    expect(tester.widget<Text>(installment).data, 'Rp 3.338.000');

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('1 tahun'), findsOneWidget);
    expect(tester.widget<Text>(installment).data, isNot('Rp 3.338.000'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('calculating sends the simulation and enables consultation',
      (tester) async {
    when(
      () => repository.quickSimulate(
        programId: any(named: 'programId'),
        otrPrice: any(named: 'otrPrice'),
        dpPercent: any(named: 'dpPercent'),
        tenorYears: any(named: 'tenorYears'),
      ),
    ).thenAnswer((_) async => _saved());
    await pump(tester);

    await tester.tap(find.text('30%'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quick-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-submit')));
    await tester.pumpAndSettle();

    verify(
      () => repository.quickSimulate(
        programId: 'program-veloz',
        otrPrice: 183260000,
        dpPercent: 30,
        tenorYears: 5,
      ),
    ).called(1);
    expect(find.text('SK-260904-ABCDEFGH'), findsOneWidget);
    expect(find.textContaining('Admin kami sudah menerima'), findsWidgets);

    await tester.ensureVisible(find.byKey(const ValueKey('quick-consult')));
    await tester.tap(find.byKey(const ValueKey('quick-consult')));
    await tester.pumpAndSettle();
    expect(find.text('Hubungi sales'), findsOneWidget);
    expect(find.text('Belum ada sales'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
