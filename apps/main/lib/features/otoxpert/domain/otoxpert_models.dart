import '../../toyota_service/domain/toyota_service_models.dart';

class OtoxpertOption {
  const OtoxpertOption({required this.value, required this.label});

  final String value;
  final String label;

  factory OtoxpertOption.fromJson(Map<String, dynamic> json) => OtoxpertOption(
        value: (json['value'] ?? json['action'])?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );
}

class OtoxpertOptions {
  const OtoxpertOptions({
    required this.notice,
    required this.partnerConsentVersion,
    required this.symptoms,
    required this.contactChannels,
    required this.maxPhotos,
  });

  final String notice;
  final String partnerConsentVersion;
  final List<OtoxpertOption> symptoms;
  final List<OtoxpertOption> contactChannels;
  final int maxPhotos;

  factory OtoxpertOptions.fromJson(Map<String, dynamic> json) {
    List<OtoxpertOption> options(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(OtoxpertOption.fromJson)
            .toList(growable: false);
    final upload = json['photo_upload'] as Map<String, dynamic>? ?? const {};
    return OtoxpertOptions(
      notice: json['notice']?.toString() ?? '',
      partnerConsentVersion: json['partner_consent_version']?.toString() ?? '',
      symptoms: options('symptom_options'),
      contactChannels: options('contact_channels'),
      maxPhotos: (upload['max_files'] as num?)?.toInt() ?? 5,
    );
  }
}

class OtoxpertPrice {
  const OtoxpertPrice({
    required this.type,
    required this.minimumAmount,
    required this.currency,
    required this.disclaimer,
    this.maximumAmount,
    this.validUntil,
  });

  final String type;
  final int minimumAmount;
  final int? maximumAmount;
  final String currency;
  final String disclaimer;
  final String? validUntil;

