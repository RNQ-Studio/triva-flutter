import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../domain/otoxpert_models.dart';
import '../otoxpert_controller.dart';

class OtoxpertBookingScreen extends ConsumerWidget {
  const OtoxpertBookingScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final booking = ref.watch(otoxpertBookingProvider(bookingId));
    final mutation = ref.watch(otoxpertMutationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailTitle)),
      body: SafeArea(
        child: booking.when(
          data: (value) => RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(otoxpertBookingProvider(bookingId).future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                _StatusHeader(booking: value),
                const SizedBox(height: AppSpacing.medium),
                _BookingSummary(booking: value),
                if (value.price != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _PriceSummary(price: value.price!),
                ],
                if (value.proposedSlot != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _AlternativeCard(booking: value),
                ],
                if (value.isConfirmed) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _ConfirmedCard(booking: value),
                ],
                const SizedBox(height: AppSpacing.large),
                Text(
                  l10n.bookingTimelineTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                if (value.timeline.isEmpty)
                  Text(l10n.bookingGenericDescription)
                else
                  for (final item in value.timeline) _TimelineTile(item: item),
                if (value.allowedCustomerActions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.large),
                  _CustomerActions(
                    booking: value,
                    busy: mutation.isLoading,
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                OutlinedButton.icon(
                  onPressed: () => context.go('/activity'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(l10n.backToActivity),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorState(
            onRetry: () => ref.invalidate(
              otoxpertBookingProvider(bookingId),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.serviceVioletSoft,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.serviceViolet,
              foregroundColor: colors.onPrimary,
              child: Icon(_statusIcon(booking.status)),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.statusLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(booking.referenceNo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Line(
              label: l10n.reviewVehicle,
              value: booking.vehicle?.displayName ?? '—',
            ),
            _Line(label: l10n.location, value: booking.workshop?.name ?? '—'),
            if (booking.workshop != null)
              _Line(label: l10n.fullAddress, value: booking.workshop!.address),
            _Line(label: l10n.service, value: booking.service?.name ?? '—'),
            _Line(
              label: l10n.currentMileage,
              value: NumberFormat.decimalPattern(
                Localizations.localeOf(context).toLanguageTag(),
              ).format(booking.currentMileage),
            ),
            _Line(label: l10n.complaint, value: booking.complaint),
            _Line(
              label: l10n.primarySchedule,
              value: _slot(booking.primarySlot),
            ),
            _Line(
              label: l10n.alternativeSchedule,
              value: _slot(booking.alternativeSlot),
            ),
            if (booking.reason != null)
              _Line(label: l10n.rejectionReason, value: booking.reason!),
          ],
        ),
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.alternativeProposedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            _Line(
                label: l10n.advisorProposal,
                value: _slot(booking.proposedSlot)),
            if (booking.proposalReason != null)
              _Line(
                label: l10n.proposalReasonLabel,
                value: booking.proposalReason!,
              ),
            if (booking.proposalExpiresAt != null)
              _Line(
                label: l10n.proposalDeadline,
                value: DateFormat.yMMMd(
                  Localizations.localeOf(context).toLanguageTag(),
                ).add_Hm().format(booking.proposalExpiresAt!.toLocal()),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  const _ConfirmedCard({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookingConfirmedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            _Line(
              label: l10n.confirmedSchedule,
              value: _slot(booking.confirmedSlot),
            ),
            if (booking.operatorName != null)
              _Line(label: l10n.serviceAdvisor, value: booking.operatorName!),
            if (booking.externalBookingNumber != null)
              _Line(
                label: l10n.partnerBookingNumber,
                value: booking.externalBookingNumber!,
              ),
            if (booking.arrivalInstructions != null)
              _Line(
                label: l10n.arrivalInstructions,
                value: booking.arrivalInstructions!,
              ),
            if (booking.operatorPhone != null) ...[
              const SizedBox(height: AppSpacing.small),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri(
                    scheme: 'tel',
                    path: booking.operatorPhone,
                  ),
                ),
                icon: const Icon(Icons.phone_outlined),
                label: Text(l10n.contactServiceAdvisor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.price});

  final OtoxpertPrice price;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final amount = price.maximumAmount == null
        ? formatter.format(price.minimumAmount)
        : '${formatter.format(price.minimumAmount)} – '
            '${formatter.format(price.maximumAmount)}';
    return Card(
      color: AppColors.serviceVioletSoft,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.otoxpertIndicativePrice,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(amount, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              price.disclaimer.isEmpty
                  ? l10n.otoxpertPriceDisclaimer
                  : price.disclaimer,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});

  final ToyotaServiceTimelineItem item;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          radius: AppIconSize.medium,
          child: Icon(Icons.check_rounded, size: AppIconSize.medium),
        ),
        title: Text(item.title),
        subtitle: Text(
          [
            if (item.description?.isNotEmpty == true) item.description!,
            if (item.occurredAt != null)
              DateFormat.yMMMd(
                Localizations.localeOf(context).toLanguageTag(),
              ).add_Hm().format(item.occurredAt!.toLocal()),
          ].join('\n'),
        ),
      );
}

class _CustomerActions extends ConsumerWidget {
  const _CustomerActions({required this.booking, required this.busy});

  final OtoxpertBooking booking;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booking.canAcceptAlternative)
          FilledButton.icon(
            onPressed: busy ? null : () => _acceptAlternative(context, ref),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.acceptAlternative),
          ),
        if (booking.canRejectAlternative)
          OutlinedButton(
            onPressed: busy
                ? null
                : () => _scheduleDialog(
                      context,
                      ref,
                      action: 'reject-alternative',
                    ),
            child: Text(l10n.rejectAlternative),
          ),
        if (booking.canReschedule)
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () => _scheduleDialog(
                      context,
                      ref,
                      action: 'reschedule',
                    ),
            icon: const Icon(Icons.event_repeat_outlined),
            label: Text(l10n.requestReschedule),
          ),
        if (booking.canCancel)
          TextButton.icon(
            onPressed: busy ? null : () => _cancelDialog(context, ref),
            icon: const Icon(Icons.cancel_outlined),
            label: Text(l10n.cancelBooking),
          ),
      ],
    );
  }

  Future<void> _acceptAlternative(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await ref
        .read(otoxpertMutationProvider.notifier)
        .acceptAlternative(booking.id);
    if (!context.mounted || result != null) return;
    _showFailure(context);
  }

  Future<void> _scheduleDialog(
    BuildContext context,
    WidgetRef ref, {
    required String action,
  }) async {
    final workshop = booking.workshop;
    final service = booking.service;
    if (workshop == null || service == null) return;
    final availability = await ref.read(
      otoxpertAvailabilityProvider(
        (workshopId: workshop.id, serviceId: service.id),
      ).future,
    );
    if (!context.mounted) return;
    final result = await showDialog<
        ({
          ToyotaServiceSlot primary,
          ToyotaServiceSlot alternative,
          String reason
        })>(
      context: context,
      builder: (_) => _ScheduleDialog(
        slots: availability.slots,
        title: action == 'reschedule'
            ? AppLocalizations.of(context)!.rescheduleTitle
            : AppLocalizations.of(context)!.chooseReplacementSchedule,
      ),
    );
    if (result == null) return;
    final updated =
        await ref.read(otoxpertMutationProvider.notifier).sendSchedule(
              booking.id,
              action: action,
              primary: result.primary,
              alternative: result.alternative,
              reason: result.reason,
            );
    if (!context.mounted || updated != null) return;
    _showFailure(context);
  }

  Future<void> _cancelDialog(BuildContext context, WidgetRef ref) async {
    final reason = await _reasonDialog(
      context,
      title: AppLocalizations.of(context)!.confirmCancellation,
    );
    if (reason == null) return;
    final result = await ref
        .read(otoxpertMutationProvider.notifier)
        .cancel(booking.id, reason);
    if (!context.mounted || result != null) return;
    _showFailure(context);
  }
}

