import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_repository_provider.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/entities/app_notification.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';

part 'notifications_provider.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  ref.watch(authProvider);
  return NotificationsRepositoryImpl(
    DioClient(
      ref.watch(storageServiceProvider),
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
}

final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return const [];
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return 0;
  return ref.watch(notificationsRepositoryProvider).getUnreadCount();
});

final visibleNotificationsListProvider =
    Provider<AsyncValue<List<AppNotification>>>((ref) {
  return ref.watch(notificationsListProvider).unwrapPrevious();
});

final visibleUnreadNotificationCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(unreadNotificationCountProvider).unwrapPrevious();
});
