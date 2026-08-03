import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/credit/domain/credit_models.dart';

void main() {
  test('parses program tenor fees and exact calculation breakdown', () {
    final program = CreditProgram.fromJson(_programJson());
    final calculation = CreditCalculation.fromJson(_calculationJson());

    expect(program.vehicleLabel, 'Avanza 1.5 G CVT 2026');
    expect(program.minimumDpAmount, 64000000);
    expect(program.isDemo, isTrue);
    expect(program.tenorOptions.single.annualFlatRatePercent, 5.25);
    expect(calculation.tradeInEquity, 80000000);
    expect(calculation.totalDownPayment, 110000000);
    expect(calculation.principal, 210000000);
    expect(calculation.monthlyInstallment, 4418750);
    expect(calculation.totalPayment, 296625000);
    expect(calculation.isDemoProgram, isTrue);
  });

  test('parses saved snapshot, follow-up, and expired program state', () {
    final simulation = CreditSimulation.fromJson({
      'id': 'simulation-1',
      'reference_no': 'SK-001',
      'status': 'lead_created',
      'status_label': 'Menunggu follow-up sales',
      'program': _calculationJson()['program'],
      'inputs': _calculationJson()['inputs'],
      'calculation': _calculationJson()['calculation'],
      'formula_version': 'flat-v1',
      'valid_until': '2026-08-31',
      'is_program_expired': true,
      'disclaimer': 'Estimasi.',
      'follow_up': {
        'id': 'lead-1',
        'reference_no': 'SKL-001',
        'status': 'new',
        'status_label': 'Baru',
        'contact_channel': 'whatsapp',
        'requested_at': '2026-07-27T03:00:00Z',
      },
      'saved_at': '2026-07-27T02:00:00Z',
      'updated_at': '2026-07-27T03:00:00Z',
    });

    expect(simulation.isProgramExpired, isTrue);
    expect(simulation.followUp?.referenceNo, 'SKL-001');
    expect(simulation.calculation.monthlyInstallment, 4418750);
  });

  test('draft serialization keeps resume and idempotency state', () {
    const draft = CreditSimulationDraft(
      programId: 'program-1',
      otrPrice: 320000000,
      cashDownPayment: 70000000,
      manualTradeInValue: 100000000,
      useTradeInAsDp: true,
      oldVehiclePayoff: 20000000,
      tenorMonths: 60,
      idempotencyKey: 'idem-1',
      comparisonGroupId: 'group-1',
      campaignSource: 'sales_share',
    );

    final restored = CreditSimulationDraft.fromJson(draft.toJson());

    expect(restored.canCalculate, isTrue);
    expect(restored.idempotencyKey, 'idem-1');
    expect(restored.comparisonGroupId, 'group-1');
    expect(restored.campaignSource, 'sales_share');
  });

  test('rejects malformed required nominal instead of displaying zero', () {
    final payload = _calculationJson();
    final calculation = payload['calculation']! as Map<String, dynamic>;
    calculation.remove('monthly_installment');

    expect(
      () => CreditCalculation.fromJson(payload),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _programJson() => {
      'id': 'program-1',
      'program_code': 'TAF-001',
      'version': 1,
      'partner_name': 'TAF',
      'program_name': 'Program Flat',
      'city': 'Surabaya',
      'vehicle': {
        'model': 'Avanza',
        'variant': '1.5 G CVT',
        'model_year': 2026,
        'otr_price': 320000000,
        'approved_discount': 10000000,
      },
      'minimum_dp_amount': 64000000,
      'maximum_dp_amount': 256000000,
      'tenor_options': [
        {
          'tenor_months': 60,
          'annual_flat_rate_basis_points': 525,
          'administration_fee': 2500000,
          'provision_fee': 1000000,
          'upfront_insurance': 7500000,
          'other_upfront_cost_label': 'Fidusia',
          'other_upfront_costs': 500000,
        },
      ],
      'formula_version': 'flat-v1',
      'effective_from': '2026-07-01',
      'effective_to': '2026-08-31',
      'source_reference': 'Dokumen program.',
      'disclaimer': 'Estimasi.',
      'is_demo': true,
    };

Map<String, dynamic> _calculationJson() => {
      'program': {
        'id': 'program-1',
        'program_name': 'Program Flat',
        'partner_name': 'TAF',
        'source_reference': 'Dokumen program.',
        'is_demo': true,
      },
      'inputs': {
        'otr_price': 320000000,
        'cash_down_payment': 20000000,
        'trade_in_value': 100000000,
        'use_trade_in_as_dp': true,
        'old_vehicle_payoff': 20000000,
        'tenor_months': 60,
      },
      'calculation': {
        'trade_in_equity': 80000000,
        'approved_discount': 10000000,
        'total_down_payment': 110000000,
        'principal': 210000000,
        'annual_flat_rate_basis_points': 525,
        'total_flat_interest': 55125000,
        'monthly_installment': 4418750,
        'administration_fee': 2500000,
        'provision_fee': 1000000,
        'upfront_insurance': 7500000,
        'other_upfront_cost_label': 'Fidusia',
        'other_upfront_costs': 500000,
        'initial_payment': 31500000,
        'total_payment': 296625000,
      },
      'formula_version': 'flat-v1',
      'valid_until': '2026-08-31',
      'warnings': <String>[],
      'disclaimer': 'Estimasi.',
    };
