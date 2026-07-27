import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.type,
    super.isRead,
    super.data,
    super.readAt,
    super.sentAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      data: Map<String, dynamic>.from(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
      sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? ''),
      createdAt:
          createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
