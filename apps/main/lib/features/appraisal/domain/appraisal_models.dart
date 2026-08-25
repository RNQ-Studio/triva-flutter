const appraisalPhotoAngles = <String>[
  'front',
  'rear',
  'left_side',
  'right_side',
  'dashboard_odometer',
];

class VehicleMakeOption {
  const VehicleMakeOption({
    required this.id,
    required this.slug,
    required this.name,
    this.logoUrl,
  });

  final int id;
  final String slug;
  final String name;
  final String? logoUrl;

  factory VehicleMakeOption.fromJson(Map<String, dynamic> json) =>
      VehicleMakeOption(
        id: (json['id'] as num).toInt(),
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        logoUrl: json['logo_url']?.toString(),
      );
}

class VehicleModelOption {
  const VehicleModelOption({
    required this.id,
    required this.makeId,
    required this.slug,
    required this.name,
  });

  final int id;
  final int makeId;
  final String slug;
  final String name;

  factory VehicleModelOption.fromJson(Map<String, dynamic> json) =>
      VehicleModelOption(
        id: (json['id'] as num).toInt(),
        makeId: (json['make_id'] as num).toInt(),
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class VehicleVariantOption {
  const VehicleVariantOption({
    required this.id,
    required this.modelId,
    required this.name,
    this.transmission,
    this.fuelType,
  });

  final int id;
  final int modelId;
  final String name;
  final String? transmission;
  final String? fuelType;

  factory VehicleVariantOption.fromJson(Map<String, dynamic> json) =>
      VehicleVariantOption(
        id: (json['id'] as num).toInt(),
        modelId: (json['model_id'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        transmission: json['transmission']?.toString(),
        fuelType: json['fuel_type']?.toString(),
      );
}

class VehicleData {
  const VehicleData({
    this.id,
    this.makeId,
    this.modelId,
    this.variantId,
    required this.make,
    required this.model,
    required this.variant,
    required this.year,
    required this.transmission,
    required this.fuelType,
    required this.mileage,
    required this.color,
    required this.licensePlate,
    this.provinceId,
    this.cityId,
    required this.city,
  });

  final String? id;
  final int? makeId;
  final int? modelId;
  final int? variantId;
  final String make;
  final String model;
  final String variant;
  final int year;
  final String transmission;
  final String fuelType;
  final int mileage;
  final String color;
  final String licensePlate;
  final int? provinceId;
  final int? cityId;
  final String city;

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
        id: json['id']?.toString(),
        makeId: (json['make_id'] as num?)?.toInt(),
        modelId: (json['model_id'] as num?)?.toInt(),
        variantId: (json['variant_id'] as num?)?.toInt(),
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        variant: json['variant']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        transmission: json['transmission']?.toString() ?? '',
        fuelType: json['fuel_type']?.toString() ?? '',
        mileage: (json['mileage'] as num?)?.toInt() ?? 0,
        color: json['color']?.toString() ?? '',
        licensePlate: json['license_plate']?.toString() ?? '',
        provinceId: (json['province_id'] as num?)?.toInt(),
        cityId: (json['city_id'] as num?)?.toInt(),
        city: json['city']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (makeId != null) 'make_id': makeId,
        if (modelId != null) 'model_id': modelId,
        if (variantId != null) 'variant_id': variantId,
        'make': make,
        'model': model,
        'variant': variant,
        'year': year,
        'transmission': transmission,
        'fuel_type': fuelType,
        'mileage': mileage,
        'color': color,
        'license_plate': licensePlate,
        if (provinceId != null) 'province_id': provinceId,
        if (cityId != null) 'city_id': cityId,
        'city': city,
      };
}

class AppraisalPhoto {
  const AppraisalPhoto({
    required this.id,
    required this.angle,
    required this.angleLabel,
    required this.reviewStatus,
    this.rejectionNote,
    this.url,
  });

  final String id;
  final String angle;
  final String angleLabel;
  final String reviewStatus;
  final String? rejectionNote;
  final String? url;

  factory AppraisalPhoto.fromJson(Map<String, dynamic> json) => AppraisalPhoto(
        id: json['id'].toString(),
        angle: json['angle']?.toString() ?? '',
        angleLabel: json['angle_label']?.toString() ?? '',
        reviewStatus: json['review_status']?.toString() ?? 'pending',
        rejectionNote: json['rejection_note']?.toString(),
        url: json['url']?.toString(),
      );
}

class AppraisalTimelineItem {
  const AppraisalTimelineItem({
    required this.status,
    required this.title,
    this.description,
    this.occurredAt,
  });

  final String status;
  final String title;
  final String? description;
  final DateTime? occurredAt;

  factory AppraisalTimelineItem.fromJson(Map<String, dynamic> json) =>
      AppraisalTimelineItem(
        status: json['status']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? ''),
      );
}

class AppraisalResultData {
  const AppraisalResultData({
    required this.tradeInLow,
    required this.tradeInHigh,
    required this.marketLow,
    required this.marketMid,
    required this.marketHigh,
    required this.confidence,
    required this.comparableCount,
    required this.sources,
    required this.adjustments,
    required this.dataAsOf,
    required this.validUntil,
    required this.requiresPhysicalInspection,
    required this.disclaimer,
  });

  final int tradeInLow;
  final int tradeInHigh;
  final int marketLow;
  final int marketMid;
  final int marketHigh;
  final String confidence;
  final int comparableCount;
  final List<AppraisalResultSource> sources;
  final List<AppraisalAdjustment> adjustments;
  final DateTime? dataAsOf;
  final DateTime? validUntil;
  final bool requiresPhysicalInspection;
  final String disclaimer;

  factory AppraisalResultData.fromJson(Map<String, dynamic> json) {
    final tradeIn =
        json['trade_in_estimate'] as Map<String, dynamic>? ?? const {};
    final market = json['market_price'] as Map<String, dynamic>? ?? const {};
    return AppraisalResultData(
      tradeInLow: (tradeIn['low'] as num?)?.toInt() ?? 0,
      tradeInHigh: (tradeIn['high'] as num?)?.toInt() ?? 0,
      marketLow: (market['low'] as num?)?.toInt() ?? 0,
      marketMid: (market['mid'] as num?)?.toInt() ?? 0,
      marketHigh: (market['high'] as num?)?.toInt() ?? 0,
      confidence: json['confidence']?.toString() ?? 'low',
      comparableCount: (json['comparable_count'] as num?)?.toInt() ?? 0,
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppraisalResultSource.fromJson)
          .toList(growable: false),
      adjustments: (json['adjustments'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppraisalAdjustment.fromJson)
          .where((adjustment) => adjustment.label.isNotEmpty)
          .toList(growable: false),
      dataAsOf: DateTime.tryParse(json['data_as_of']?.toString() ?? ''),
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? ''),
      requiresPhysicalInspection:
          json['requires_physical_inspection'] as bool? ?? true,
      disclaimer: json['disclaimer']?.toString() ?? '',
    );
  }
}

class AppraisalResultSource {
  const AppraisalResultSource({
    required this.code,
    required this.label,
    required this.comparableCount,
  });

