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
    return data['booking_id']?.toString() ??
        data['toyota_service_booking_id']?.toString();
  }
}
