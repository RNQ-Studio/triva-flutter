const appraisalPhotoAngles = <String>[
  'front',
  'rear',
  'left_side',
  'right_side',
  'dashboard_odometer',
];

class VehicleData {
  const VehicleData({
    this.id,
    required this.make,
    required this.model,
    required this.variant,
    required this.year,
    required this.transmission,
    required this.fuelType,
    required this.mileage,
    required this.color,
    required this.licensePlate,
    required this.city,
  });

  final String? id;
  final String make;
  final String model;
  final String variant;
  final int year;
  final String transmission;
  final String fuelType;
  final int mileage;
  final String color;
  final String licensePlate;
  final String city;

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
        id: json['id']?.toString(),
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        variant: json['variant']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        transmission: json['transmission']?.toString() ?? '',
        fuelType: json['fuel_type']?.toString() ?? '',
        mileage: (json['mileage'] as num?)?.toInt() ?? 0,
        color: json['color']?.toString() ?? '',
        licensePlate: json['license_plate']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'make': make,
        'model': model,
        'variant': variant,
        'year': year,
        'transmission': transmission,
        'fuel_type': fuelType,
        'mileage': mileage,
        'color': color,
        'license_plate': licensePlate,
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
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? ''),
      requiresPhysicalInspection:
          json['requires_physical_inspection'] as bool? ?? true,
      disclaimer: json['disclaimer']?.toString() ?? '',
    );
  }
}

class AppraisalData {
  const AppraisalData({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    this.vehicle,
    this.photos = const [],
    this.timeline = const [],
    this.result,
    this.customerDecision,
    this.submittedAt,
    this.dueAt,
    this.inspectionScheduledAt,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final VehicleData? vehicle;
  final List<AppraisalPhoto> photos;
  final List<AppraisalTimelineItem> timeline;
  final AppraisalResultData? result;
  final String? customerDecision;
  final DateTime? submittedAt;
  final DateTime? dueAt;
  final DateTime? inspectionScheduledAt;

  bool get needsAction => status == 'needs_customer_action';
  bool get resultReady => status == 'result_ready';
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
        submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? ''),
        dueAt: DateTime.tryParse(json['due_at']?.toString() ?? ''),
        inspectionScheduledAt: DateTime.tryParse(
          json['inspection_scheduled_at']?.toString() ?? '',
        ),
      );
}

class AppraisalDraft {
  const AppraisalDraft({
    this.make = '',
    this.model = '',
    this.variant = '',
    this.year,
    this.transmission = '',
    this.fuelType = '',
    this.mileage,
    this.color = '',
    this.licensePlate = '',
    this.city = '',
    this.taxStatus = '',
    this.floodHistory = '',
    this.majorAccidentHistory = '',
    this.serviceHistory = '',
    this.ownership = '',
    this.photoPaths = const {},
    this.assetIds = const {},
    this.vehicleId,
    this.appraisalId,
    this.idempotencyKey,
    this.marketingConsent = false,
  });

  final String make;
  final String model;
  final String variant;
  final int? year;
  final String transmission;
  final String fuelType;
  final int? mileage;
  final String color;
  final String licensePlate;
  final String city;
  final String taxStatus;
  final String floodHistory;
  final String majorAccidentHistory;
  final String serviceHistory;
  final String ownership;
  final Map<String, String> photoPaths;
  final Map<String, String> assetIds;
  final String? vehicleId;
  final String? appraisalId;
  final String? idempotencyKey;
  final bool marketingConsent;

  bool get hasIdentity =>
      make.isNotEmpty && model.isNotEmpty && variant.isNotEmpty && year != null;
  bool get hasDetails =>
      transmission.isNotEmpty &&
      fuelType.isNotEmpty &&
      mileage != null &&
      color.isNotEmpty &&
      licensePlate.isNotEmpty &&
      city.isNotEmpty;
  bool get hasCondition =>
      taxStatus.isNotEmpty &&
      floodHistory.isNotEmpty &&
      majorAccidentHistory.isNotEmpty &&
      serviceHistory.isNotEmpty &&
      ownership.isNotEmpty;
  bool get hasAllPhotos => appraisalPhotoAngles.every(photoPaths.containsKey);