  final String code;
  final String label;
  final int comparableCount;

  factory AppraisalResultSource.fromJson(Map<String, dynamic> json) =>
      AppraisalResultSource(
        code: json['code']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        comparableCount: (json['comparable_count'] as num?)?.toInt() ?? 0,
      );
}

class AppraisalAdjustment {
  const AppraisalAdjustment({required this.code, required this.label});

  final String code;
  final String label;

  factory AppraisalAdjustment.fromJson(Map<String, dynamic> json) =>
      AppraisalAdjustment(
        code: json['code']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );
}

class AppraisalConditionData {
  const AppraisalConditionData({
    required this.taxStatus,
    required this.floodHistory,
    required this.majorAccidentHistory,
    required this.serviceHistory,
    required this.ownership,
    required this.conditionPercentage,
    required this.engineCondition,
    required this.tyreCondition,
  });

  final String taxStatus;
  final String floodHistory;
  final String majorAccidentHistory;
  final String serviceHistory;
  final String ownership;
  final int conditionPercentage;
  final String engineCondition;
  final String tyreCondition;

  factory AppraisalConditionData.fromJson(Map<String, dynamic> json) =>
      AppraisalConditionData(
        taxStatus: json['tax_status']?.toString() ?? '',
        floodHistory: json['flood_history']?.toString() ?? '',
        majorAccidentHistory: json['major_accident_history']?.toString() ?? '',
        serviceHistory: json['service_history']?.toString() ?? '',
        ownership: json['ownership']?.toString() ?? '',
        conditionPercentage:
            ((json['condition_percentage'] as num?)?.toInt() ?? 0)
                .clamp(0, 100)
                .toInt(),
        engineCondition: json['engine_condition']?.toString() ?? '',
        tyreCondition: json['tyre_condition']?.toString() ?? '',
      );
}

class AppraisalContinuation {
  const AppraisalContinuation({
    required this.type,
    this.vehicleId,
    this.appraisalId,
    this.suggestedTradeInLow,
    this.suggestedTradeInHigh,
  });

