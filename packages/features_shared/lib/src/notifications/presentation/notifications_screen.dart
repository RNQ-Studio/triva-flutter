import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/app_notification.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(visibleNotificationsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: notifications.value?.any((item) => !item.isRead) == true
                ? () => _markAllAsRead(context, ref)
                : null,
            child: Text(l10n.notificationsMarkAllRead),
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.when(
          data: (items) => RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(notificationsListProvider.future),
            child: items.isEmpty
                ? ListView(
                    children: [
                      _NotificationEmpty(
                        title: l10n.notificationsEmptyTitle,
                        description: l10n.notificationsEmptyDescription,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) => _NotificationTile(
                      notification: items[index],
                      onTap: () => _open(context, ref, items[index]),
                    ),
                  ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _NotificationEmpty(
            title: l10n.notificationsLoadError,
            description: l10n.notificationsOfflineError,
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(notificationsListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.notificationsMarkAllReadError,
          ),
        ),
      );
    }
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      try {
        await ref
            .read(notificationsRepositoryProvider)
            .markAsRead(notification.id);
        ref.invalidate(notificationsListProvider);
        ref.invalidate(unreadNotificationCountProvider);
      } on Object {
        // Opening the source-of-truth detail must not depend on a read receipt.
      }
    }
    final otoxpertId = notification.otoxpertBookingId;
    final toyotaId = notification.toyotaServiceBookingId;
    final creditId = notification.creditSimulationId;
    final bodyPaintId = notification.bodyPaintEstimateId;
    if (bodyPaintId != null && context.mounted) {
      context.push('/body-paint/estimates/$bodyPaintId');
    } else if (creditId != null && context.mounted) {
      context.push('/credit/simulations/$creditId');
    } else if (otoxpertId != null && context.mounted) {
      context.push('/otoxpert/bookings/$otoxpertId');
    } else if (toyotaId != null && context.mounted) {
      context.push('/toyota-service/bookings/$toyotaId');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: notification.isRead
            ? Colors.transparent
            : Theme.of(context).colorScheme.primaryContainer.withValues(
                  alpha: .32,
                ),
        child: ListTile(
          leading: Icon(
            notification.bodyPaintEstimateId != null
                ? Icons.format_paint_outlined
                : notification.creditSimulationId != null
                    ? Icons.calculate_outlined
                    : notification.otoxpertBookingId != null
                        ? Icons.handyman_outlined
                        : notification.toyotaServiceBookingId != null
                            ? Icons.car_repair_outlined
                            : Icons.notifications_outlined,
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
          subtitle: Text(notification.body),
          trailing: notification.isRead
              ? const Icon(Icons.chevron_right_rounded)
              : const Badge(),
          onTap: onTap,
        ),
      );
}

class _NotificationEmpty extends StatelessWidget {
  const _NotificationEmpty({
    required this.title,
    required this.description,
    this.action,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 56),
              const SizedBox(height: AppSpacing.medium),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              Text(description, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.medium),
                action!,
              ],
            ],
          ),
        ),
      );
}
