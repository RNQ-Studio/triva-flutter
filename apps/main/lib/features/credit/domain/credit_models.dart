class CreditTenorOption {
  const CreditTenorOption({
    required this.tenorMonths,
    required this.annualFlatRateBasisPoints,
    required this.administrationFee,
    required this.provisionFee,
    required this.upfrontInsurance,
    required this.otherUpfrontCosts,
    this.otherUpfrontCostLabel,
  });

  final int tenorMonths;
  final int annualFlatRateBasisPoints;
  final int administrationFee;
  final int provisionFee;
  final int upfrontInsurance;
  final int otherUpfrontCosts;
  final String? otherUpfrontCostLabel;

  double get annualFlatRatePercent => annualFlatRateBasisPoints / 100;

  factory CreditTenorOption.fromJson(Map<String, dynamic> json) =>
      CreditTenorOption(
        tenorMonths: _int(json['tenor_months']),
        annualFlatRateBasisPoints: _int(json['annual_flat_rate_basis_points']),
        administrationFee: _int(json['administration_fee']),
        provisionFee: _int(json['provision_fee']),
        upfrontInsurance: _int(json['upfront_insurance']),
        otherUpfrontCosts: _int(json['other_upfront_costs']),
        otherUpfrontCostLabel: json['other_upfront_cost_label']?.toString(),
      );
}

class CreditProgram {
  const CreditProgram({
    required this.id,
    required this.programCode,
    required this.version,
    required this.partnerName,
    required this.programName,
    required this.city,
    required this.vehicleModel,
    required this.vehicleVariant,
    required this.otrPrice,
    required this.approvedDiscount,
    required this.minimumDpAmount,
    required this.maximumDpAmount,
    required this.tenorOptions,
    required this.formulaVersion,
    required this.effectiveFrom,
    required this.sourceReference,
    required this.disclaimer,
    this.modelYear,
    this.effectiveTo,
  });

  final String id;
  final String programCode;
  final int version;
  final String partnerName;
  final String programName;
  final String city;
  final String vehicleModel;
  final String vehicleVariant;
  final int? modelYear;
  final int otrPrice;
  final int approvedDiscount;
  final int minimumDpAmount;
  final int maximumDpAmount;
  final List<CreditTenorOption> tenorOptions;
  final String formulaVersion;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String sourceReference;
  final String disclaimer;

  String get vehicleLabel {
    final year = modelYear == null ? '' : ' $modelYear';
    return '$vehicleModel $vehicleVariant$year';
  }

  factory CreditProgram.fromJson(Map<String, dynamic> json) {
    final vehicle = _map(json['vehicle']);
    final tenors = (json['tenor_options'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CreditTenorOption.fromJson)
        .toList(growable: false);
    if (tenors.isEmpty) {
      throw const FormatException('Credit program has no tenor option.');
    }
    return CreditProgram(
      id: json['id'].toString(),
      programCode: json['program_code'].toString(),
      version: _int(json['version']),
      partnerName: json['partner_name'].toString(),
      programName: json['program_name'].toString(),
      city: json['city'].toString(),
      vehicleModel: vehicle['model'].toString(),
      vehicleVariant: vehicle['variant'].toString(),
      modelYear: _nullableInt(vehicle['model_year']),
      otrPrice: _int(vehicle['otr_price']),
      approvedDiscount: _int(vehicle['approved_discount']),
      minimumDpAmount: _int(json['minimum_dp_amount']),
      maximumDpAmount: _int(json['maximum_dp_amount']),
      tenorOptions: tenors,
      formulaVersion: json['formula_version'].toString(),
      effectiveFrom: DateTime.parse(json['effective_from'].toString()),
      effectiveTo: _date(json['effective_to']),
      sourceReference: json['source_reference'].toString(),
      disclaimer: json['disclaimer'].toString(),
    );
  }
}

class CreditCalculation {
  const CreditCalculation({
    required this.program,
    required this.otrPrice,
    required this.cashDownPayment,
    required this.tradeInValue,
    required this.useTradeInAsDp,
    required this.oldVehiclePayoff,
    required this.tenorMonths,
    required this.tradeInEquity,
    required this.approvedDiscount,
    required this.totalDownPayment,
    required this.principal,
    required this.annualFlatRateBasisPoints,
    required this.totalFlatInterest,
    required this.monthlyInstallment,
    required this.administrationFee,
    required this.provisionFee,
    required this.upfrontInsurance,
    required this.otherUpfrontCosts,
    required this.initialPayment,
    required this.totalPayment,
    required this.formulaVersion,
    required this.warnings,
    required this.disclaimer,
    this.tradeInAppraisalId,
    this.otherUpfrontCostLabel,
    this.validUntil,
  });

