import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';

class AppraisalResultScreen extends ConsumerStatefulWidget {
  const AppraisalResultScreen({super.key, required this.appraisalId});

  final String appraisalId;

  @override
  ConsumerState<AppraisalResultScreen> createState() =>
      _AppraisalResultScreenState();
}

class _AppraisalResultScreenState extends ConsumerState<AppraisalResultScreen> {
  bool _busy = false;

  Future<void> _decide(String decision) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(appraisalRepositoryProvider)
          .decide(widget.appraisalId, decision);
      ref.invalidate(appraisalsProvider);
      ref.invalidate(appraisalDetailProvider(widget.appraisalId));
      if (!mounted) return;
      if (decision == 'deferred') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.decisionDeferredMessage),
          ),
        );
        context.go(appraisalActivityPath);
      } else {
        context.go(appraisalCompletePath(widget.appraisalId, decision));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _schedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) return;
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => _busy = true);
    try {
      await ref.read(appraisalRepositoryProvider).scheduleInspection(
            widget.appraisalId,
            scheduled,
          );
      ref.invalidate(appraisalsProvider);
      if (mounted) {
        context.go(appraisalCompletePath(widget.appraisalId, 'inspection'));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(appraisalDetailProvider(widget.appraisalId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: SafeArea(
        child: async.when(
          data: (appraisal) {
            final result = appraisal.result;
            if (result == null) {
              return Center(child: Text(l10n.loadFailed));
            }
            return _ResultContent(
              appraisal: appraisal,
              result: result,
              busy: _busy,
              onAccept: () => _decide('accepted'),
              onReject: () => _decide('rejected'),
              onDefer: () => _decide('deferred'),
              onSchedule: _schedule,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(
                appraisalDetailProvider(widget.appraisalId),
              ),
              child: Text(l10n.retry),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({
    required this.appraisal,
    required this.result,
    required this.busy,
    required this.onAccept,
    required this.onReject,
    required this.onDefer,
    required this.onSchedule,
  });

  final AppraisalData appraisal;
  final AppraisalResultData result;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDefer;
  final VoidCallback onSchedule;

  String _money(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final date = result.validUntil == null
        ? '-'
        : DateFormat('d MMMM yyyy', 'id_ID').format(result.validUntil!);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        Text(
          appraisal.vehicle == null
              ? appraisal.referenceNo
              : '${appraisal.vehicle!.make} ${appraisal.vehicle!.model} '
                  '${appraisal.vehicle!.variant} · ${appraisal.vehicle!.year}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.large),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tradeInEstimate,
                  style: TextStyle(color: colors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.small),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${_money(result.tradeInLow)} – '
                    '${_money(result.tradeInHigh)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  l10n.validUntil(date),
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              children: [
                _ResultRow(
                  label: l10n.marketRange,
                  value:
                      '${_money(result.marketLow)} – ${_money(result.marketHigh)}',
                ),
                const Divider(height: AppSpacing.xLarge),
                _ResultRow(
                  label: l10n.confidence,
                  value: result.confidence.toUpperCase(),
                ),
                const Divider(height: AppSpacing.xLarge),
                _ResultRow(
                  label: l10n.comparableCount(result.comparableCount),
                  value: result.comparableCount.toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          result.disclaimer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xLarge),
        FilledButton(
          onPressed: busy ? null : onAccept,
          child: Text(l10n.acceptPrice),
        ),
        const SizedBox(height: AppSpacing.small),
        if (result.requiresPhysicalInspection) ...[
          OutlinedButton.icon(
            onPressed: busy ? null : onSchedule,
            icon: const Icon(Icons.event_available_outlined),
            label: Text(l10n.scheduleInspection),
          ),
          const SizedBox(height: AppSpacing.small),
        ],
        OutlinedButton(
          onPressed: busy ? null : onReject,
          child: Text(l10n.declinePrice),
        ),
        TextButton(
          onPressed: busy ? null : onDefer,
          child: Text(l10n.decideLater),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
          softWrap: true,
        ),
      ],
    );
  }
}
