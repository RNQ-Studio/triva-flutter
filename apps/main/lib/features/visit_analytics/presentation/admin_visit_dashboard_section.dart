import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/visit_analytics_models.dart';
import 'visit_analytics_controller.dart';

class AdminVisitDashboardSection extends ConsumerWidget {
  const AdminVisitDashboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statistics = ref.watch(adminVisitStatisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminVisitDashboardTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    l10n.adminVisitDashboardDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            IconButton(
              onPressed: statistics.isLoading
                  ? null
                  : () => ref.invalidate(adminVisitStatisticsProvider),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l10n.adminVisitRefresh,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        statistics.when(
          loading: _VisitDashboardLoading.new,
          error: (error, _) => _VisitDashboardError(
            offline: _isOffline(error),
            onRetry: () => ref.invalidate(adminVisitStatisticsProvider),
          ),
          data: (snapshot) => snapshot.isEmpty
              ? const _VisitDashboardEmpty()
              : _VisitDashboardContent(snapshot: snapshot),
        ),
      ],
    );
  }
}

class _VisitDashboardContent extends StatelessWidget {
  const _VisitDashboardContent({required this.snapshot});

  final VisitAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMd(locale).add_Hm();
    final periods = <(VisitPeriod, String, IconData)>[
      (VisitPeriod.daily, l10n.adminVisitDaily, Icons.today_outlined),
      (VisitPeriod.weekly, l10n.adminVisitWeekly, Icons.date_range_outlined),
      (
        VisitPeriod.monthly,
        l10n.adminVisitMonthly,
        Icons.calendar_month_outlined
      ),
      (
        VisitPeriod.overall,
        l10n.adminVisitOverall,
        Icons.all_inclusive_rounded
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          key: const ValueKey('admin-visit-statistics-content'),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < periods.length; index++) ...[
                _VisitPeriodRow(
                  label: periods[index].$2,
                  icon: periods[index].$3,
                  statistics: snapshot.forPeriod(periods[index].$1),
                ),
                if (index < periods.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.large,
                    endIndent: AppSpacing.large,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          snapshot.trackingStartedAt == null
              ? l10n.adminVisitTrackingStartsNow
              : l10n.adminVisitRecordedSince(
                  dateFormat.format(snapshot.trackingStartedAt!.toLocal()),
                ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          l10n.adminVisitUpdatedAt(
            dateFormat.format(snapshot.generatedAt.toLocal()),
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _VisitPeriodRow extends StatelessWidget {
  const _VisitPeriodRow({
    required this.label,
    required this.icon,
    required this.statistics,
  });

  final String label;
  final IconData icon;
  final VisitPeriodStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.small),
          Text(
            number.format(statistics.total),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xSmall),
        child: Wrap(
          spacing: AppSpacing.medium,
          runSpacing: AppSpacing.xSmall,
          children: [
            _VisitSourceValue(
              label: l10n.adminVisitAndroid,
              value: number.format(statistics.countFor(VisitSource.android)),
            ),
            _VisitSourceValue(
              label: l10n.adminVisitWeb,
              value: number.format(statistics.countFor(VisitSource.web)),
            ),
            _VisitSourceValue(
              label: l10n.adminVisitLandingPage,
              value:
                  number.format(statistics.countFor(VisitSource.landingPage)),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitSourceValue extends StatelessWidget {
  const _VisitSourceValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _VisitDashboardLoading extends StatelessWidget {
  const _VisitDashboardLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey('admin-visit-statistics-loading'),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < VisitPeriod.values.length; index++) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.surfaceContainerHighest,
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: .45,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppRadius.small,
                    ),
                    child: const SizedBox(height: AppSpacing.medium),
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.small),
                child: FractionallySizedBox(
                  widthFactor: .8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppRadius.small,
                    ),
                    child: const SizedBox(height: AppSpacing.small),
                  ),
                ),
              ),
            ),
            if (index < VisitPeriod.values.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.large,
                endIndent: AppSpacing.large,
                color: colors.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _VisitDashboardEmpty extends StatelessWidget {
  const _VisitDashboardEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _VisitMessageCard(
      icon: Icons.query_stats_rounded,
      title: l10n.adminVisitEmptyTitle,
      description: l10n.adminVisitEmptyDescription,
    );
  }
}

class _VisitDashboardError extends StatelessWidget {
  const _VisitDashboardError({
    required this.offline,
    required this.onRetry,
  });

  final bool offline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _VisitMessageCard(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: offline ? l10n.adminVisitOfflineTitle : l10n.adminVisitErrorTitle,
      description: offline
          ? l10n.adminVisitOfflineDescription
          : l10n.adminVisitErrorDescription,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.retry),
      ),
    );
  }
}

class _VisitMessageCard extends StatelessWidget {
  const _VisitMessageCard({
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

bool _isOffline(Object error) {
  if (error is NetworkException) return true;
  if (error is! DioException) return false;
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout;
}
