import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/credit_models.dart';
import '../credit_controller.dart';
import '../credit_paths.dart';
import 'widgets/credit_follow_up_dialog.dart';
import 'widgets/credit_result_sections.dart';

class CreditSimulationDetailScreen extends ConsumerStatefulWidget {
  const CreditSimulationDetailScreen({
    required this.simulationId,
    super.key,
  });

  final String simulationId;

  @override
  ConsumerState<CreditSimulationDetailScreen> createState() =>
      _CreditSimulationDetailScreenState();
}

class _CreditSimulationDetailScreenState
    extends ConsumerState<CreditSimulationDetailScreen> {
  CreditSimulation? _updatedSimulation;
  bool _isRequestingFollowUp = false;
  String? _followUpError;

  @override
  void didUpdateWidget(CreditSimulationDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simulationId != widget.simulationId) {
      _updatedSimulation = null;
      _isRequestingFollowUp = false;
      _followUpError = null;
    }
  }

  Future<void> _requestFollowUp() async {
    final channel = await showCreditFollowUpDialog(context);
    if (channel == null || !mounted) return;
    setState(() {
      _isRequestingFollowUp = true;
      _followUpError = null;
    });
    try {
      final simulation =
          await ref.read(creditRepositoryProvider).requestFollowUp(
                widget.simulationId,
                contactChannel: channel,
              );
      if (!mounted) return;
      setState(() {
        _updatedSimulation = simulation;
        _isRequestingFollowUp = false;
      });
      ref.invalidate(creditSimulationProvider(widget.simulationId));
      ref.invalidate(creditSimulationsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.creditFollowUpSuccess,
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      final message = friendlyCreditError(error);
      setState(() {
        _isRequestingFollowUp = false;
        _followUpError = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(creditSimulationProvider(widget.simulationId));
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
                      creditSimulationProvider(widget.simulationId),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (loadedSimulation) {
            final simulation = _newerSimulation(
              loadedSimulation,
              _updatedSimulation,
            );
            return ListView(
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
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
                        if (_followUpError != null) ...[
                          const SizedBox(height: AppSpacing.medium),
                          _FollowUpError(
                            message: _followUpError == 'general'
                                ? l10n.errorGeneral
                                : _followUpError!,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.medium),
                        Wrap(
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.small,
                          children: [
                            if (simulation.followUp == null)
                              FilledButton.icon(
                                onPressed: _isRequestingFollowUp
                                    ? null
                                    : _requestFollowUp,
                                icon: _isRequestingFollowUp
                                    ? const SizedBox.square(
                                        dimension: AppIconSize.medium,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.support_agent_rounded),
                                label: Text(
                                  _isRequestingFollowUp
                                      ? l10n.creditRequestingFollowUp
                                      : l10n.creditRequestSales,
                                ),
                              ),
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
            );
          },
        ),
      ),
    );
  }

  CreditSimulation _newerSimulation(
    CreditSimulation loaded,
    CreditSimulation? updated,
  ) {
    if (updated == null) return loaded;
    if (updated.followUp != null && loaded.followUp == null) return updated;
    final loadedAt = loaded.updatedAt ?? loaded.savedAt;
    final updatedAt = updated.updatedAt ?? updated.savedAt;
    return loadedAt.isBefore(updatedAt) ? updated : loaded;
  }
}

class _FollowUpError extends StatelessWidget {
  const _FollowUpError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
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
