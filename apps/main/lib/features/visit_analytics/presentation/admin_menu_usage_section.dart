import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/menu_usage_models.dart';
import '../domain/visit_analytics_models.dart';
import 'admin_analytics_widgets.dart';
import 'visit_analytics_controller.dart';

/// Menu yang paling sering dipilih pelanggan, dipecah per periode.
class AdminMenuUsageSection extends ConsumerStatefulWidget {
  const AdminMenuUsageSection({super.key});

  @override
  ConsumerState<AdminMenuUsageSection> createState() =>
      _AdminMenuUsageSectionState();
}

class _AdminMenuUsageSectionState extends ConsumerState<AdminMenuUsageSection> {
  VisitPeriod _period = VisitPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usage = ref.watch(adminMenuUsageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminAnalyticsHeader(
          title: l10n.adminMenuUsageTitle,
          description: l10n.adminMenuUsageDescription,
          refreshTooltip: l10n.adminVisitRefresh,
          onRefresh: usage.isLoading
              ? null
              : () => ref.invalidate(adminMenuUsageProvider),
        ),
        const SizedBox(height: AppSpacing.medium),
        usage.when(
          loading: () => const _MenuUsageLoading(),
          error: (error, _) => AdminAnalyticsMessageCard(
            icon: isAnalyticsOffline(error)
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded,
            title: isAnalyticsOffline(error)
                ? l10n.adminVisitOfflineTitle
                : l10n.adminVisitErrorTitle,
            description: isAnalyticsOffline(error)
                ? l10n.adminVisitOfflineDescription
                : l10n.adminVisitErrorDescription,
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(adminMenuUsageProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (snapshot) => snapshot.isEmpty
              ? AdminAnalyticsMessageCard(
                  icon: Icons.touch_app_outlined,
                  title: l10n.adminMenuUsageEmptyTitle,
                  description: l10n.adminMenuUsageEmptyDescription,
                )
              : _MenuUsageContent(
                  snapshot: snapshot,
                  period: _period,
                  onPeriodChanged: (value) => setState(() => _period = value),
                ),
        ),
      ],
    );
  }
}

class _MenuUsageContent extends StatelessWidget {
  const _MenuUsageContent({
    required this.snapshot,
    required this.period,
    required this.onPeriodChanged,
  });

  final MenuUsageSnapshot snapshot;
  final VisitPeriod period;
  final ValueChanged<VisitPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 0,
    );
    final selected = snapshot.forPeriod(period);
    final labels = <VisitPeriod, String>{
      VisitPeriod.daily: l10n.adminVisitDaily,
      VisitPeriod.weekly: l10n.adminVisitWeekly,
      VisitPeriod.monthly: l10n.adminVisitMonthly,
      VisitPeriod.overall: l10n.adminVisitOverall,
    };
    final busiest = selected.menus.isEmpty ? 0 : selected.menus.first.total;

    return Column(
      key: const ValueKey('admin-menu-usage-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in labels.entries)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.small),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: entry.key == period,
                    onSelected: (_) => onPeriodChanged(entry.key),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.adminMenuUsageTotal)),
                    Text(
                      number.format(selected.total),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                if (selected.menus.isEmpty)
                  Text(
                    l10n.adminMenuUsagePeriodEmpty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                else
                  for (var index = 0; index < selected.menus.length; index++)
                    _MenuUsageRow(
                      rank: index + 1,
                      entry: selected.menus[index],
                      busiest: busiest,
                      countLabel:
                          '${number.format(selected.menus[index].total)}'
                          ' (${percent.format(selected.menus[index].share)})',
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuUsageRow extends StatelessWidget {
  const _MenuUsageRow({
    required this.rank,
    required this.entry,
    required this.busiest,
    required this.countLabel,
  });

  final int rank;
  final MenuUsageEntry entry;
  final int busiest;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(countLabel, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: ClipRRect(
              borderRadius: AppRadius.small,
              child: LinearProgressIndicator(
                value: busiest == 0 ? 0 : entry.total / busiest,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHighest,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuUsageLoading extends StatelessWidget {
  const _MenuUsageLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey('admin-menu-usage-loading'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            for (var index = 0; index < 4; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: FractionallySizedBox(
                  widthFactor: index.isEven ? .85 : .6,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppRadius.small,
                    ),
                    child: const SizedBox(height: AppSpacing.medium),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
