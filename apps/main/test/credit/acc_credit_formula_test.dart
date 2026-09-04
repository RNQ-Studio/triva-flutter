import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/credit/domain/acc_credit_formula.dart';

AccRateCard _card() => AccRateCard.fromJson({
      'formula_version': 'acc-flat-v1',
      'dp_percent_options': [20, 25, 30],
      'tenor_years_options': [1, 2, 3, 4, 5],
      'administration_fee': 1000000,
      'liability_insurance_fee': 400000,
      'rounding': 1000,
      'default_vehicle_class': 'reg2',
      'vehicle_classes': {
        'reg1': ['raize'],
        'reg2': ['veloz', 'innova'],
      },
      'interest_rates': {
        'reg2': {
          '25': {'1': 620, '5': 970},
          '30': {'1': 620, '5': 900},
        },
      },
      'insurance_rates': [
        {
          'max': 178571429,
          'rates': {'1': 278, '5': 544},
        },
        {
          'max': 200000000,
          'rates': {'1': 278, '5': 536},
        },
        {
          'max': null,
          'rates': {'1': 234, '5': 492},
        },
      ],
    });

void main() {
  test('reproduces the branch worksheet example', () {
    final quote = AccCreditFormula(_card()).quoteWithRates(
      otrPrice: 183260000,
      dpPercent: 29,
      downPayment: 52596000,
      tenorYears: 5,
      interestRateBps: 580,
      insuranceRateBps: 536,
    );

    expect(quote.principal, 130664000);
    expect(quote.insurancePremium, 9823000);
    expect(quote.financedAmount, 140487000);
    expect(quote.totalFlatInterest, 40741230);
    expect(quote.monthlyInstallment, 3020000);
    expect(quote.totalDownPayment, 57016000);
    expect(quote.tenorMonths, 60);
  });

  test('looks up rate by class, DP tier, tenor and OTR band', () {
    final formula = AccCreditFormula(_card());

    final quote = formula.quote(
      otrPrice: 183260000,
      dpPercent: 30,
      tenorYears: 5,
      vehicleModel: 'Veloz Hybrid',
    )!;
    expect(quote.vehicleClass, 'reg2');
    expect(quote.annualFlatRateBps, 900);
    expect(quote.insuranceRateBps, 536);
    expect(quote.downPayment, 54978000);

    // DP 20% memakai kolom 25%.
    expect(
      formula
          .quote(
            otrPrice: 183260000,
            dpPercent: 20,
            tenorYears: 5,
            vehicleModel: 'Veloz Hybrid',
          )!
          .annualFlatRateBps,
      970,
    );
    // Kelas tanpa rate di kartu -> null, bukan angka palsu.
    expect(
      formula.quote(
        otrPrice: 183260000,
        dpPercent: 20,
        tenorYears: 5,
        vehicleModel: 'Raize',
      ),
      isNull,
    );
    expect(
      formula.quote(
        otrPrice: 0,
        dpPercent: 20,
        tenorYears: 5,
        vehicleModel: 'Veloz',
      ),
      isNull,
    );
  });
}