  final String type;
  final String? vehicleId;
  final String? appraisalId;
  final int? suggestedTradeInLow;
  final int? suggestedTradeInHigh;

  factory AppraisalContinuation.fromJson(Map<String, dynamic> json) =>
      AppraisalContinuation(
        type: json['type']?.toString() ?? '',
        vehicleId: json['vehicle_id']?.toString(),
        appraisalId: json['appraisal_id']?.toString(),
        suggestedTradeInLow: (json['suggested_trade_in_low'] as num?)?.toInt(),
        suggestedTradeInHigh:
            (json['suggested_trade_in_high'] as num?)?.toInt(),
      );
}

class AppraisalData {
  const AppraisalData({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    this.vehicle,
    this.condition,
    this.photos = const [],
    this.timeline = const [],
    this.result,
    this.customerDecision,
    this.continuation,
    this.submittedAt,
    this.dueAt,
    this.inspectionScheduledAt,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final VehicleData? vehicle;
  final AppraisalConditionData? condition;
  final List<AppraisalPhoto> photos;
  final List<AppraisalTimelineItem> timeline;
  final AppraisalResultData? result;
  final String? customerDecision;
  final AppraisalContinuation? continuation;
  final DateTime? submittedAt;
  final DateTime? dueAt;
  final DateTime? inspectionScheduledAt;

  bool get needsAction => status == 'needs_customer_action';
  bool get resultReady => status == 'result_ready';
  bool get processingFailed =>
      status == 'failed' || status == 'insufficient_comparables';
  bool get isComplete => const {
        'accepted_by_customer',
        'rejected_by_customer',
        'inspection_scheduled',
        'converted',
      }.contains(status);

  factory AppraisalData.fromJson(Map<String, dynamic> json) => AppraisalData(
        id: json['id'].toString(),
        referenceNo: json['reference_no']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        statusLabel: json['status_label']?.toString() ?? '',
        vehicle: json['vehicle'] is Map<String, dynamic>
            ? VehicleData.fromJson(json['vehicle'] as Map<String, dynamic>)
            : null,
        condition: json['condition'] is Map<String, dynamic>
            ? AppraisalConditionData.fromJson(
                json['condition'] as Map<String, dynamic>,
              )
            : null,
        photos: (json['photos'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AppraisalPhoto.fromJson)
            .toList(growable: false),
        timeline: (json['timeline'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AppraisalTimelineItem.fromJson)
            .toList(growable: false),
        result: json['result'] is Map<String, dynamic>
            ? AppraisalResultData.fromJson(
                json['result'] as Map<String, dynamic>,
              )
            : null,
        customerDecision: json['customer_decision']?.toString(),
        continuation: json['continuation'] is Map<String, dynamic>
            ? AppraisalContinuation.fromJson(
                json['continuation'] as Map<String, dynamic>,
              )
            : null,
        submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? ''),
        dueAt: DateTime.tryParse(json['due_at']?.toString() ?? ''),
        inspectionScheduledAt: DateTime.tryParse(
          json['inspection_scheduled_at']?.toString() ?? '',
        ),
      );
}

class AppraisalDraft {
  const AppraisalDraft({
    this.makeId,
    this.modelId,
    this.variantId,
    this.make = '',
    this.model = '',
    this.variant = '',
    this.year,
    this.transmission = '',
    this.fuelType = '',
    this.mileage,
    this.color = '',
    this.licensePlate = '',
    this.provinceId,
    this.cityId,
    this.city = '',
    this.taxStatus = '',
    this.floodHistory = '',
    this.majorAccidentHistory = '',
    this.serviceHistory = '',
    this.ownership = '',
    this.conditionPercentage = 90,
    this.engineCondition = '',
    this.tyreCondition = '',
    this.photoPaths = const {},
    this.assetIds = const {},
    this.vehicleId,
    this.appraisalId,
    this.vehicleCreationIdempotencyKey,
    this.appraisalCreationIdempotencyKey,
    this.idempotencyKey,
    this.marketingConsent = false,
  });

  final int? makeId;
  final int? modelId;
  final int? variantId;
  final String make;
  final String model;
  final String variant;
  final int? year;
  final String transmission;
  final String fuelType;
  final int? mileage;
  final String color;
  final String licensePlate;
  final int? provinceId;
  final int? cityId;
  final String city;
  final String taxStatus;
  final String floodHistory;
  final String majorAccidentHistory;
  final String serviceHistory;
  final String ownership;
  final int conditionPercentage;
  final String engineCondition;
  final String tyreCondition;
  final Map<String, String> photoPaths;
  final Map<String, String> assetIds;
  final String? vehicleId;
  final String? appraisalId;
  final String? vehicleCreationIdempotencyKey;
  final String? appraisalCreationIdempotencyKey;
  final String? idempotencyKey;
  final bool marketingConsent;

  bool get hasIdentity =>
      makeId != null &&
      make.isNotEmpty &&
      model.isNotEmpty &&
      variant.isNotEmpty &&
      year != null;
  bool get hasDetails =>
      transmission.isNotEmpty &&
      fuelType.isNotEmpty &&
      mileage != null &&
      color.isNotEmpty &&
      licensePlate.isNotEmpty &&
      provinceId != null &&
      cityId != null &&
      city.isNotEmpty;
  bool get hasCondition =>
      taxStatus.isNotEmpty &&
      floodHistory.isNotEmpty &&
      majorAccidentHistory.isNotEmpty &&
      serviceHistory.isNotEmpty &&
      ownership.isNotEmpty &&
      engineCondition.isNotEmpty &&
      tyreCondition.isNotEmpty &&
      conditionPercentage >= 0 &&
      conditionPercentage <= 100;
  bool get hasAllPhotos => appraisalPhotoAngles.every(photoPaths.containsKey);

  AppraisalDraft copyWith({
    int? makeId,
    int? modelId,
    int? variantId,
    bool clearVariantId = false,
    String? make,
    String? model,
    String? variant,
    int? year,
    String? transmission,
    String? fuelType,
    int? mileage,
    String? color,
    String? licensePlate,
    int? provinceId,
    int? cityId,
    String? city,
    String? taxStatus,
    String? floodHistory,
    String? majorAccidentHistory,
    String? serviceHistory,
    String? ownership,
    int? conditionPercentage,
    String? engineCondition,
    String? tyreCondition,
    Map<String, String>? photoPaths,
    Map<String, String>? assetIds,
    String? vehicleId,
    String? appraisalId,
    String? vehicleCreationIdempotencyKey,
    String? appraisalCreationIdempotencyKey,
    String? idempotencyKey,
    bool clearVehicleCreationIdempotencyKey = false,
    bool clearAppraisalCreationIdempotencyKey = false,
    bool? marketingConsent,
  }) =>
      AppraisalDraft(
        makeId: makeId ?? this.makeId,
        modelId: modelId ?? this.modelId,
        variantId: clearVariantId ? null : variantId ?? this.variantId,
        make: make ?? this.make,
        model: model ?? this.model,
        variant: variant ?? this.variant,
        year: year ?? this.year,
        transmission: transmission ?? this.transmission,
        fuelType: fuelType ?? this.fuelType,
        mileage: mileage ?? this.mileage,
        color: color ?? this.color,
        licensePlate: licensePlate ?? this.licensePlate,
        provinceId: provinceId ?? this.provinceId,
        cityId: cityId ?? this.cityId,
        city: city ?? this.city,
        taxStatus: taxStatus ?? this.taxStatus,
        floodHistory: floodHistory ?? this.floodHistory,
        majorAccidentHistory: majorAccidentHistory ?? this.majorAccidentHistory,
        serviceHistory: serviceHistory ?? this.serviceHistory,
        ownership: ownership ?? this.ownership,
        conditionPercentage: conditionPercentage ?? this.conditionPercentage,
        engineCondition: engineCondition ?? this.engineCondition,
        tyreCondition: tyreCondition ?? this.tyreCondition,
        photoPaths: photoPaths ?? this.photoPaths,
        assetIds: assetIds ?? this.assetIds,
        vehicleId: vehicleId ?? this.vehicleId,
        appraisalId: appraisalId ?? this.appraisalId,
        vehicleCreationIdempotencyKey: clearVehicleCreationIdempotencyKey
            ? null
            : vehicleCreationIdempotencyKey ??
                this.vehicleCreationIdempotencyKey,
        appraisalCreationIdempotencyKey: clearAppraisalCreationIdempotencyKey
            ? null
            : appraisalCreationIdempotencyKey ??
                this.appraisalCreationIdempotencyKey,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        marketingConsent: marketingConsent ?? this.marketingConsent,
      );

  factory AppraisalDraft.fromJson(Map<String, dynamic> json) => AppraisalDraft(
        makeId: (json['make_id'] as num?)?.toInt(),
        modelId: (json['model_id'] as num?)?.toInt(),
        variantId: (json['variant_id'] as num?)?.toInt(),
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        variant: json['variant']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt(),
        transmission: json['transmission']?.toString() ?? '',
        fuelType: json['fuel_type']?.toString() ?? '',
        mileage: (json['mileage'] as num?)?.toInt(),
        color: json['color']?.toString() ?? '',
        licensePlate: json['license_plate']?.toString() ?? '',
        provinceId: (json['province_id'] as num?)?.toInt(),
        cityId: (json['city_id'] as num?)?.toInt(),
        city: json['city']?.toString() ?? '',
        taxStatus: json['tax_status']?.toString() ?? '',
        floodHistory: json['flood_history']?.toString() ?? '',
        majorAccidentHistory: json['major_accident_history']?.toString() ?? '',
        serviceHistory: json['service_history']?.toString() ?? '',
        ownership: json['ownership']?.toString() ?? '',
        conditionPercentage:
            ((json['condition_percentage'] as num?)?.toInt() ?? 90)
                .clamp(0, 100)
                .toInt(),
        engineCondition: json['engine_condition']?.toString() ?? '',
        tyreCondition: json['tyre_condition']?.toString() ?? '',
        photoPaths: Map<String, String>.from(
          json['photo_paths'] as Map<String, dynamic>? ?? const {},
        ),
        assetIds: Map<String, String>.from(
          json['asset_ids'] as Map<String, dynamic>? ?? const {},
        ),
        vehicleId: json['vehicle_id']?.toString(),
        appraisalId: json['appraisal_id']?.toString(),
        vehicleCreationIdempotencyKey:
            json['vehicle_creation_idempotency_key']?.toString(),
        appraisalCreationIdempotencyKey:
            json['appraisal_creation_idempotency_key']?.toString(),
        idempotencyKey: json['idempotency_key']?.toString(),
        marketingConsent: json['marketing_consent'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'make_id': makeId,
        'model_id': modelId,
        'variant_id': variantId,
        'make': make,
        'model': model,
        'variant': variant,
        'year': year,
        'transmission': transmission,
        'fuel_type': fuelType,
        'mileage': mileage,
        'color': color,
        'license_plate': licensePlate,
        'province_id': provinceId,
        'city_id': cityId,
        'city': city,
        'tax_status': taxStatus,
        'flood_history': floodHistory,
        'major_accident_history': majorAccidentHistory,
        'service_history': serviceHistory,
        'ownership': ownership,
        'condition_percentage': conditionPercentage,
        'engine_condition': engineCondition,
        'tyre_condition': tyreCondition,
        'photo_paths': photoPaths,
        'asset_ids': assetIds,
        'vehicle_id': vehicleId,
        'appraisal_id': appraisalId,
        'vehicle_creation_idempotency_key': vehicleCreationIdempotencyKey,
        'appraisal_creation_idempotency_key': appraisalCreationIdempotencyKey,
        'idempotency_key': idempotencyKey,
        'marketing_consent': marketingConsent,
      };

  VehicleData toVehicle() => VehicleData(
        id: vehicleId,
        makeId: makeId,
        modelId: modelId,
        variantId: variantId,
        make: make,
        model: model,
        variant: variant,
        year: year!,
        transmission: transmission,
        fuelType: fuelType,
        mileage: mileage!,
        color: color,
        licensePlate: licensePlate,
        provinceId: provinceId,
        cityId: cityId,
        city: city,
      );

  Map<String, dynamic> get conditionJson => {
        'tax_status': taxStatus,
        'flood_history': floodHistory,
        'major_accident_history': majorAccidentHistory,
        'service_history': serviceHistory,
        'ownership': ownership,
        'condition_percentage': conditionPercentage,
        'engine_condition': engineCondition,
        'tyre_condition': tyreCondition,
      };
}
