part of 'toyota_service_models.dart';

class ToyotaServiceTimelineItem {
  const ToyotaServiceTimelineItem({
    required this.status,
    required this.title,
    this.description,
    this.occurredAt,
    this.event,
    this.reasonCode,
    this.actorType,
    this.actorId,
    this.actorName,
    this.internalNote,
    this.metadata = const {},
  });

  final String status;
  final String title;
  final String? description;
  final DateTime? occurredAt;
  final String? event;
  final String? reasonCode;
  final String? actorType;
  final String? actorId;
  final String? actorName;
  final String? internalNote;
  final Map<String, dynamic> metadata;

  factory ToyotaServiceTimelineItem.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>? ?? const {};
    return ToyotaServiceTimelineItem(
      status: json['status']?.toString() ?? '',
      title:
          json['title']?.toString() ?? json['status_label']?.toString() ?? '',
      description:
          json['description']?.toString() ?? json['customer_note']?.toString(),
      occurredAt: DateTime.tryParse(
        json['occurred_at']?.toString() ?? json['created_at']?.toString() ?? '',
      ),
      event: json['event']?.toString(),
      reasonCode: json['reason_code']?.toString(),
      actorType: json['actor_type']?.toString(),
      actorId: actor['id']?.toString(),
      actorName: actor['name']?.toString(),
      internalNote: json['note']?.toString(),
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ToyotaServiceBooking {
  const ToyotaServiceBooking({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.fulfillmentType,
    required this.currentMileage,
    required this.complaint,
    required this.contactChannel,
    required this.allowedCustomerActions,
    required this.timeline,
    required this.isConfirmed,
    this.vehicle,
    this.serviceLocation,
    this.serviceType,
    this.primarySlot,
    this.alternativeSlot,
    this.proposedSlot,
    this.confirmedSlot,
    this.proposalReason,
    this.proposalExpiresAt,
    this.proposedPicName,
    this.proposedArrivalInstructions,
    this.proposedExternalBookingNumber,
    this.rejectionReason,
    this.cancellationReason,
    this.rescheduleReason,
    this.reschedulePrimarySlot,
    this.rescheduleAlternativeSlot,
    this.proposalContext,
    this.thsAddress,
    this.thsCity,
    this.thsLatitude,
    this.thsLongitude,
    this.thsLocationNotes,
    this.assignedAdvisorName,
    this.assignedAdvisorPhone,
    this.serviceAdvisorName,
    this.serviceAdvisorPhone,
    this.externalBookingNumber,
    this.arrivalInstructions,
    this.picName,
    this.customerName,
    this.customerPhone,
    this.submittedAt,
    this.dueAt,
    this.updatedAt,
    this.completedAt,
    this.reason,
    this.reasonCode,
    this.availableAdminActions = const [],
    this.slaOverdue = false,
    this.benefitChecks = const [],
    this.photos = const [],
    this.statusUpdateUrl,
  });

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;

  /// Tautan web publik (tanpa login) bagi PIC cabang untuk memperbarui
  /// status booking; disertakan di pesan WhatsApp booking.
  final String? statusUpdateUrl;
  final ToyotaServiceFulfillment fulfillmentType;
  final ToyotaServiceVehicle? vehicle;
  final ToyotaServiceLocation? serviceLocation;
  final ToyotaServiceType? serviceType;
  final int currentMileage;
  final String complaint;
  final ToyotaServiceSlot? primarySlot;
  final ToyotaServiceSlot? alternativeSlot;
  final ToyotaServiceSlot? proposedSlot;
  final ToyotaServiceSlot? confirmedSlot;
  final String? proposalReason;
  final DateTime? proposalExpiresAt;
  final String? proposedPicName;
  final String? proposedArrivalInstructions;
  final String? proposedExternalBookingNumber;
  final String? rejectionReason;
  final String? cancellationReason;
  final String? rescheduleReason;
  final ToyotaServiceSlot? reschedulePrimarySlot;
  final ToyotaServiceSlot? rescheduleAlternativeSlot;
  final String? proposalContext;
  final String? thsAddress;
  final String? thsCity;
  final double? thsLatitude;
  final double? thsLongitude;
  final String? thsLocationNotes;
  final String contactChannel;
  final List<String> allowedCustomerActions;
  final List<ToyotaServiceTimelineItem> timeline;
  final bool isConfirmed;
  final String? assignedAdvisorName;
  final String? assignedAdvisorPhone;
  final String? serviceAdvisorName;
  final String? serviceAdvisorPhone;
  final String? externalBookingNumber;
  final String? arrivalInstructions;
  final String? picName;
  final String? customerName;
  final String? customerPhone;
  final DateTime? submittedAt;
  final DateTime? dueAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? reason;
  final String? reasonCode;
  final List<ToyotaServiceAdminAction> availableAdminActions;
  final bool slaOverdue;
  final List<ToyotaServiceBenefitCheck> benefitChecks;
  final List<ToyotaServicePhoto> photos;

  bool get canAcceptAlternative =>
      allowedCustomerActions.contains('accept_alternative');
  bool get canRejectAlternative =>
      allowedCustomerActions.contains('reject_alternative');
  bool get canReschedule =>
      allowedCustomerActions.contains('reschedule') ||
      allowedCustomerActions.contains('request_reschedule');
  bool get canCancel => allowedCustomerActions.contains('cancel');
  bool get isTerminal => const {
        'completed',
        'rejected',
        'cancelled',
        'expired',
        'no_show',
      }.contains(status);

  factory ToyotaServiceBooking.fromJson(Map<String, dynamic> json) {
    final requested =
        json['requested_slots'] as Map<String, dynamic>? ?? const {};
    final proposed = json['proposed_slot'];
    final confirmed = json['confirmed_slot'];
    final reschedule =
        json['reschedule_request'] as Map<String, dynamic>? ?? const {};
    final advisor = json['assigned_advisor'] as Map<String, dynamic>? ??
        json['assigned_service_advisor'] as Map<String, dynamic>? ??
        const {};
    final serviceAdvisor =
        json['service_advisor'] as Map<String, dynamic>? ?? const {};
    final ths = json['ths_location'] as Map<String, dynamic>? ?? const {};
    final customer = json['customer'] as Map<String, dynamic>? ?? const {};
    return ToyotaServiceBooking(
      id: json['id']?.toString() ?? '',
      referenceNo: json['reference_no']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      fulfillmentType: ToyotaServiceFulfillment.fromValue(
            json['fulfillment_type']?.toString(),
          ) ??
          ToyotaServiceFulfillment.workshop,
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
      currentMileage: (json['current_mileage'] as num?)?.toInt() ?? 0,
      complaint: json['complaint']?.toString() ?? '',
      primarySlot: _slot(requested['primary']),
      alternativeSlot: _slot(requested['alternative']),
      proposedSlot: _slot(proposed),
      confirmedSlot: _slot(confirmed),
      proposalReason: json['proposal_reason']?.toString() ??
          (proposed is Map<String, dynamic>
              ? proposed['reason']?.toString()
              : null),
      proposalExpiresAt: DateTime.tryParse(
        json['proposal_expires_at']?.toString() ??
            (proposed is Map<String, dynamic>
                ? proposed['expires_at']?.toString() ?? ''
                : ''),
      ),
      proposedPicName: proposed is Map<String, dynamic>
          ? proposed['pic_name']?.toString()
          : null,
      proposedArrivalInstructions: proposed is Map<String, dynamic>
          ? proposed['arrival_instructions']?.toString()
          : null,
      proposedExternalBookingNumber: proposed is Map<String, dynamic>
          ? proposed['external_booking_number']?.toString()
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      rescheduleReason: reschedule['reason']?.toString(),
      reschedulePrimarySlot: _slot(reschedule['primary']),
      rescheduleAlternativeSlot: _slot(reschedule['alternative']),
      proposalContext: json['proposal_context']?.toString() ??
          (proposed is Map<String, dynamic>
              ? proposed['context']?.toString()
              : null),
      thsAddress: ths['address']?.toString() ?? json['ths_address']?.toString(),
      thsCity: ths['city']?.toString() ?? json['ths_city']?.toString(),
      thsLatitude: (ths['latitude'] as num?)?.toDouble() ??
          (json['ths_latitude'] as num?)?.toDouble(),
      thsLongitude: (ths['longitude'] as num?)?.toDouble() ??
          (json['ths_longitude'] as num?)?.toDouble(),
      thsLocationNotes:
          ths['notes']?.toString() ?? json['ths_location_notes']?.toString(),
      contactChannel: json['contact_channel']?.toString() ?? '',
      allowedCustomerActions:
          (json['allowed_customer_actions'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      timeline: (json['timeline'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServiceTimelineItem.fromJson)
          .toList(growable: false),
      isConfirmed: json['is_confirmed'] as bool? ??
          json['status']?.toString() == 'confirmed',
      assignedAdvisorName:
          advisor['name']?.toString() ?? json['advisor_name']?.toString(),
      assignedAdvisorPhone:
          advisor['phone']?.toString() ?? json['advisor_phone']?.toString(),
      serviceAdvisorName: serviceAdvisor['name']?.toString(),
      serviceAdvisorPhone: serviceAdvisor['phone']?.toString(),
      externalBookingNumber: json['external_booking_number']?.toString() ??
          json['partner_booking_number']?.toString(),
      arrivalInstructions: json['arrival_instructions']?.toString(),
      picName:
          serviceAdvisor['name']?.toString() ?? json['pic_name']?.toString(),
      customerName: customer['name']?.toString(),
      customerPhone: customer['phone']?.toString(),
      submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? ''),
      dueAt: DateTime.tryParse(json['due_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      reason: json['reason']?.toString(),
      reasonCode: json['reason_code']?.toString(),
      availableAdminActions:
          (json['available_admin_actions'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(ToyotaServiceAdminAction.fromJson)
              .toList(growable: false),
      slaOverdue: json['sla'] is Map<String, dynamic>
          ? ((json['sla'] as Map<String, dynamic>)['is_overdue'] as bool? ??
              false)
          : false,
      benefitChecks: (json['benefit_checks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServiceBenefitCheck.fromJson)
          .toList(growable: false),
      photos: (json['photos'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServicePhoto.fromJson)
          .toList(growable: false),
      statusUpdateUrl: json['status_update_url']?.toString(),
    );
  }

  static ToyotaServiceSlot? _slot(dynamic value) {
    return value is Map<String, dynamic>
        ? ToyotaServiceSlot.fromJson(value)
        : null;
  }
}

List<ToyotaServiceSlot> validAdminConfirmationSlots(
  ToyotaServiceBooking booking,
  String action, {
  DateTime? now,
}) {
  final candidates = switch (action) {
    'confirm' => [booking.primarySlot, booking.alternativeSlot],
    'confirm_reschedule' => [
        booking.reschedulePrimarySlot,
        booking.rescheduleAlternativeSlot,
      ],
    _ => const <ToyotaServiceSlot?>[],
  };
  final reference = now ?? DateTime.now();
  return candidates
      .whereType<ToyotaServiceSlot>()
      .where((slot) => _slotHasNotStarted(slot, reference))
      .toSet()
      .toList(growable: false);
}

bool _slotHasNotStarted(ToyotaServiceSlot slot, DateTime now) {
  final date = DateTime.tryParse(slot.date);
  final start = slot.timeWindow.split('-').first.trim().split(':');
  if (date == null || start.length < 2) return false;
  final hour = int.tryParse(start[0]);
  final minute = int.tryParse(start[1]);
  if (hour == null || minute == null) return false;
  return DateTime(date.year, date.month, date.day, hour, minute).isAfter(now);
}

DateTime? toyotaServiceSlotStart(ToyotaServiceSlot? slot) {
  if (slot == null) return null;
  final date = DateTime.tryParse(slot.date);
  final start = slot.timeWindow.split('-').first.trim().split(':');
  if (date == null || start.length < 2) return null;
  final hour = int.tryParse(start[0]);
  final minute = int.tryParse(start[1]);
  if (hour == null || minute == null) return null;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

DateTime? defaultProposalExpiry(
  ToyotaServiceSlot proposedSlot, {
  ToyotaServiceSlot? existingConfirmedSlot,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final proposedStart = toyotaServiceSlotStart(proposedSlot);
  if (proposedStart == null) return null;
  final confirmedStart = toyotaServiceSlotStart(existingConfirmedSlot);
  final limitingStart =
      confirmedStart != null && confirmedStart.isBefore(proposedStart)
          ? confirmedStart
          : proposedStart;
  final latest = limitingStart.subtract(const Duration(hours: 1));
  final defaultValue = reference.add(const Duration(hours: 24));
  final result = defaultValue.isBefore(latest) ? defaultValue : latest;
  return result.isAfter(reference) ? result : null;
}

bool isValidProposalExpiry(
  DateTime expiry,
  ToyotaServiceSlot proposedSlot, {
  ToyotaServiceSlot? existingConfirmedSlot,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final proposedStart = toyotaServiceSlotStart(proposedSlot);
  final confirmedStart = toyotaServiceSlotStart(existingConfirmedSlot);
  if (!expiry.isAfter(reference) ||
      proposedStart == null ||
      !expiry.isBefore(proposedStart)) {
    return false;
  }
  return confirmedStart == null || expiry.isBefore(confirmedStart);
}

class ToyotaServiceBenefitCheck {
  const ToyotaServiceBenefitCheck({
    required this.type,
    required this.status,
    this.source,
    this.validUntil,
    this.notes,
  });

  final String type;
  final String status;
  final String? source;
  final DateTime? validUntil;
  final String? notes;

  factory ToyotaServiceBenefitCheck.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceBenefitCheck(
        type:
            json['benefit_type']?.toString() ?? json['type']?.toString() ?? '',
        status: json['benefit_status']?.toString() ??
            json['status']?.toString() ??
            'pending_verification',
        source: json['verification_source']?.toString() ??
            json['source']?.toString(),
        validUntil: DateTime.tryParse(
          json['benefit_valid_until']?.toString() ??
              json['valid_until']?.toString() ??
              '',
        ),
        notes: json['benefit_notes']?.toString() ?? json['notes']?.toString(),
      );
}

class ToyotaServicePhoto {
  const ToyotaServicePhoto({
    required this.id,
    required this.url,
    this.name,
  });

  final String id;
  final String url;
  final String? name;

  factory ToyotaServicePhoto.fromJson(Map<String, dynamic> json) =>
      ToyotaServicePhoto(
        id: json['id']?.toString() ?? '',
        url: (json['asset'] is Map<String, dynamic>
                ? (json['asset'] as Map<String, dynamic>)['temporary_url']
                    ?.toString()
                : null) ??
            json['temporary_url']?.toString() ??
            json['url']?.toString() ??
            '',
        name: (json['asset'] is Map<String, dynamic>
                ? (json['asset'] as Map<String, dynamic>)['original_filename']
                    ?.toString()
                : null) ??
            json['name']?.toString() ??
            json['original_name']?.toString(),
      );
}

class ToyotaServiceAdminAction {
  const ToyotaServiceAdminAction({
    required this.action,
    required this.label,
  });

  final String action;
  final String label;

  factory ToyotaServiceAdminAction.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceAdminAction(
        action: json['action']?.toString() ?? '',
        label: json['label']?.toString() ?? json['action']?.toString() ?? '',
      );
}

class ToyotaServiceAdvisorOption {
  const ToyotaServiceAdvisorOption({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;

  factory ToyotaServiceAdvisorOption.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceAdvisorOption(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
      );
}

class ToyotaServiceAdminOptions {
  const ToyotaServiceAdminOptions({
    required this.advisors,
    this.statuses = const [],
    this.actions = const [],
    this.fulfillmentTypes = const [],
    this.locations = const [],
    this.serviceTypes = const [],
    this.benefitTypes = const [],
    this.benefitStatuses = const [],
    this.verificationSources = const [],
    this.reasonCodes = const [],
  });

  final List<ToyotaServiceAdvisorOption> advisors;
  final List<ToyotaServiceValueLabel> statuses;
  final List<ToyotaServiceValueLabel> actions;
  final List<ToyotaServiceValueLabel> fulfillmentTypes;
  final List<ToyotaServiceLocation> locations;
  final List<ToyotaServiceType> serviceTypes;
  final List<ToyotaServiceValueLabel> benefitTypes;
  final List<ToyotaServiceValueLabel> benefitStatuses;
  final List<ToyotaServiceValueLabel> verificationSources;
  final List<ToyotaServiceValueLabel> reasonCodes;

  factory ToyotaServiceAdminOptions.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceAdminOptions(
        advisors: (json['advisors'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceAdvisorOption.fromJson)
            .toList(growable: false),
        statuses: _valueLabels(json['statuses']),
        actions: _valueLabels(json['actions']),
        fulfillmentTypes: _valueLabels(json['fulfillment_types']),
        locations: (json['service_locations'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceLocation.fromJson)
            .toList(growable: false),
        serviceTypes: (json['service_types'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ToyotaServiceType.fromJson)
            .toList(growable: false),
        benefitTypes: _valueLabels(json['benefit_types']),
        benefitStatuses: _valueLabels(json['benefit_statuses']),
        verificationSources: _valueLabels(json['verification_sources']),
        reasonCodes: _valueLabels(json['reason_codes']),
      );

  static List<ToyotaServiceValueLabel> _valueLabels(dynamic value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ToyotaServiceValueLabel.fromJson)
          .toList(growable: false);
}

class ToyotaServiceValueLabel {
  const ToyotaServiceValueLabel({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  factory ToyotaServiceValueLabel.fromJson(Map<String, dynamic> json) =>
      ToyotaServiceValueLabel(
        value: json['value']?.toString() ?? '',
        label: json['label']?.toString() ?? json['value']?.toString() ?? '',
      );
}
