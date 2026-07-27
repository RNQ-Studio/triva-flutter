class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.data = const {},
    this.readAt,
    this.sentAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final bool isRead;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? sentAt;

  String? get toyotaServiceBookingId {
    final explicit = data['toyota_service_booking_id']?.toString();
    if (explicit != null) return explicit;
    return type == 'toyota_service_booking' ||
            data['type']?.toString() == 'toyota_service_booking'
        ? data['booking_id']?.toString()
        : null;
  }

  String? get otoxpertBookingId {
    final explicit = data['otoxpert_booking_id']?.toString();
    if (explicit != null) return explicit;
    return type == 'otoxpert_booking' ||
            data['type']?.toString() == 'otoxpert_booking'
        ? data['booking_id']?.toString()
        : null;
  }

  String? get creditSimulationId {
    final explicit = data['credit_simulation_id']?.toString();
    if (explicit != null) return explicit;
    return type == 'credit_simulation' ||
            data['type']?.toString() == 'credit_simulation'
        ? data['simulation_id']?.toString()
        : null;
  }

  String? get bodyPaintEstimateId {
    final explicit = data['body_paint_estimate_id']?.toString();
    if (explicit != null) return explicit;
    return type == 'body_paint_estimate' ||
            data['type']?.toString() == 'body_paint_estimate'
        ? data['estimate_id']?.toString()
        : null;
  }
}
