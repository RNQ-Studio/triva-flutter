import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/demographics_models.dart';
import 'admin_analytics_widgets.dart';
import 'visit_analytics_controller.dart';

/// Sebaran jenis kelamin dan usia pengguna terdaftar.
class AdminDemographicsSection extends ConsumerWidget {
  const AdminDemographicsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final demographics = ref.watch(adminDemographicsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminAnalyticsHeader(
          title: l10n.adminDemographicsTitle,
          description: l10n.adminDemographicsDescription,
          refreshTooltip: l10n.adminVisitRefresh,
          onRefresh: demographics.isLoading
              ? null
              : () => ref.invalidate(adminDemographicsProvider),
        ),
        const SizedBox(height: AppSpacing.medium),
        demographics.when(
          loading: () => const _DemographicsLoading(),
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
              onPressed: () => ref.invalidate(adminDemographicsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (snapshot) => snapshot.isEmpty
              ? AdminAnalyticsMessageCard(
                  icon: Icons.groups_outlined,
                  title: l10n.adminDemographicsEmptyTitle,
                  description: l10n.adminDemographicsEmptyDescription,
                )
              : _DemographicsContent(snapshot: snapshot),
        ),
      ],
    );
  }
}

class _DemographicsContent extends StatelessWidget {
  const _DemographicsContent({required this.snapshot});

  final DemographicsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 0,
    );

    return Column(
      key: const ValueKey('admin-demographics-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.adminDemographicsRegistered)),
                    Text(
                      number.format(snapshot.totalUsers),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  l10n.adminDemographicsCompleted(
                    number.format(snapshot.completedProfiles),
                    percent.format(snapshot.completionRate),
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.large),
                _SegmentGroup(
                  title: l10n.adminDemographicsGender,
                  segments: snapshot.gender,
                  total: snapshot.totalUsers,
                ),
                const SizedBox(height: AppSpacing.large),
                _SegmentGroup(
                  title: l10n.adminDemographicsAge,
                  segments: snapshot.ageGroups,
                  total: snapshot.totalUsers,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentGroup extends StatelessWidget {
  const _SegmentGroup({
    required this.title,
    required this.segments,
    required this.total,
  });

  final String title;
  final List<DemographicsSegment> segments;
  final int total;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 0,
    );
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        for (final segment in segments) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        segment.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: segment.isUnknown
                                  ? colors.onSurfaceVariant
                                  : null,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Text(
                      '${number.format(segment.total)} '
                      '(${percent.format(segment.share)})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xSmall),
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : segment.total / total,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: segment.isUnknown ? colors.outline : colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DemographicsLoading extends StatelessWidget {
  const _DemographicsLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey('admin-demographics-loading'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            for (var index = 0; index < 4; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: FractionallySizedBox(
                  widthFactor: index.isEven ? .9 : .65,
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
