part of 'toyota_service_models.dart';

class ToyotaServiceDraftPhoto {
  const ToyotaServiceDraftPhoto({
    required this.assetId,
    required this.name,
  });

  final String assetId;
  final String name;

  factory ToyotaServiceDraftPhoto.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceDraftPhoto(
        assetId: json['asset_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      other is ToyotaServiceDraftPhoto && other.assetId == assetId;

  @override
  int get hashCode => assetId.hashCode;
}

class ToyotaServiceDraft {
  const ToyotaServiceDraft({
    this.vehicle,
    this.serviceLocation,
    this.serviceType,
    this.fulfillmentType,
    this.currentMileage,
    this.complaint = '',
    this.photos = const [],
    this.primarySlot,
    this.alternativeSlot,
    this.contactChannel = 'whatsapp',
    this.thsAddress = '',
    this.thsCity = '',
    this.thsLatitude,
    this.thsLongitude,
    this.thsLocationNotes = '',
    this.serviceConsent = false,
    this.idempotencyKey,
  });

  final ToyotaServiceVehicle? vehicle;
  final ToyotaServiceLocation? serviceLocation;
  final ToyotaServiceType? serviceType;
  final ToyotaServiceFulfillment? fulfillmentType;
  final int? currentMileage;
  final String complaint;
  final List<ToyotaServiceDraftPhoto> photos;
  final ToyotaServiceSlot? primarySlot;
  final ToyotaServiceSlot? alternativeSlot;
  final String contactChannel;
  final String thsAddress;
  final String thsCity;
  final double? thsLatitude;
  final double? thsLongitude;
  final String thsLocationNotes;
  final bool serviceConsent;
  final String? idempotencyKey;

  bool get hasVehicle => vehicle != null;
  bool get hasFulfillment => fulfillmentType != null && serviceLocation != null;
  bool get hasService => serviceType != null;
  bool get hasDetails =>
      currentMileage != null &&
      currentMileage! >= 0 &&
      currentMileage! <= 5000000 &&
      complaint.trim().length >= 5 &&
      complaint.trim().length <= 3000;
  bool get hasSchedule =>
      primarySlot != null &&
      alternativeSlot != null &&
      primarySlot != alternativeSlot;
  bool get hasThsAddress =>
      fulfillmentType != ToyotaServiceFulfillment.ths ||
      (thsAddress.trim().length >= 10 &&
          thsCity.trim().isNotEmpty &&
          thsLatitude != null &&
          thsLongitude != null);
  bool get canSubmit =>
      hasVehicle &&
      hasFulfillment &&
      hasService &&
      hasDetails &&
      hasSchedule &&
      hasThsAddress &&
      serviceConsent;

  ToyotaServiceDraft copyWith({
    ToyotaServiceVehicle? vehicle,
    ToyotaServiceLocation? serviceLocation,
    ToyotaServiceType? serviceType,
    ToyotaServiceFulfillment? fulfillmentType,
    int? currentMileage,
    String? complaint,
    List<ToyotaServiceDraftPhoto>? photos,
    ToyotaServiceSlot? primarySlot,
    ToyotaServiceSlot? alternativeSlot,
    String? contactChannel,
    String? thsAddress,
    String? thsCity,
    double? thsLatitude,
    double? thsLongitude,
    String? thsLocationNotes,
    bool? serviceConsent,
    String? idempotencyKey,
    bool clearLocation = false,
    bool clearService = false,
    bool clearSchedule = false,
    bool clearIdempotencyKey = false,
  }) =>
      ToyotaServiceDraft(
        vehicle: vehicle ?? this.vehicle,
        serviceLocation:
            clearLocation ? null : serviceLocation ?? this.serviceLocation,
        serviceType: clearService ? null : serviceType ?? this.serviceType,
        fulfillmentType: fulfillmentType ?? this.fulfillmentType,
        currentMileage: currentMileage ?? this.currentMileage,
        complaint: complaint ?? this.complaint,
        photos: photos ?? this.photos,
        primarySlot: clearSchedule ? null : primarySlot ?? this.primarySlot,
        alternativeSlot:
            clearSchedule ? null : alternativeSlot ?? this.alternativeSlot,
        contactChannel: contactChannel ?? this.contactChannel,
        thsAddress: thsAddress ?? this.thsAddress,
        thsCity: thsCity ?? this.thsCity,
        thsLatitude: thsLatitude ?? this.thsLatitude,
        thsLongitude: thsLongitude ?? this.thsLongitude,
        thsLocationNotes: thsLocationNotes ?? this.thsLocationNotes,
        serviceConsent: serviceConsent ?? this.serviceConsent,
        idempotencyKey:
            clearIdempotencyKey ? null : idempotencyKey ?? this.idempotencyKey,
      );

  factory ToyotaServiceDraft.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceDraft(
        vehicle: json['vehicle'] is Map<String, dynamic>
            ? ToyotaServiceVehicle.fromJson(
                json['vehicle'] as Map<String, dynamic>,
              )
            : null,
        serviceLocation: json['service_location'] is Map<String, dynamic>
            ? ToyotaServiceLocation.fromJson(
                json['service_location'] as Map<String, dynamic>,
              )
            : null,
        serviceType: json['service_type'] is Map<String, dynamic>
            ? ToyotaServiceType.fromJson(
                json['service_type'] as Map<String, dynamic>,
              )
            : null,
        fulfillmentType: ToyotaServiceFulfillment.fromValue(
          json['fulfillment_type']?.toString(),
        ),
        currentMileage: (json['current_mileage'] as num?)?.toInt(),
        complaint: json['complaint']?.toString() ?? '',
        photos: json['photos'] is List
            ? (json['photos'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(ToyotaServiceDraftPhoto.fromJson)
                .where((item) => item.assetId.isNotEmpty)
                .toList(growable: false)
            : json['photo_asset_id'] != null
                ? [
                    ToyotaServiceDraftPhoto(
                      assetId: json['photo_asset_id'].toString(),
                      name: json['photo_name']?.toString() ??
                          'supporting-photo.jpg',
                    ),
                  ]
                : const [],
        primarySlot: ToyotaServiceBooking._slot(json['primary_slot']),
        alternativeSlot: ToyotaServiceBooking._slot(json['alternative_slot']),
        contactChannel: json['contact_channel']?.toString() ?? 'whatsapp',
        thsAddress: json['ths_address']?.toString() ?? '',
        thsCity: json['ths_city']?.toString() ?? '',
        thsLatitude: (json['ths_latitude'] as num?)?.toDouble(),
        thsLongitude: (json['ths_longitude'] as num?)?.toDouble(),
        thsLocationNotes: json['ths_location_notes']?.toString() ?? '',
        serviceConsent: json['service_consent'] as bool? ?? false,
        idempotencyKey: json['idempotency_key']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
        if (serviceLocation != null)
          'service_location': {
            'id': serviceLocation!.id,
            'name': serviceLocation!.name,
            'address': serviceLocation!.address,
            'city': serviceLocation!.city,
            'latitude': serviceLocation!.latitude,
            'longitude': serviceLocation!.longitude,
            'is_active': serviceLocation!.isActive,
          },
        if (serviceType != null)
          'service_type': {
            'id': serviceType!.id,
            'code': serviceType!.code,
            'name': serviceType!.name,
            'description': serviceType!.description,
            'allowed_fulfillment_types': serviceType!.allowedFulfillments
                .map((item) => item.value)
                .toList(growable: false),
            'workshop_lead_time_days': serviceType!.workshopLeadDays,
            'ths_lead_time_days': serviceType!.thsLeadDays,
            'is_active': serviceType!.isActive,
          },
        'fulfillment_type': fulfillmentType?.value,
        'current_mileage': currentMileage,
        'complaint': complaint,
        'photos': photos.map((item) => item.toJson()).toList(growable: false),
        'primary_slot': primarySlot?.toJson(),
        'alternative_slot': alternativeSlot?.toJson(),
        'contact_channel': contactChannel,
        'ths_address': thsAddress,
        'ths_city': thsCity,
        'ths_latitude': thsLatitude,
        'ths_longitude': thsLongitude,
        'ths_location_notes': thsLocationNotes,
        'service_consent': serviceConsent,
        'idempotency_key': idempotencyKey,
      };
}
