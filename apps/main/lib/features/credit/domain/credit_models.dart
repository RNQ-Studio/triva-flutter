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
        tenorMonths: _requiredInt(json['tenor_months'], 'tenor_months'),
        annualFlatRateBasisPoints: _requiredInt(
          json['annual_flat_rate_basis_points'],
          'annual_flat_rate_basis_points',
        ),
        administrationFee: _requiredInt(
          json['administration_fee'],
          'administration_fee',
        ),
        provisionFee: _requiredInt(json['provision_fee'], 'provision_fee'),
        upfrontInsurance: _requiredInt(
          json['upfront_insurance'],
          'upfront_insurance',
        ),
        otherUpfrontCosts: _requiredInt(
          json['other_upfront_costs'],
          'other_upfront_costs',
        ),
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
    this.isDemo = false,
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
  final bool isDemo;

  String get vehicleLabel {
    final year = modelYear == null ? '' : ' $modelYear';
    return '$vehicleModel $vehicleVariant$year';
  }

  factory CreditProgram.fromJson(Map<String, dynamic> json) {
    final vehicle = _requiredMap(json['vehicle'], 'vehicle');
    final tenorPayload = json['tenor_options'];
    if (tenorPayload is! List<dynamic>) {
      throw const FormatException(
        'Invalid credit API payload: tenor_options must be a list.',
      );
    }
    final tenors = tenorPayload
        .map(
          (item) => CreditTenorOption.fromJson(
            _requiredMap(item, 'tenor_options[]'),
          ),
        )
        .toList(growable: false);
    if (tenors.isEmpty) {
      throw const FormatException('Credit program has no tenor option.');
    }
    return CreditProgram(
      id: _requiredString(json['id'], 'id'),
      programCode: _requiredString(json['program_code'], 'program_code'),
      version: _requiredInt(json['version'], 'version'),
      partnerName: _requiredString(json['partner_name'], 'partner_name'),
      programName: _requiredString(json['program_name'], 'program_name'),
      city: _requiredString(json['city'], 'city'),
      vehicleModel: _requiredString(vehicle['model'], 'vehicle.model'),
      vehicleVariant: _requiredString(vehicle['variant'], 'vehicle.variant'),
      modelYear: _nullableInt(vehicle['model_year']),
      otrPrice: _requiredInt(vehicle['otr_price'], 'vehicle.otr_price'),
      approvedDiscount: _requiredInt(
        vehicle['approved_discount'],
        'vehicle.approved_discount',
      ),
      minimumDpAmount: _requiredInt(
        json['minimum_dp_amount'],
        'minimum_dp_amount',
      ),
      maximumDpAmount: _requiredInt(
        json['maximum_dp_amount'],
        'maximum_dp_amount',
      ),
      tenorOptions: tenors,
      formulaVersion: _requiredString(
        json['formula_version'],
        'formula_version',
      ),
      effectiveFrom: _requiredDate(json['effective_from'], 'effective_from'),
      effectiveTo: _date(json['effective_to']),
      sourceReference: _requiredString(
        json['source_reference'],
        'source_reference',
      ),
      disclaimer: _requiredString(json['disclaimer'], 'disclaimer'),
      isDemo: json['is_demo'] == true,
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

  bool get isDemoProgram => program['is_demo'] == true;

  String get scenarioKey =>
      '$monthlyInstallment|$totalDownPayment|$tenorMonths|'
      '$annualFlatRateBasisPoints';

  factory CreditCalculation.fromJson(Map<String, dynamic> json) {
    final inputs = _requiredMap(json['inputs'], 'inputs');
    final calculation = _requiredMap(json['calculation'], 'calculation');
    return CreditCalculation(
      program: _requiredMap(json['program'], 'program'),
      otrPrice: _requiredInt(inputs['otr_price'], 'inputs.otr_price'),
      cashDownPayment: _requiredInt(
        inputs['cash_down_payment'],
        'inputs.cash_down_payment',
      ),
      tradeInAppraisalId: inputs['trade_in_appraisal_id']?.toString(),
      tradeInValue: _requiredInt(
        inputs['trade_in_value'],
        'inputs.trade_in_value',
      ),
      useTradeInAsDp: inputs['use_trade_in_as_dp'] == true,
      oldVehiclePayoff: _requiredInt(
        inputs['old_vehicle_payoff'],
        'inputs.old_vehicle_payoff',
      ),
      tenorMonths: _requiredInt(inputs['tenor_months'], 'inputs.tenor_months'),
      tradeInEquity: _requiredInt(
        calculation['trade_in_equity'],
        'calculation.trade_in_equity',
      ),
      approvedDiscount: _requiredInt(
        calculation['approved_discount'],
        'calculation.approved_discount',
      ),
      totalDownPayment: _requiredInt(
        calculation['total_down_payment'],
        'calculation.total_down_payment',
      ),
      principal:
          _requiredInt(calculation['principal'], 'calculation.principal'),
      annualFlatRateBasisPoints: _requiredInt(
        calculation['annual_flat_rate_basis_points'],
        'calculation.annual_flat_rate_basis_points',
      ),
      totalFlatInterest: _requiredInt(
        calculation['total_flat_interest'],
        'calculation.total_flat_interest',
      ),
      monthlyInstallment: _requiredInt(
        calculation['monthly_installment'],
        'calculation.monthly_installment',
      ),
      administrationFee: _requiredInt(
        calculation['administration_fee'],
        'calculation.administration_fee',
      ),
      provisionFee: _requiredInt(
        calculation['provision_fee'],
        'calculation.provision_fee',
      ),
      upfrontInsurance: _requiredInt(
        calculation['upfront_insurance'],
        'calculation.upfront_insurance',
      ),
      otherUpfrontCostLabel:
          calculation['other_upfront_cost_label']?.toString(),
      otherUpfrontCosts: _requiredInt(
        calculation['other_upfront_costs'],
        'calculation.other_upfront_costs',
      ),
      initialPayment: _requiredInt(
        calculation['initial_payment'],
        'calculation.initial_payment',
      ),
      totalPayment: _requiredInt(
        calculation['total_payment'],
        'calculation.total_payment',
      ),
      formulaVersion: _requiredString(
        json['formula_version'],
        'formula_version',
      ),
      validUntil: _date(json['valid_until']),
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      disclaimer: _requiredString(json['disclaimer'], 'disclaimer'),
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
        id: _requiredString(json['id'], 'follow_up.id'),
        referenceNo: _requiredString(
          json['reference_no'],
          'follow_up.reference_no',
        ),
        status: _requiredString(json['status'], 'follow_up.status'),
        statusLabel: _requiredString(
          json['status_label'],
          'follow_up.status_label',
        ),
        contactChannel: _requiredString(
          json['contact_channel'],
          'follow_up.contact_channel',
        ),
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
      'program': _requiredMap(json['program'], 'program'),
      'inputs': _requiredMap(json['inputs'], 'inputs'),
      'calculation': _requiredMap(json['calculation'], 'calculation'),
      'formula_version': json['formula_version'],
      'valid_until': json['valid_until'],
      'warnings': const <String>[],
      'disclaimer': json['disclaimer'],
    };
    return CreditSimulation(
      id: _requiredString(json['id'], 'id'),
      referenceNo: _requiredString(json['reference_no'], 'reference_no'),
      status: _requiredString(json['status'], 'status'),
      statusLabel: _requiredString(json['status_label'], 'status_label'),
      comparisonGroupId: json['comparison_group_id']?.toString(),
      calculation: CreditCalculation.fromJson(calculationJson),
      isProgramExpired: json['is_program_expired'] == true,
      followUp: json['follow_up'] is Map<String, dynamic>
          ? CreditFollowUp.fromJson(
              _requiredMap(json['follow_up'], 'follow_up'),
            )
          : null,
      savedAt: _requiredDate(json['saved_at'], 'saved_at'),
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
        otrPrice: _draftInt(json['otr_price']),
        cashDownPayment: _draftInt(json['cash_down_payment']),
        manualTradeInValue: _draftInt(json['manual_trade_in_value']),
        tradeInAppraisalId: json['trade_in_appraisal_id']?.toString(),
        useTradeInAsDp: json['use_trade_in_as_dp'] == true,
        oldVehiclePayoff: _draftInt(json['old_vehicle_payoff']),
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

Map<String, dynamic> _requiredMap(dynamic value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException(
      'Invalid credit API payload: $field must be an object.');
}

String _requiredString(dynamic value, String field) {
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Invalid credit API payload: $field must be a string.');
}

int _requiredInt(dynamic value, String field) {
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw FormatException(
      'Invalid credit API payload: $field must be an integer.');
}

int _draftInt(dynamic value) => value is num ? value.toInt() : 0;

int? _nullableInt(dynamic value) =>
    value == null ? null : _requiredInt(value, 'optional integer');

DateTime? _date(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) {
    throw const FormatException('Invalid credit API payload: invalid date.');
  }
  return parsed;
}

DateTime _requiredDate(dynamic value, String field) =>
    _date(value) ??
    (throw FormatException('Invalid credit API payload: $field is required.'));