  AppraisalDraft copyWith({
    String? make,
    String? model,
    String? variant,
    int? year,
    String? transmission,
    String? fuelType,
    int? mileage,
    String? color,
    String? licensePlate,
    String? city,
    String? taxStatus,
    String? floodHistory,
    String? majorAccidentHistory,
    String? serviceHistory,
    String? ownership,
    Map<String, String>? photoPaths,
    Map<String, String>? assetIds,
    String? vehicleId,
    String? appraisalId,
    String? idempotencyKey,
    bool? marketingConsent,
  }) =>
      AppraisalDraft(
        make: make ?? this.make,
        model: model ?? this.model,
        variant: variant ?? this.variant,
        year: year ?? this.year,
        transmission: transmission ?? this.transmission,
        fuelType: fuelType ?? this.fuelType,
        mileage: mileage ?? this.mileage,
        color: color ?? this.color,
        licensePlate: licensePlate ?? this.licensePlate,
        city: city ?? this.city,
        taxStatus: taxStatus ?? this.taxStatus,
        floodHistory: floodHistory ?? this.floodHistory,
        majorAccidentHistory: majorAccidentHistory ?? this.majorAccidentHistory,
        serviceHistory: serviceHistory ?? this.serviceHistory,
        ownership: ownership ?? this.ownership,
        photoPaths: photoPaths ?? this.photoPaths,
        assetIds: assetIds ?? this.assetIds,
        vehicleId: vehicleId ?? this.vehicleId,
        appraisalId: appraisalId ?? this.appraisalId,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        marketingConsent: marketingConsent ?? this.marketingConsent,
      );

  factory AppraisalDraft.fromJson(Map<String, dynamic> json) => AppraisalDraft(
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        variant: json['variant']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt(),
        transmission: json['transmission']?.toString() ?? '',
        fuelType: json['fuel_type']?.toString() ?? '',
        mileage: (json['mileage'] as num?)?.toInt(),
        color: json['color']?.toString() ?? '',
        licensePlate: json['license_plate']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        taxStatus: json['tax_status']?.toString() ?? '',
        floodHistory: json['flood_history']?.toString() ?? '',
        majorAccidentHistory: json['major_accident_history']?.toString() ?? '',
        serviceHistory: json['service_history']?.toString() ?? '',
        ownership: json['ownership']?.toString() ?? '',
        photoPaths: Map<String, String>.from(
          json['photo_paths'] as Map<String, dynamic>? ?? const {},
        ),
        assetIds: Map<String, String>.from(
          json['asset_ids'] as Map<String, dynamic>? ?? const {},
        ),
        vehicleId: json['vehicle_id']?.toString(),
        appraisalId: json['appraisal_id']?.toString(),
        idempotencyKey: json['idempotency_key']?.toString(),
        marketingConsent: json['marketing_consent'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'make': make,
        'model': model,
        'variant': variant,
        'year': year,
        'transmission': transmission,
        'fuel_type': fuelType,
        'mileage': mileage,
        'color': color,
        'license_plate': licensePlate,
        'city': city,
        'tax_status': taxStatus,
        'flood_history': floodHistory,
        'major_accident_history': majorAccidentHistory,
        'service_history': serviceHistory,
        'ownership': ownership,
        'photo_paths': photoPaths,
        'asset_ids': assetIds,
        'vehicle_id': vehicleId,
        'appraisal_id': appraisalId,
        'idempotency_key': idempotencyKey,
        'marketing_consent': marketingConsent,
      };

  VehicleData toVehicle() => VehicleData(
        id: vehicleId,
        make: make,
        model: model,
        variant: variant,
        year: year!,
        transmission: transmission,
        fuelType: fuelType,
        mileage: mileage!,
        color: color,
        licensePlate: licensePlate,
        city: city,
      );

  Map<String, dynamic> get conditionJson => {
        'tax_status': taxStatus,
        'flood_history': floodHistory,
        'major_accident_history': majorAccidentHistory,
        'service_history': serviceHistory,
        'ownership': ownership,
      };
}