  final Map<String, dynamic> program;
  final int otrPrice;
  final int cashDownPayment;
  final String? tradeInAppraisalId;
  final int tradeInValue;
  final bool useTradeInAsDp;
  final int oldVehiclePayoff;
  final int tenorMonths;
  final int tradeInEquity;
  final int approvedDiscount;
  final int totalDownPayment;
  final int principal;
  final int annualFlatRateBasisPoints;
  final int totalFlatInterest;
  final int monthlyInstallment;
  final int administrationFee;
  final int provisionFee;
  final int upfrontInsurance;
  final String? otherUpfrontCostLabel;
  final int otherUpfrontCosts;
  final int initialPayment;
  final int totalPayment;
  final String formulaVersion;
  final DateTime? validUntil;
  final List<String> warnings;
  final String disclaimer;

  String get scenarioKey =>
      '$monthlyInstallment|$totalDownPayment|$tenorMonths|'
      '$annualFlatRateBasisPoints';

  factory CreditCalculation.fromJson(Map<String, dynamic> json) {
    final inputs = _map(json['inputs']);
    final calculation = _map(json['calculation']);
    return CreditCalculation(
      program: _map(json['program']),
      otrPrice: _int(inputs['otr_price']),
      cashDownPayment: _int(inputs['cash_down_payment']),
      tradeInAppraisalId: inputs['trade_in_appraisal_id']?.toString(),
      tradeInValue: _int(inputs['trade_in_value']),
      useTradeInAsDp: inputs['use_trade_in_as_dp'] == true,
      oldVehiclePayoff: _int(inputs['old_vehicle_payoff']),
      tenorMonths: _int(inputs['tenor_months']),
      tradeInEquity: _int(calculation['trade_in_equity']),
      approvedDiscount: _int(calculation['approved_discount']),
      totalDownPayment: _int(calculation['total_down_payment']),
      principal: _int(calculation['principal']),
      annualFlatRateBasisPoints:
          _int(calculation['annual_flat_rate_basis_points']),
      totalFlatInterest: _int(calculation['total_flat_interest']),
      monthlyInstallment: _int(calculation['monthly_installment']),
      administrationFee: _int(calculation['administration_fee']),
      provisionFee: _int(calculation['provision_fee']),
      upfrontInsurance: _int(calculation['upfront_insurance']),
      otherUpfrontCostLabel:
          calculation['other_upfront_cost_label']?.toString(),
      otherUpfrontCosts: _int(calculation['other_upfront_costs']),
      initialPayment: _int(calculation['initial_payment']),
      totalPayment: _int(calculation['total_payment']),
      formulaVersion: json['formula_version'].toString(),
      validUntil: _date(json['valid_until']),
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      disclaimer: json['disclaimer'].toString(),
    );
  }
}

class CreditFollowUp {
  const CreditFollowUp({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.contactChannel,
    this.requestedAt,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final String contactChannel;
  final DateTime? requestedAt;

  factory CreditFollowUp.fromJson(Map<String, dynamic> json) => CreditFollowUp(
        id: json['id'].toString(),
        referenceNo: json['reference_no'].toString(),
        status: json['status'].toString(),
        statusLabel: json['status_label'].toString(),
        contactChannel: json['contact_channel'].toString(),
        requestedAt: _date(json['requested_at']),
      );
}

class CreditSimulation {
  const CreditSimulation({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.calculation,
    required this.isProgramExpired,
    required this.savedAt,
    this.comparisonGroupId,
    this.followUp,
    this.updatedAt,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final String? comparisonGroupId;
  final CreditCalculation calculation;
  final bool isProgramExpired;
  final CreditFollowUp? followUp;
  final DateTime savedAt;
  final DateTime? updatedAt;

  factory CreditSimulation.fromJson(Map<String, dynamic> json) {
    final calculationJson = <String, dynamic>{
      'program': _map(json['program']),
      'inputs': _map(json['inputs']),
      'calculation': _map(json['calculation']),
      'formula_version': json['formula_version'],
      'valid_until': json['valid_until'],
      'warnings': const <String>[],
      'disclaimer': json['disclaimer'],
    };
    return CreditSimulation(
      id: json['id'].toString(),
      referenceNo: json['reference_no'].toString(),
      status: json['status'].toString(),
      statusLabel: json['status_label'].toString(),
      comparisonGroupId: json['comparison_group_id']?.toString(),
      calculation: CreditCalculation.fromJson(calculationJson),
      isProgramExpired: json['is_program_expired'] == true,
      followUp: json['follow_up'] is Map<String, dynamic>
          ? CreditFollowUp.fromJson(_map(json['follow_up']))
          : null,
      savedAt: DateTime.parse(json['saved_at'].toString()),
      updatedAt: _date(json['updated_at']),
    );
  }
}

class CreditSimulationDraft {
  const CreditSimulationDraft({
    this.programId,
    this.otrPrice = 0,
    this.cashDownPayment = 0,
    this.manualTradeInValue = 0,
    this.tradeInAppraisalId,
    this.useTradeInAsDp = false,
    this.oldVehiclePayoff = 0,
    this.tenorMonths,
    this.acceptExpiredAppraisal = false,
    this.idempotencyKey,
    this.comparisonGroupId,
    this.campaignSource = 'triva_credit',
  });

  final String? programId;
  final int otrPrice;
  final int cashDownPayment;
  final int manualTradeInValue;
  final String? tradeInAppraisalId;
  final bool useTradeInAsDp;
  final int oldVehiclePayoff;
  final int? tenorMonths;
  final bool acceptExpiredAppraisal;
  final String? idempotencyKey;
  final String? comparisonGroupId;
  final String campaignSource;

  bool get canCalculate =>
      programId != null && otrPrice > 0 && tenorMonths != null;

  CreditSimulationDraft copyWith({
    String? programId,
    int? otrPrice,
    int? cashDownPayment,
    int? manualTradeInValue,
    String? tradeInAppraisalId,
    bool? useTradeInAsDp,
    int? oldVehiclePayoff,
    int? tenorMonths,
    bool? acceptExpiredAppraisal,
    String? idempotencyKey,
    String? comparisonGroupId,
    String? campaignSource,
    bool clearProgram = false,
    bool clearAppraisal = false,
    bool clearIdempotency = false,
  }) =>
      CreditSimulationDraft(
        programId: clearProgram ? null : programId ?? this.programId,
        otrPrice: otrPrice ?? this.otrPrice,
        cashDownPayment: cashDownPayment ?? this.cashDownPayment,
        manualTradeInValue: manualTradeInValue ?? this.manualTradeInValue,
        tradeInAppraisalId: clearAppraisal
            ? null
            : tradeInAppraisalId ?? this.tradeInAppraisalId,
        useTradeInAsDp: useTradeInAsDp ?? this.useTradeInAsDp,
        oldVehiclePayoff: oldVehiclePayoff ?? this.oldVehiclePayoff,
        tenorMonths: tenorMonths ?? this.tenorMonths,
        acceptExpiredAppraisal:
            acceptExpiredAppraisal ?? this.acceptExpiredAppraisal,
        idempotencyKey:
            clearIdempotency ? null : idempotencyKey ?? this.idempotencyKey,
        comparisonGroupId: comparisonGroupId ?? this.comparisonGroupId,
        campaignSource: campaignSource ?? this.campaignSource,
      );

  factory CreditSimulationDraft.fromJson(Map<String, dynamic> json) =>
      CreditSimulationDraft(
        programId: json['program_id']?.toString(),
        otrPrice: _int(json['otr_price']),
        cashDownPayment: _int(json['cash_down_payment']),
        manualTradeInValue: _int(json['manual_trade_in_value']),
        tradeInAppraisalId: json['trade_in_appraisal_id']?.toString(),
        useTradeInAsDp: json['use_trade_in_as_dp'] == true,
        oldVehiclePayoff: _int(json['old_vehicle_payoff']),
        tenorMonths: _nullableInt(json['tenor_months']),
        acceptExpiredAppraisal: json['accept_expired_appraisal'] == true,
        idempotencyKey: json['idempotency_key']?.toString(),
        comparisonGroupId: json['comparison_group_id']?.toString(),
        campaignSource: json['campaign_source']?.toString() ?? 'triva_credit',
      );

  Map<String, dynamic> toJson() => {
        'program_id': programId,
        'otr_price': otrPrice,
        'cash_down_payment': cashDownPayment,
        'manual_trade_in_value': manualTradeInValue,
        'trade_in_appraisal_id': tradeInAppraisalId,
        'use_trade_in_as_dp': useTradeInAsDp,
        'old_vehicle_payoff': oldVehiclePayoff,
        'tenor_months': tenorMonths,
        'accept_expired_appraisal': acceptExpiredAppraisal,
        'idempotency_key': idempotencyKey,
        'comparison_group_id': comparisonGroupId,
        'campaign_source': campaignSource,
      };
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

int _int(dynamic value) => value is num ? value.toInt() : 0;

int? _nullableInt(dynamic value) => value is num ? value.toInt() : null;

DateTime? _date(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : DateTime.tryParse(text);
}
