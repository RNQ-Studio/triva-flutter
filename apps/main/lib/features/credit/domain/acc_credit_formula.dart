/// Rate card dan rumus simulasi kredit ACC (revisi 4 September 2026).
///
/// Cermin dari `App\Services\Credit\AccCreditCalculator` di backend supaya
/// angsuran tampil seketika saat pelanggan mengubah DP/tenor, sementara angka
/// resminya tetap dihitung server saat "Hitung simulasi" ditekan.
class AccRateCard {
  const AccRateCard({
    required this.formulaVersion,
    required this.dpPercentOptions,
    required this.tenorYearsOptions,
    required this.administrationFee,
    required this.liabilityInsuranceFee,
    required this.rounding,
    required this.defaultVehicleClass,
    required this.vehicleClasses,
    required this.interestRates,
    required this.insuranceRates,
  });

  final String formulaVersion;
  final List<int> dpPercentOptions;
  final List<int> tenorYearsOptions;
  final int administrationFee;
  final int liabilityInsuranceFee;
  final int rounding;
  final String defaultVehicleClass;

  /// kelas → kata kunci model.
  final Map<String, List<String>> vehicleClasses;

  /// kelas → tier DP ('25'/'30') → tenor (tahun) → basis poin.
  final Map<String, Map<String, Map<int, int>>> interestRates;

  /// Batas atas OTR (null = tanpa batas) → tenor → basis poin.
  final List<AccInsuranceBand> insuranceRates;

  factory AccRateCard.fromJson(Map<String, dynamic> json) {
    final classes = <String, List<String>>{};
    (json['vehicle_classes'] as Map<String, dynamic>? ?? const {})
        .forEach((key, value) {
      classes[key] = (value as List<dynamic>? ?? const [])
          .map((item) => item.toString().toLowerCase())
          .toList(growable: false);
    });
    final interest = <String, Map<String, Map<int, int>>>{};
    (json['interest_rates'] as Map<String, dynamic>? ?? const {})
        .forEach((klass, tiers) {
      final tierMap = <String, Map<int, int>>{};
      (tiers as Map<String, dynamic>? ?? const {}).forEach((tier, rates) {
        tierMap[tier] = _intMap(rates);
      });
      interest[klass] = tierMap;
    });
    return AccRateCard(
      formulaVersion: json['formula_version']?.toString() ?? '',
      dpPercentOptions:
          _intList(json['dp_percent_options'], const [20, 25, 30]),
      tenorYearsOptions:
          _intList(json['tenor_years_options'], const [1, 2, 3, 4, 5]),
      administrationFee: (json['administration_fee'] as num?)?.toInt() ?? 0,
      liabilityInsuranceFee:
          (json['liability_insurance_fee'] as num?)?.toInt() ?? 0,
      rounding: (json['rounding'] as num?)?.toInt() ?? 1000,
      defaultVehicleClass: json['default_vehicle_class']?.toString() ?? 'reg2',
      vehicleClasses: classes,
      interestRates: interest,
      insuranceRates: (json['insurance_rates'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AccInsuranceBand.fromJson)
          .toList(growable: false),
    );
  }

  String vehicleClassFor(String vehicleModel) {
    final needle = vehicleModel.toLowerCase();
    for (final entry in vehicleClasses.entries) {
      for (final keyword in entry.value) {
        if (keyword.isNotEmpty && needle.contains(keyword)) return entry.key;
      }
    }
    return defaultVehicleClass;
  }

  int? interestRateBps(String vehicleClass, int dpPercent, int tenorYears) {
    final tier = dpPercent >= 30 ? '30' : '25';
    return interestRates[vehicleClass]?[tier]?[tenorYears];
  }

  int? insuranceRateBps(int otrPrice, int tenorYears) {
    for (final band in insuranceRates) {
      if (band.max == null || otrPrice <= band.max!) {
        return band.rates[tenorYears];
      }
    }
    return null;
  }

  static Map<int, int> _intMap(Object? raw) {
    final result = <int, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final k = int.tryParse(key.toString());
        if (k != null && value is num) result[k] = value.toInt();
      });
    } else if (raw is List) {
      // JSON list tanpa kunci: indeks 0 = tenor 1 (jarang, hanya jaga-jaga).
      for (var i = 0; i < raw.length; i++) {
        final value = raw[i];
        if (value is num) result[i + 1] = value.toInt();
      }
    }
    return result;
  }

  static List<int> _intList(Object? raw, List<int> fallback) {
    if (raw is! List) return fallback;
    final values = raw.whereType<num>().map((e) => e.toInt()).toList();
    return values.isEmpty ? fallback : values;
  }
}

