import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Kartu pesan bersama untuk seluruh bagian analitik pada panel admin.
class AdminAnalyticsMessageCard extends StatelessWidget {
  const AdminAnalyticsMessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kegagalan muat yang disebabkan koneksi, bukan kesalahan server.
bool isAnalyticsOffline(Object error) {
  if (error is NetworkException) return true;
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}

/// Judul bagian analitik dengan tombol muat ulang.
class AdminAnalyticsHeader extends StatelessWidget {
  const AdminAnalyticsHeader({
    super.key,
    required this.title,
    required this.description,
    required this.onRefresh,
    required this.refreshTooltip,
  });

  final String title;
  final String description;
  final VoidCallback? onRefresh;
  final String refreshTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: refreshTooltip,
        ),
      ],
    );
  }
}
