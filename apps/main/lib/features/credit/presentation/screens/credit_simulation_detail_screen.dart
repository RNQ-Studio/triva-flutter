import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../credit_controller.dart';
import '../credit_paths.dart';
import 'widgets/credit_result_sections.dart';

class CreditSimulationDetailScreen extends ConsumerWidget {
  const CreditSimulationDetailScreen({
    required this.simulationId,
    super.key,
  });

  final String simulationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(creditSimulationProvider(simulationId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditFlowTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const _CreditDetailLoading(),
          error: (_, __) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              child: Column(
                children: [
                  Text(l10n.creditLoadFailed),
                  const SizedBox(height: AppSpacing.medium),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(
                      creditSimulationProvider(simulationId),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (simulation) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
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
                                  simulation.referenceNo,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.xSmall),
                                Text(simulation.statusLabel),
                              ],
                            ),
                          ),
                          const Icon(Icons.bookmark_added_outlined),
                        ],
                      ),
                      if (simulation.isProgramExpired) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _ExpiredNotice(message: l10n.creditProgramExpired),
                      ],
                      const SizedBox(height: AppSpacing.xLarge),
                      CreditResultSummary(
                        calculation: simulation.calculation,
                      ),
                      const SizedBox(height: AppSpacing.xLarge),
                      if (simulation.followUp != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.support_agent_rounded),
                          title: Text(l10n.creditRequestSales),
                          subtitle: Text(
                            '${simulation.followUp!.referenceNo} · '
                            '${simulation.followUp!.statusLabel}',
                          ),
                        ),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                subject: l10n.creditFlowTitle,
                                text: creditShareText(
                                  context,
                                  simulation.calculation,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined),
                            label: Text(l10n.creditShareSummary),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go(creditPath),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.creditStartNew),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditDetailLoading extends StatelessWidget {
  const _CreditDetailLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.xLarge),
        for (final factor in [0.48, 0.82, 1.0, 1.0])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: FractionallySizedBox(
              widthFactor: factor,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: AppSpacing.xLarge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: AppRadius.small,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpiredNotice extends StatelessWidget {
  const _ExpiredNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.history_rounded,
              color: colors.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
