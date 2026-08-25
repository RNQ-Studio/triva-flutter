import '../../toyota_service/domain/toyota_service_models.dart';

class BodyPaintOption {
  const BodyPaintOption({
    required this.value,
    required this.label,
    this.isHighRisk = false,
  });

  final String value;
  final String label;
  final bool isHighRisk;

  factory BodyPaintOption.fromJson(Map<String, dynamic> json) =>
      BodyPaintOption(
        value: json['value']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        isHighRisk: json['is_high_risk'] as bool? ?? false,
      );
}

class BodyPaintOptions {
  const BodyPaintOptions({
    required this.panels,
    required this.damageTypes,
    required this.severities,
    required this.workTypes,
    required this.locations,
    required this.maximumPhotos,
    required this.disclaimer,
    required this.serviceTypeId,
  });

  final List<BodyPaintOption> panels;
  final List<BodyPaintOption> damageTypes;
  final List<BodyPaintOption> severities;
  final List<BodyPaintOption> workTypes;
  final List<ToyotaServiceLocation> locations;
  final int maximumPhotos;
  final String disclaimer;
  final String? serviceTypeId;

  factory BodyPaintOptions.fromJson(Map<String, dynamic> json) {
    List<BodyPaintOption> readOptions(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BodyPaintOption.fromJson)
            .toList(growable: false);
    final upload = json['photo_upload'] as Map<String, dynamic>? ?? const {};
    final booking = json['booking'] as Map<String, dynamic>? ?? const {};
    return BodyPaintOptions(
      panels: readOptions('panels'),
      damageTypes: readOptions('damage_types'),
      severities: readOptions('severities'),
      workTypes: readOptions('work_types'),
      locations: (json['service_locations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServiceLocation.fromJson)
          .toList(growable: false),
      maximumPhotos: (upload['maximum_count'] as num?)?.toInt() ?? 10,
      disclaimer: json['disclaimer']?.toString() ?? '',
      serviceTypeId: booking['service_type_id']?.toString(),
    );
  }
}

class BodyPaintDraftDamage {
  const BodyPaintDraftDamage({
    required this.key,
    this.remoteId,
    this.panelCode = '',
    this.damageType = '',
    this.severity = 'unsure',
    this.note = '',
    this.closePhotoAssetId,
    this.closePhotoName,
  });

  final String key;
  final String? remoteId;
  final String panelCode;
  final String damageType;
  final String severity;
  final String note;
  final String? closePhotoAssetId;
  final String? closePhotoName;

  bool get isComplete =>
      panelCode.isNotEmpty &&
      damageType.isNotEmpty &&
      severity.isNotEmpty &&
      closePhotoAssetId != null;

  BodyPaintDraftDamage copyWith({
    String? remoteId,
    String? panelCode,
    String? damageType,
    String? severity,
    String? note,
    String? closePhotoAssetId,
    String? closePhotoName,
    bool clearPhoto = false,
  }) =>
      BodyPaintDraftDamage(
        key: key,
        remoteId: remoteId ?? this.remoteId,
        panelCode: panelCode ?? this.panelCode,
        damageType: damageType ?? this.damageType,
        severity: severity ?? this.severity,
        note: note ?? this.note,
        closePhotoAssetId:
            clearPhoto ? null : closePhotoAssetId ?? this.closePhotoAssetId,
        closePhotoName:
            clearPhoto ? null : closePhotoName ?? this.closePhotoName,
      );

  factory BodyPaintDraftDamage.fromJson(Map<String, dynamic> json) =>
      BodyPaintDraftDamage(
        key: json['key']?.toString() ?? '',
        remoteId: json['remote_id']?.toString(),
        panelCode: json['panel_code']?.toString() ?? '',
        damageType: json['damage_type']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'unsure',
        note: json['note']?.toString() ?? '',
        closePhotoAssetId: json['close_photo_asset_id']?.toString(),
        closePhotoName: json['close_photo_name']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'remote_id': remoteId,
        'panel_code': panelCode,
        'damage_type': damageType,
        'severity': severity,
        'note': note,
        'close_photo_asset_id': closePhotoAssetId,
        'close_photo_name': closePhotoName,
      };
}

class BodyPaintDraft {
  const BodyPaintDraft({
    this.estimateId,
    this.sourceAppraisalId,
    this.vehicle,
    this.location,
    this.damages = const [],
    this.contextPhotoAssetId,
    this.contextPhotoName,
    this.notes = '',
    this.isInsured = false,
    this.insuranceProvider = '',
    this.consent = false,
    this.idempotencyKey,
  });

  final String? estimateId;
  final String? sourceAppraisalId;
  final ToyotaServiceVehicle? vehicle;
  final ToyotaServiceLocation? location;
  final List<BodyPaintDraftDamage> damages;
  final String? contextPhotoAssetId;
  final String? contextPhotoName;
  final String notes;

  /// Apakah kendaraan diasuransikan. Bila ya, estimasi biaya tidak
  /// ditampilkan karena perbaikannya mengikuti klaim.
  final bool isInsured;
  final String insuranceProvider;
  final bool consent;
  final String? idempotencyKey;

  bool get canSubmit =>
      vehicle != null &&
      location != null &&
      damages.isNotEmpty &&
      damages.every((damage) => damage.isComplete) &&
      contextPhotoAssetId != null &&
      (!isInsured || insuranceProvider.trim().isNotEmpty) &&
      consent;

  BodyPaintDraft copyWith({
    String? estimateId,
    String? sourceAppraisalId,
    ToyotaServiceVehicle? vehicle,
    ToyotaServiceLocation? location,
    List<BodyPaintDraftDamage>? damages,
    String? contextPhotoAssetId,
    String? contextPhotoName,
    String? notes,
    bool? isInsured,
    String? insuranceProvider,
    bool? consent,
    String? idempotencyKey,
    bool clearRemote = false,
  }) =>
      BodyPaintDraft(
        estimateId: clearRemote ? null : estimateId ?? this.estimateId,
        sourceAppraisalId: sourceAppraisalId ?? this.sourceAppraisalId,
        vehicle: vehicle ?? this.vehicle,
        location: location ?? this.location,
        damages: damages ?? this.damages,
        contextPhotoAssetId: contextPhotoAssetId ?? this.contextPhotoAssetId,
        contextPhotoName: contextPhotoName ?? this.contextPhotoName,
        notes: notes ?? this.notes,
        isInsured: isInsured ?? this.isInsured,
        insuranceProvider: insuranceProvider ?? this.insuranceProvider,
        consent: consent ?? this.consent,
        idempotencyKey:
            clearRemote ? null : idempotencyKey ?? this.idempotencyKey,
      );

  factory BodyPaintDraft.fromJson(Map<String, dynamic> json) => BodyPaintDraft(
        estimateId: json['estimate_id']?.toString(),
        sourceAppraisalId: json['source_appraisal_id']?.toString(),
        vehicle: json['vehicle'] is Map<String, dynamic>
            ? ToyotaServiceVehicle.fromJson(
                json['vehicle'] as Map<String, dynamic>,
              )
            : null,
        location: json['location'] is Map<String, dynamic>
            ? ToyotaServiceLocation.fromJson(
                json['location'] as Map<String, dynamic>,
              )
            : null,
        damages: (json['damages'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BodyPaintDraftDamage.fromJson)
            .toList(growable: false),
        contextPhotoAssetId: json['context_photo_asset_id']?.toString(),
        contextPhotoName: json['context_photo_name']?.toString(),
        notes: json['notes']?.toString() ?? '',
        isInsured: json['is_insured'] as bool? ?? false,
        insuranceProvider: json['insurance_provider']?.toString() ?? '',
        consent: json['consent'] as bool? ?? false,
        idempotencyKey: json['idempotency_key']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'estimate_id': estimateId,
        'source_appraisal_id': sourceAppraisalId,
        'vehicle': vehicle?.toJson(),
        'location': location == null
            ? null
            : {
                'id': location!.id,
                'name': location!.name,
                'address': location!.address,
                'city': location!.city,
              },
        'damages': damages.map((damage) => damage.toJson()).toList(),
        'context_photo_asset_id': contextPhotoAssetId,
        'context_photo_name': contextPhotoName,
        'notes': notes,
        'is_insured': isInsured,
        'insurance_provider': insuranceProvider,
        'consent': consent,
        'idempotency_key': idempotencyKey,
      };
}

class BodyPaintPhoto {
  const BodyPaintPhoto({
    required this.id,
    required this.assetId,
    required this.type,
    required this.reviewStatus,
    this.rejectionReason,
    this.url,
  });

  final String id;
  final String assetId;
  final String type;
  final String reviewStatus;
  final String? rejectionReason;
  final String? url;

  bool get isRejected => reviewStatus == 'rejected';

  factory BodyPaintPhoto.fromJson(Map<String, dynamic> json) => BodyPaintPhoto(
        id: json['id']?.toString() ?? '',
        assetId: json['asset_id']?.toString() ?? '',
        type: json['photo_type']?.toString() ?? '',
        reviewStatus: json['review_status']?.toString() ?? 'pending',
        rejectionReason: json['rejection_reason']?.toString(),
        url: json['temporary_url']?.toString(),
      );
}

class BodyPaintDamage {
  const BodyPaintDamage({
    required this.id,
    required this.panelCode,
    required this.panelLabel,
    required this.damageType,
    required this.damageTypeLabel,
    required this.severity,
    required this.isHighRisk,
    required this.photos,
    this.note,
  });

  final String id;
  final String panelCode;
  final String panelLabel;
  final String damageType;
  final String damageTypeLabel;
  final String severity;
  final bool isHighRisk;
  final String? note;
  final List<BodyPaintPhoto> photos;

  factory BodyPaintDamage.fromJson(Map<String, dynamic> json) =>
      BodyPaintDamage(
        id: json['id']?.toString() ?? '',
        panelCode: json['panel_code']?.toString() ?? '',
        panelLabel: json['panel_label']?.toString() ?? '',
        damageType: json['damage_type']?.toString() ?? '',
        damageTypeLabel: json['damage_type_label']?.toString() ?? '',
        severity: json['customer_severity']?.toString() ?? 'unsure',
        isHighRisk: json['is_high_risk'] as bool? ?? false,
        note: json['customer_note']?.toString(),
        photos: (json['photos'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BodyPaintPhoto.fromJson)
            .toList(growable: false),
      );
}

class BodyPaintEstimateItem {
  const BodyPaintEstimateItem({
    required this.damageId,
    required this.panelCode,
    required this.panelLabel,
    required this.damageType,
    required this.workType,
    required this.workTypeLabel,
    required this.severity,
    required this.laborLow,
    required this.laborHigh,
    required this.materialLow,
    required this.materialHigh,
    required this.partsLow,
    required this.partsHigh,
    required this.otherLow,
    required this.otherHigh,
    required this.totalLow,
    required this.totalHigh,
    required this.durationMinHours,
    required this.durationMaxHours,
    this.recommendation,
  });

  final String damageId;
  final String panelCode;
  final String panelLabel;
  final String damageType;
  final String workType;
  final String workTypeLabel;
  final String severity;
  final int laborLow;
  final int laborHigh;
  final int materialLow;
  final int materialHigh;
  final int partsLow;
  final int partsHigh;
  final int otherLow;
  final int otherHigh;
  final int totalLow;
  final int totalHigh;
  final int durationMinHours;
  final int durationMaxHours;
  final String? recommendation;

  factory BodyPaintEstimateItem.fromJson(Map<String, dynamic> json) {
    final cost = json['cost'] as Map<String, dynamic>? ?? const {};
    return BodyPaintEstimateItem(
      damageId: json['damage_id']?.toString() ?? '',
      panelCode: json['panel_code']?.toString() ?? '',
      panelLabel: json['panel_label']?.toString() ??
          json['panel_code']?.toString() ??
          '',
      damageType: json['damage_type']?.toString() ?? '',
      workType: json['work_type']?.toString() ?? 'repair',
      workTypeLabel: json['work_type_label']?.toString() ??
          json['work_type']?.toString() ??
          '',
      severity: json['severity_label']?.toString() ??
          json['severity']?.toString() ??
          '',
      laborLow: _cost(json, cost, 'labor_low'),
      laborHigh: _cost(json, cost, 'labor_high'),
      materialLow: _cost(json, cost, 'material_low'),
      materialHigh: _cost(json, cost, 'material_high'),
      partsLow: _cost(json, cost, 'parts_low'),
      partsHigh: _cost(json, cost, 'parts_high'),
      otherLow: _cost(json, cost, 'other_low'),
      otherHigh: _cost(json, cost, 'other_high'),
      totalLow: (cost['total_low'] as num?)?.toInt() ??
          _sumCost(json,
              const ['labor_low', 'material_low', 'parts_low', 'other_low']),
      totalHigh: (cost['total_high'] as num?)?.toInt() ??
          _sumCost(json, const [
            'labor_high',
            'material_high',
            'parts_high',
            'other_high'
          ]),
      durationMinHours: (json['duration_min_hours'] as num?)?.toInt() ?? 1,
      durationMaxHours: (json['duration_max_hours'] as num?)?.toInt() ?? 1,
      recommendation: json['recommendation']?.toString(),
    );
  }

  static int _sumCost(Map<String, dynamic> json, List<String> keys) =>
      keys.fold(0, (sum, key) => sum + ((json[key] as num?)?.toInt() ?? 0));

  static int _cost(
    Map<String, dynamic> json,
    Map<String, dynamic> cost,
    String key,
  ) =>
      (cost[key] as num?)?.toInt() ?? (json[key] as num?)?.toInt() ?? 0;
}

class BodyPaintResult {
  const BodyPaintResult({
    required this.version,
    required this.low,
    required this.high,
    required this.minDays,
    required this.maxDays,
    required this.items,
    required this.assumptions,
    required this.disclaimer,
    this.validUntil,
    this.isInsured = false,
    this.insuranceNotice,
    this.insuranceProvider,
  });

  final int version;
  final int low;
  final int high;
  final int minDays;
  final int maxDays;
  final List<BodyPaintEstimateItem> items;
  final List<String> assumptions;
  final String disclaimer;
  final DateTime? validUntil;

  /// Kendaraan yang diasuransikan tidak menerima nominal estimasi karena
  /// biayanya ditentukan klaim. Notulensi 19 Agustus 2026.
  final bool isInsured;
  final String? insuranceNotice;
  final String? insuranceProvider;

  bool get showsCost => !isInsured;

  factory BodyPaintResult.fromJson(Map<String, dynamic> json) {
    final duration = json['duration'] as Map<String, dynamic>? ?? const {};
    return BodyPaintResult(
      version: (json['version'] as num?)?.toInt() ?? 1,
      low: (json['low'] as num?)?.toInt() ?? 0,
      high: (json['high'] as num?)?.toInt() ?? 0,
      minDays: (duration['min_days'] as num?)?.toInt() ?? 1,
      maxDays: (duration['max_days'] as num?)?.toInt() ?? 1,
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BodyPaintEstimateItem.fromJson)
          .toList(growable: false),
      assumptions: (json['assumptions'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
      disclaimer: json['disclaimer']?.toString() ?? '',
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? ''),
      isInsured: json['is_insured'] == true,
      insuranceNotice: json['insurance_notice']?.toString(),
      insuranceProvider: json['insurance_provider']?.toString(),
    );
  }
}

class BodyPaintTimelineItem {
  const BodyPaintTimelineItem({
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final String title;
  final String description;
  final DateTime? createdAt;

  factory BodyPaintTimelineItem.fromJson(Map<String, dynamic> json) =>
      BodyPaintTimelineItem(
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

class BodyPaintEstimate {
  const BodyPaintEstimate({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.allowedActions,
    required this.damages,
    required this.contextPhotos,
    required this.timeline,
    required this.requiresPhysicalInspection,
    this.vehicle,
    this.location,
    this.result,
    this.bookingId,
    this.bookingRoute,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.assignedEstimatorName,
    this.hasHighRiskDamage = false,
    this.engineLow,
    this.engineHigh,
    this.engineItems = const [],
    this.availableAdminActions = const [],
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final List<String> allowedActions;
  final ToyotaServiceVehicle? vehicle;
  final ToyotaServiceLocation? location;
  final List<BodyPaintDamage> damages;
  final List<BodyPaintPhoto> contextPhotos;
  final BodyPaintResult? result;
  final List<BodyPaintTimelineItem> timeline;
  final bool requiresPhysicalInspection;
  final String? bookingId;
  final String? bookingRoute;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? assignedEstimatorName;
  final bool hasHighRiskDamage;
  final int? engineLow;
  final int? engineHigh;
  final List<BodyPaintEstimateItem> engineItems;
  final List<BodyPaintOption> availableAdminActions;

  bool allows(String action) => allowedActions.contains(action);

  factory BodyPaintEstimate.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final estimator = json['assigned_estimator'] as Map<String, dynamic>?;
    final engine = json['engine_estimate'] as Map<String, dynamic>?;
    return BodyPaintEstimate(
      id: json['id']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      allowedActions:
          (json['allowed_customer_actions'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(growable: false),
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? ToyotaServiceVehicle.fromJson(
              json['vehicle'] as Map<String, dynamic>,
            )
          : null,
      location: json['service_location'] is Map<String, dynamic>
          ? ToyotaServiceLocation.fromJson(
              json['service_location'] as Map<String, dynamic>,
            )
          : null,
      damages: (json['damages'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BodyPaintDamage.fromJson)
          .toList(growable: false),
      contextPhotos: (json['context_photos'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BodyPaintPhoto.fromJson)
          .toList(growable: false),
      result: json['estimate'] is Map<String, dynamic>
          ? BodyPaintResult.fromJson(json['estimate'] as Map<String, dynamic>)
          : null,
      timeline: (json['timeline'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BodyPaintTimelineItem.fromJson)
          .toList(growable: false),
      requiresPhysicalInspection:
          json['requires_physical_inspection'] as bool? ?? true,
      bookingId: booking?['id']?.toString(),
      bookingRoute: booking?['route']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      customerName: customer?['name']?.toString(),
      assignedEstimatorName: estimator?['name']?.toString(),
      hasHighRiskDamage: json['has_high_risk_damage'] as bool? ?? false,
      engineLow: (engine?['low'] as num?)?.toInt(),
      engineHigh: (engine?['high'] as num?)?.toInt(),
      engineItems: (engine?['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BodyPaintEstimateItem.fromJson)
          .toList(growable: false),
      availableAdminActions:
          (json['available_actions'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(BodyPaintOption.fromJson)
              .toList(growable: false),
    );
  }
}
