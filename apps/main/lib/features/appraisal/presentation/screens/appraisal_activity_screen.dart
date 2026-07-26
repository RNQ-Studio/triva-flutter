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
                ? ListView(
                    children: [
                      const SizedBox(height: 160),
                      Icon(
                        Icons.inbox_outlined,
                        size: 56,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        l10n.activityEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
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