class _ScheduleDialog extends StatefulWidget {
  const _ScheduleDialog({required this.slots, required this.title});

  final List<ToyotaServiceSlot> slots;
  final String title;

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _reason = TextEditingController();
  ToyotaServiceSlot? _primary;
  ToyotaServiceSlot? _alternative;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ToyotaServiceSlot>(
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.newPrimarySchedule),
              items: _items(),
              onChanged: (value) => setState(() => _primary = value),
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<ToyotaServiceSlot>(
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: l10n.newAlternativeSchedule),
              items: _items(disabled: _primary),
              onChanged: (value) => setState(() => _alternative = value),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.changeReason),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _primary == null ||
                  _alternative == null ||
                  _primary == _alternative ||
                  _reason.text.trim().length < 5
              ? null
              : () => Navigator.pop(
                    context,
                    (
                      primary: _primary!,
                      alternative: _alternative!,
                      reason: _reason.text.trim(),
                    ),
                  ),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  List<DropdownMenuItem<ToyotaServiceSlot>> _items({
    ToyotaServiceSlot? disabled,
  }) =>
      [
        for (final slot in widget.slots)
          DropdownMenuItem(
            value: slot,
            enabled: slot != disabled,
            child: Text(_slot(slot)),
          ),
      ];
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 132,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem_rounded, size: AppIconSize.service),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.bookingOfflineError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _reasonDialog(
  BuildContext context, {
  required String title,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.cancelReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.length >= 5) Navigator.pop(dialogContext, reason);
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}

void _showFailure(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.bookingMutationFailed),
    ),
  );
}

String _slot(ToyotaServiceSlot? value) =>
    value == null ? '—' : '${value.date} • ${value.timeWindow}';

IconData _statusIcon(String status) => switch (status) {
      'confirmed' => Icons.event_available_rounded,
      'checked_in' || 'in_service' => Icons.build_circle_outlined,
      'completed' => Icons.task_alt_rounded,
      'cancelled' ||
      'rejected' ||
      'expired' ||
      'no_show' =>
        Icons.event_busy_outlined,
      _ => Icons.schedule_rounded,
    };
