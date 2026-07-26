import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';

class AppraisalActivityScreen extends ConsumerWidget {
  const AppraisalActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(appraisalsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: SafeArea(
        child: async.when(
          data: (items) => RefreshIndicator(
            onRefresh: () async => ref.refresh(appraisalsProvider.future),
            child: items.isEmpty
                ? const _DemoActivityList()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.medium),
                    itemBuilder: (context, index) =>
                        _ActivityCard(appraisal: items[index]),
                  ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _LoadError(
            onRetry: () => ref.invalidate(appraisalsProvider),
          ),
        ),
      ),
    );
  }
}

class _DemoActivityList extends StatelessWidget {
  const _DemoActivityList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activities = [
      (
        Icons.fact_check_rounded,
        l10n.demoActivityAppraisalTitle,
        l10n.demoActivityAppraisalSubtitle,
        l10n.demoActivityReviewStatus,
        AppColors.appraisalBlue,
        AppColors.appraisalBlueSoft,
      ),
      (
        Icons.car_repair_rounded,
        l10n.demoActivityServiceTitle,
        l10n.demoActivityServiceSubtitle,
        l10n.demoActivityConfirmedStatus,
        AppColors.serviceOrange,
        AppColors.serviceOrangeSoft,
      ),
      (
        Icons.calculate_rounded,
        l10n.demoActivityCreditTitle,
        l10n.demoActivityCreditSubtitle,
        l10n.demoActivitySavedStatus,
        AppColors.serviceGreen,
        AppColors.serviceGreenSoft,
      ),
      (
        Icons.format_paint_rounded,
        l10n.demoActivityBodyPaintTitle,
        l10n.demoActivityBodyPaintSubtitle,
        l10n.demoActivityDraftStatus,
        AppColors.serviceRose,
        AppColors.serviceRoseSoft,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: AppRadius.medium,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    l10n.demoActivityNotice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.demoActivityRecentTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.large,
          ),
          child: Column(
            children: [
              for (var index = 0; index < activities.length; index++) ...[
                _DemoActivityTile(activity: activities[index]),
                if (index != activities.length - 1)
                  const Divider(
                    height: 1,
                    indent: 80,
                    endIndent: AppSpacing.large,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoActivityTile extends StatelessWidget {
  const _DemoActivityTile({required this.activity});

  final (
    IconData,
    String,
    String,
    String,
    Color,
    Color,
  ) activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: activity.$6,
              borderRadius: AppRadius.medium,
            ),
            child: SizedBox.square(
              dimension: 52,
              child: Icon(
                activity.$1,
                color: activity.$5,
                size: AppIconSize.large,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  activity.$3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  activity.$4,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: activity.$5,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.appraisal});

  final AppraisalData appraisal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicle = appraisal.vehicle;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          appraisal.resultReady
              ? appraisalResultPath(appraisal.id)
              : appraisalDetailPath(appraisal.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: appraisal.needsAction
                    ? colors.errorContainer
                    : colors.primaryContainer,
                child: Icon(
                  appraisal.needsAction
                      ? Icons.priority_high_rounded
                      : Icons.directions_car_outlined,
                  color: appraisal.needsAction
                      ? colors.onErrorContainer
                      : colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle == null
                          ? appraisal.referenceNo
                          : '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      appraisal.referenceNo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(appraisal.statusLabel),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.loadFailed),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