class AccInsuranceBand {
  const AccInsuranceBand({required this.max, required this.rates});

  final int? max;
  final Map<int, int> rates;

  factory AccInsuranceBand.fromJson(Map<String, dynamic> json) =>
      AccInsuranceBand(
        max: (json['max'] as num?)?.toInt(),
        rates: AccRateCard._intMap(json['rates']),
      );
}

class AccCreditQuote {
  const AccCreditQuote({
    required this.otrPrice,
    required this.dpPercent,
    required this.downPayment,
    required this.principal,
    required this.insuranceRateBps,
    required this.insurancePremium,
    required this.financedAmount,
    required this.annualFlatRateBps,
    required this.tenorYears,
    required this.totalFlatInterest,
    required this.monthlyInstallment,
    required this.administrationFee,
    required this.liabilityInsuranceFee,
    required this.totalDownPayment,
    required this.totalPayment,
    required this.vehicleClass,
  });

  final int otrPrice;
  final int dpPercent;
  final int downPayment;
  final int principal;
  final int insuranceRateBps;
  final int insurancePremium;
  final int financedAmount;
  final int annualFlatRateBps;
  final int tenorYears;
  final int totalFlatInterest;
  final int monthlyInstallment;
  final int administrationFee;
  final int liabilityInsuranceFee;
  final int totalDownPayment;
  final int totalPayment;
  final String vehicleClass;

  int get tenorMonths => tenorYears * 12;
  double get annualFlatRatePercent => annualFlatRateBps / 100;
}

class AccCreditFormula {
  const AccCreditFormula(this.card);

  final AccRateCard card;

  /// Null bila kombinasi kelas/DP/tenor/OTR tidak ada di rate card.
  AccCreditQuote? quote({
    required int otrPrice,
    required int dpPercent,
    required int tenorYears,
    required String vehicleModel,
  }) {
    if (otrPrice <= 0) return null;
    final vehicleClass = card.vehicleClassFor(vehicleModel);
    final rateBps = card.interestRateBps(vehicleClass, dpPercent, tenorYears);
    final insuranceBps = card.insuranceRateBps(otrPrice, tenorYears);
    if (rateBps == null || insuranceBps == null) return null;
    final downPayment = _roundToUnit(_ratio(otrPrice * dpPercent, 100));
    return quoteWithRates(
      otrPrice: otrPrice,
      dpPercent: dpPercent,
      downPayment: downPayment,
      tenorYears: tenorYears,
      interestRateBps: rateBps,
      insuranceRateBps: insuranceBps,
      vehicleClass: vehicleClass,
    );
  }

  AccCreditQuote quoteWithRates({
    required int otrPrice,
    required int dpPercent,
    required int downPayment,
    required int tenorYears,
    required int interestRateBps,
    required int insuranceRateBps,
    String vehicleClass = '',
  }) {
    final dp = downPayment.clamp(0, otrPrice);
    final principal = otrPrice - dp;
    final insurance = _roundToUnit(_ratio(otrPrice * insuranceRateBps, 10000));
    final financed = principal + insurance;
    final tenorMonths = tenorYears * 12;
    final interest = _ratio(financed * interestRateBps * tenorYears, 10000);
    final installment = tenorMonths == 0
        ? 0
        : _roundToUnit(_ratio(financed + interest, tenorMonths));
    final totalDownPayment =
        dp + installment + card.administrationFee + card.liabilityInsuranceFee;
    final remaining = tenorMonths - 1 < 0 ? 0 : tenorMonths - 1;
    return AccCreditQuote(
      otrPrice: otrPrice,
      dpPercent: dpPercent,
      downPayment: dp,
      principal: principal,
      insuranceRateBps: insuranceRateBps,
      insurancePremium: insurance,
      financedAmount: financed,
      annualFlatRateBps: interestRateBps,
      tenorYears: tenorYears,
      totalFlatInterest: interest,
      monthlyInstallment: installment,
      administrationFee: card.administrationFee,
      liabilityInsuranceFee: card.liabilityInsuranceFee,
      totalDownPayment: totalDownPayment,
      totalPayment: totalDownPayment + installment * remaining,
      vehicleClass: vehicleClass,
    );
  }

  int _ratio(int numerator, int denominator) =>
      (numerator + denominator ~/ 2) ~/ denominator;

  int _roundToUnit(int value) {
    final unit = card.rounding < 1 ? 1 : card.rounding;
    return (value + unit ~/ 2) ~/ unit * unit;
  }
}