  factory OtoxpertPrice.fromJson(Map<String, dynamic> json) => OtoxpertPrice(
        type: json['type']?.toString() ?? 'from',
        minimumAmount: (json['minimum_amount'] as num?)?.toInt() ?? 0,
        maximumAmount: (json['maximum_amount'] as num?)?.toInt(),
        currency: json['currency']?.toString() ?? 'IDR',
        disclaimer: json['disclaimer']?.toString() ?? '',
        validUntil: (json['valid_until'] ?? json['effective_to'])?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'minimum_amount': minimumAmount,
        'maximum_amount': maximumAmount,
        'currency': currency,
        'disclaimer': disclaimer,
        'valid_until': validUntil,
      };
}

class OtoxpertService {
  const OtoxpertService({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.leadTimeDays,
    this.indicativePrice,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int leadTimeDays;
  final OtoxpertPrice? indicativePrice;

  factory OtoxpertService.fromJson(Map<String, dynamic> json) =>
      OtoxpertService(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        leadTimeDays: (json['lead_time_days'] as num?)?.toInt() ?? 1,
        indicativePrice: json['indicative_price'] is Map<String, dynamic>
            ? OtoxpertPrice.fromJson(
                json['indicative_price'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'lead_time_days': leadTimeDays,
        if (indicativePrice != null)
          'indicative_price': indicativePrice!.toJson(),
      };
}

class OtoxpertWorkshop {
  const OtoxpertWorkshop({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.timezone,
    required this.supportsPickupDelivery,
    required this.confirmationSlaMinutes,
    this.phone,
    this.services = const [],
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String timezone;
  final String? phone;
  final bool supportsPickupDelivery;
  final int confirmationSlaMinutes;
  final List<OtoxpertService> services;

  factory OtoxpertWorkshop.fromJson(Map<String, dynamic> json) =>
      OtoxpertWorkshop(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        timezone: json['timezone']?.toString() ?? 'Asia/Jakarta',
        phone: json['phone']?.toString(),
        supportsPickupDelivery:
            json['supports_pickup_delivery'] as bool? ?? false,
        confirmationSlaMinutes:
            (json['confirmation_sla_minutes'] as num?)?.toInt() ?? 30,
        services: (json['services'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(OtoxpertService.fromJson)
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'timezone': timezone,
        'phone': phone,
        'supports_pickup_delivery': supportsPickupDelivery,
        'confirmation_sla_minutes': confirmationSlaMinutes,
        'services': services.map((item) => item.toJson()).toList(),
      };
}

class OtoxpertDraft {
  const OtoxpertDraft({
    this.vehicle,
    this.workshop,
    this.service,
    this.currentMileage,
    this.lastServiceDate,
    this.complaint = '',
    this.symptomCodes = const [],
    this.photos = const [],
    this.primarySlot,
    this.alternativeSlot,
    this.pickupDeliveryRequested = false,
    this.contactChannel = 'whatsapp',
    this.partnerConsent = false,
    this.idempotencyKey,
  });

  final ToyotaServiceVehicle? vehicle;
  final OtoxpertWorkshop? workshop;
  final OtoxpertService? service;
  final int? currentMileage;
  final String? lastServiceDate;
  final String complaint;
  final List<String> symptomCodes;
  final List<ToyotaServiceDraftPhoto> photos;
  final ToyotaServiceSlot? primarySlot;
  final ToyotaServiceSlot? alternativeSlot;
  final bool pickupDeliveryRequested;
  final String contactChannel;
  final bool partnerConsent;
  final String? idempotencyKey;

  bool get canSubmit =>
      vehicle != null &&
      workshop != null &&
      service != null &&
      currentMileage != null &&
      complaint.trim().length >= 5 &&
      symptomCodes.isNotEmpty &&
      primarySlot != null &&
      alternativeSlot != null &&
      primarySlot != alternativeSlot &&
      partnerConsent;

  OtoxpertDraft copyWith({
    ToyotaServiceVehicle? vehicle,
    OtoxpertWorkshop? workshop,
    OtoxpertService? service,
    int? currentMileage,
    String? lastServiceDate,
    String? complaint,
    List<String>? symptomCodes,
    List<ToyotaServiceDraftPhoto>? photos,
    ToyotaServiceSlot? primarySlot,
    ToyotaServiceSlot? alternativeSlot,
    bool? pickupDeliveryRequested,
    String? contactChannel,
    bool? partnerConsent,
    String? idempotencyKey,
    bool clearWorkshop = false,
    bool clearService = false,
    bool clearSchedule = false,
    bool clearIdempotencyKey = false,
  }) =>
      OtoxpertDraft(
        vehicle: vehicle ?? this.vehicle,
        workshop: clearWorkshop ? null : workshop ?? this.workshop,
        service: clearService ? null : service ?? this.service,
        currentMileage: currentMileage ?? this.currentMileage,
        lastServiceDate: lastServiceDate ?? this.lastServiceDate,
        complaint: complaint ?? this.complaint,
        symptomCodes: symptomCodes ?? this.symptomCodes,
        photos: photos ?? this.photos,
        primarySlot: clearSchedule ? null : primarySlot ?? this.primarySlot,
        alternativeSlot:
            clearSchedule ? null : alternativeSlot ?? this.alternativeSlot,
        pickupDeliveryRequested:
            pickupDeliveryRequested ?? this.pickupDeliveryRequested,
        contactChannel: contactChannel ?? this.contactChannel,
        partnerConsent: partnerConsent ?? this.partnerConsent,
        idempotencyKey:
            clearIdempotencyKey ? null : idempotencyKey ?? this.idempotencyKey,
      );

  factory OtoxpertDraft.fromJson(Map<String, dynamic> json) => OtoxpertDraft(
        vehicle: json['vehicle'] is Map<String, dynamic>
            ? ToyotaServiceVehicle.fromJson(
                json['vehicle'] as Map<String, dynamic>,
              )
            : null,
        workshop: json['workshop'] is Map<String, dynamic>
            ? OtoxpertWorkshop.fromJson(
                json['workshop'] as Map<String, dynamic>,
              )
            : null,
        service: json['service'] is Map<String, dynamic>
            ? OtoxpertService.fromJson(
                json['service'] as Map<String, dynamic>,
              )
            : null,
        currentMileage: (json['current_mileage'] as num?)?.toInt(),
        lastServiceDate: json['last_service_date']?.toString(),
        complaint: json['complaint']?.toString() ?? '',
        symptomCodes: (json['symptom_codes'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        photos: (json['photos'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceDraftPhoto.fromJson)
            .toList(growable: false),
        primarySlot: _slot(json['primary_slot']),
        alternativeSlot: _slot(json['alternative_slot']),
        pickupDeliveryRequested:
            json['pickup_delivery_requested'] as bool? ?? false,
        contactChannel: json['contact_channel']?.toString() ?? 'whatsapp',
        partnerConsent: json['partner_consent'] as bool? ?? false,
        idempotencyKey: json['idempotency_key']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (vehicle != null) 'vehicle': vehicle!.toJson(),
        if (workshop != null) 'workshop': workshop!.toJson(),
        if (service != null) 'service': service!.toJson(),
        'current_mileage': currentMileage,
        'last_service_date': lastServiceDate,
        'complaint': complaint,
        'symptom_codes': symptomCodes,
        'photos': photos.map((item) => item.toJson()).toList(),
        'primary_slot': primarySlot?.toJson(),
        'alternative_slot': alternativeSlot?.toJson(),
        'pickup_delivery_requested': pickupDeliveryRequested,
        'contact_channel': contactChannel,
        'partner_consent': partnerConsent,
        'idempotency_key': idempotencyKey,
      };
}

class OtoxpertBooking {
  const OtoxpertBooking({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.currentMileage,
    required this.complaint,
    required this.symptomCodes,
    required this.allowedCustomerActions,
    required this.timeline,
    required this.isConfirmed,
    required this.submittedAt,
    this.vehicle,
    this.workshop,
    this.service,
    this.primarySlot,
    this.alternativeSlot,
    this.proposedSlot,
    this.confirmedSlot,
    this.reschedulePrimarySlot,
    this.rescheduleAlternativeSlot,
    this.proposalReason,
    this.proposalExpiresAt,
    this.price,
    this.operatorName,
    this.operatorPhone,
    this.arrivalInstructions,
    this.externalBookingNumber,
    this.reason,
    this.reasonCode,
    this.updatedAt,
    this.availableAdminActions = const [],
    this.slaOverdue = false,
    this.customerName,
    this.customerPhone,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final ToyotaServiceVehicle? vehicle;
  final OtoxpertWorkshop? workshop;
  final OtoxpertService? service;
  final int currentMileage;
  final String complaint;
  final List<String> symptomCodes;
  final ToyotaServiceSlot? primarySlot;
  final ToyotaServiceSlot? alternativeSlot;
  final ToyotaServiceSlot? proposedSlot;
  final ToyotaServiceSlot? confirmedSlot;
  final ToyotaServiceSlot? reschedulePrimarySlot;
  final ToyotaServiceSlot? rescheduleAlternativeSlot;
  final String? proposalReason;
  final DateTime? proposalExpiresAt;
  final OtoxpertPrice? price;
  final List<String> allowedCustomerActions;
  final List<ToyotaServiceTimelineItem> timeline;
  final bool isConfirmed;
  final String? operatorName;
  final String? operatorPhone;
  final String? arrivalInstructions;
  final String? externalBookingNumber;
  final String? reason;
  final String? reasonCode;
  final DateTime submittedAt;
  final DateTime? updatedAt;
  final List<OtoxpertOption> availableAdminActions;
  final bool slaOverdue;
  final String? customerName;
  final String? customerPhone;

  bool get canAcceptAlternative =>
      allowedCustomerActions.contains('accept_alternative');
  bool get canRejectAlternative =>
      allowedCustomerActions.contains('reject_alternative');
  bool get canReschedule =>
      allowedCustomerActions.contains('request_reschedule') ||
      allowedCustomerActions.contains('reschedule');
  bool get canCancel => allowedCustomerActions.contains('cancel');

  factory OtoxpertBooking.fromJson(Map<String, dynamic> json) {
    final requested =
        json['requested_slots'] as Map<String, dynamic>? ?? const {};
    final proposed = json['proposed_slot'] as Map<String, dynamic>? ?? const {};
    final reschedule =
        json['reschedule_request'] as Map<String, dynamic>? ?? const {};
    final operator = json['operator'] as Map<String, dynamic>? ?? const {};
    final customer = json['customer'] as Map<String, dynamic>? ?? const {};
    final sla = json['sla'] as Map<String, dynamic>? ?? const {};
    return OtoxpertBooking(
      id: json['id']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? ToyotaServiceVehicle.fromJson(
              json['vehicle'] as Map<String, dynamic>,
            )
          : null,
      workshop: json['workshop'] is Map<String, dynamic>
          ? OtoxpertWorkshop.fromJson(
              json['workshop'] as Map<String, dynamic>,
            )
          : null,
      service: json['service'] is Map<String, dynamic>
          ? OtoxpertService.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      currentMileage: (json['current_mileage'] as num?)?.toInt() ?? 0,
      complaint: json['complaint']?.toString() ?? '',
      symptomCodes: (json['symptom_codes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      primarySlot: _slot(requested['primary']),
      alternativeSlot: _slot(requested['alternative']),
      proposedSlot: _slot(json['proposed_slot']),
      confirmedSlot: _slot(json['confirmed_slot']),
      reschedulePrimarySlot: _slot(reschedule['primary']),
      rescheduleAlternativeSlot: _slot(reschedule['alternative']),
      proposalReason: proposed['reason']?.toString(),
      proposalExpiresAt:
          DateTime.tryParse(proposed['expires_at']?.toString() ?? ''),
      price: json['price'] is Map<String, dynamic>
          ? OtoxpertPrice.fromJson(json['price'] as Map<String, dynamic>)
          : null,
      allowedCustomerActions:
          (json['allowed_customer_actions'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      timeline: (json['timeline'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServiceTimelineItem.fromJson)
          .toList(growable: false),
      isConfirmed: json['is_confirmed'] as bool? ?? false,
      operatorName: operator['name']?.toString(),
      operatorPhone: operator['phone']?.toString(),
      arrivalInstructions: json['arrival_instructions']?.toString(),
      externalBookingNumber: json['external_booking_number']?.toString(),
      reason: json['reason']?.toString(),
      reasonCode: json['reason_code']?.toString(),
      submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      availableAdminActions:
          (json['available_admin_actions'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(OtoxpertOption.fromJson)
              .toList(growable: false),
      slaOverdue: sla['is_overdue'] as bool? ?? false,
      customerName: customer['name']?.toString(),
      customerPhone: customer['phone']?.toString(),
    );
  }
}

ToyotaServiceSlot? _slot(dynamic value) =>
    value is Map<String, dynamic> ? ToyotaServiceSlot.fromJson(value) : null;
