import 'package:dio/dio.dart';

import '../models/app_notification_model.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notifications = <AppNotification>[];
    var page = 1;
    while (true) {
      final response = await _dio.get<dynamic>(
        'v1/notifications',
        queryParameters: {'page': page, 'per_page': 50},
      );
      final envelope = response.data as Map<String, dynamic>;
      final items = envelope['data'] as List<dynamic>? ?? const [];
      notifications.addAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(AppNotificationModel.fromJson),
      );
      final meta = envelope['meta'] as Map<String, dynamic>?;
      final pagination = meta?['pagination'] as Map<String, dynamic>? ?? meta;
      final currentPage =
          (pagination?['current_page'] as num?)?.toInt() ?? page;
      final lastPage =
          (pagination?['last_page'] as num?)?.toInt() ?? currentPage;
      if (currentPage != page || currentPage < 1 || lastPage < currentPage) {
        throw const FormatException(
          'Invalid pagination metadata returned by notifications API.',
        );
      }
      if (currentPage >= lastPage) break;
      page = currentPage + 1;
    }
    return List.unmodifiable(notifications);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>('v1/notifications/unread-count');
    final data = _data(response);
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dio.post<dynamic>('v1/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.post<dynamic>('v1/notifications/read-all');
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }
}
