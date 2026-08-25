import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../domain/otoxpert_models.dart';
import '../otoxpert_controller.dart';
import '../otoxpert_paths.dart';

class AdminOtoxpertQueueScreen extends ConsumerStatefulWidget {
  const AdminOtoxpertQueueScreen({super.key});

  @override
  ConsumerState<AdminOtoxpertQueueScreen> createState() =>
      _AdminOtoxpertQueueScreenState();
}

class _AdminOtoxpertQueueScreenState
    extends ConsumerState<AdminOtoxpertQueueScreen> {
  final _search = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || !auth.user.canViewAnyServiceBookings) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.otoxpertAdminQueue)),
        body: Center(child: Text(l10n.adminAccessDeniedDescription)),
      );
    }
    final bookings = ref.watch(adminOtoxpertBookingsProvider);
    final options = ref.watch(adminOtoxpertOptionsProvider).value;
    final statuses = (options?['statuses'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otoxpertAdminQueue)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: l10n.searchBookings,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  DropdownButton<String?>(
                    value: _status,
                    hint: Text(l10n.status),
                    items: [
                      DropdownMenuItem<String?>(
                        child: Text(l10n.otoxpertAllStatuses),
                      ),
                      for (final status in statuses)
                        DropdownMenuItem<String?>(
                          value: status['value']?.toString(),
                          child: Text(status['label']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookings.when(
                data: (items) {
                  final query = _search.text.trim().toLowerCase();
                  final filtered = items.where((item) {
                    final matchesStatus =
                        _status == null || item.status == _status;
                    final haystack = [
                      item.referenceNo,
                      item.customerName ?? '',
                      item.customerPhone ?? '',
                      item.vehicle?.displayName ?? '',
                      item.workshop?.name ?? '',
                    ].join(' ').toLowerCase();
                    return matchesStatus &&
                        (query.isEmpty || haystack.contains(query));
                  }).toList(growable: false);
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.refresh(adminOtoxpertBookingsProvider.future),
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppSpacing.xLarge,
                                ),
                                child: Center(
                                  child: Text(l10n.adminNoBookingsDescription),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.large),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(
                              height: AppSpacing.small,
                            ),
                            itemBuilder: (_, index) =>
                                _AdminBookingTile(booking: filtered[index]),
                          ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.invalidate(adminOtoxpertBookingsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBookingTile extends StatelessWidget {
  const _AdminBookingTile({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: booking.slaOverdue
                ? Theme.of(context).colorScheme.errorContainer
                : AppColors.accentSoft,
            child: Icon(
              booking.slaOverdue
                  ? Icons.timer_off_outlined
                  : Icons.handyman_outlined,
              color: booking.slaOverdue
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : AppColors.accent,
            ),
          ),
          title: Text(
            booking.customerName?.isNotEmpty == true
                ? booking.customerName!
                : booking.referenceNo,
          ),
          subtitle: Text(
            '${booking.referenceNo} • ${booking.statusLabel}\n'
            '${booking.vehicle?.displayName ?? '—'} • '
            '${booking.workshop?.name ?? '—'}',
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(adminOtoxpertBookingPath(booking.id)),
        ),
      );
}

class AdminOtoxpertBookingScreen extends ConsumerWidget {
  const AdminOtoxpertBookingScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final booking = ref.watch(adminOtoxpertBookingProvider(bookingId));
    final busy = ref.watch(adminOtoxpertMutationProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailTitle)),
      body: SafeArea(
        child: booking.when(
          data: (value) => RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(adminOtoxpertBookingProvider(bookingId).future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                _AdminHeader(booking: value),
                const SizedBox(height: AppSpacing.medium),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      children: [
                        _AdminLine(
                          label: l10n.customer,
                          value: value.customerName ?? '—',
                        ),
                        _AdminLine(
                          label: l10n.reviewVehicle,
                          value: value.vehicle?.displayName ?? '—',
                        ),
                        _AdminLine(
                          label: l10n.location,
                          value: value.workshop?.name ?? '—',
                        ),
                        _AdminLine(
                          label: l10n.service,
                          value: value.service?.name ?? '—',
                        ),
                        _AdminLine(
                          label: l10n.primarySchedule,
                          value: _adminSlot(value.primarySlot),
                        ),
                        _AdminLine(
                          label: l10n.alternativeSchedule,
                          value: _adminSlot(value.alternativeSlot),
                        ),
                        _AdminLine(
                          label: l10n.complaint,
                          value: value.complaint,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  l10n.bookingTimelineTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final item in value.timeline)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(item.title),
                    subtitle: Text(item.description ?? item.status),
                  ),
                if (value.availableAdminActions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    l10n.sendAdminAction,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  for (final action in value.availableAdminActions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: FilledButton.tonal(
                        onPressed: busy
                            ? null
                            : () => _performAction(
                                  context,
                                  ref,
                                  value,
                                  action,
                                ),
                        child: Text(action.label),
                      ),
                    ),
                ],
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(adminOtoxpertBookingProvider(bookingId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performAction(
    BuildContext context,
    WidgetRef ref,
    OtoxpertBooking booking,
    OtoxpertOption action,
  ) async {
    final options = await ref.read(adminOtoxpertOptionsProvider.future);
    var slots = <ToyotaServiceSlot>[];
    if (_needsSlot(action.value)) {
      if (action.value == 'confirm') {
        slots = [
          if (booking.primarySlot != null) booking.primarySlot!,
          if (booking.alternativeSlot != null) booking.alternativeSlot!,
        ];
      } else if (action.value == 'confirm_reschedule') {
        slots = [
          if (booking.reschedulePrimarySlot != null)
            booking.reschedulePrimarySlot!,
          if (booking.rescheduleAlternativeSlot != null)
            booking.rescheduleAlternativeSlot!,
        ];
      } else if (booking.workshop != null && booking.service != null) {
        final availability = await ref.read(
          otoxpertAvailabilityProvider(
            (
              workshopId: booking.workshop!.id,
              serviceId: booking.service!.id,
            ),
          ).future,
        );
        slots = availability.slots;
      }
    }
    if (!context.mounted) return;
    final fields = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AdminActionDialog(
        action: action,
        options: options,
        slots: slots,
      ),
    );
    if (fields == null) return;
    final result = await ref
        .read(adminOtoxpertMutationProvider.notifier)
        .perform(booking.id, action.value, fields);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == null
              ? AppLocalizations.of(context)!.bookingMutationFailed
              : AppLocalizations.of(context)!.adminActionSuccess,
        ),
      ),
    );
  }
}

class _AdminActionDialog extends StatefulWidget {
  const _AdminActionDialog({
    required this.action,
    required this.options,
    required this.slots,
  });

  final OtoxpertOption action;
  final Map<String, dynamic> options;
  final List<ToyotaServiceSlot> slots;

  @override
  State<_AdminActionDialog> createState() => _AdminActionDialogState();
}

class _AdminActionDialogState extends State<_AdminActionDialog> {
  final _reason = TextEditingController();
  final _pic = TextEditingController();
  final _instructions = TextEditingController();
  final _external = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  final _internal = TextEditingController();
  final _followUp = TextEditingController();
  ToyotaServiceSlot? _slot;
  String? _reasonCode;
  int? _operatorId;

  @override
  void dispose() {
    _reason.dispose();
    _pic.dispose();
    _instructions.dispose();
    _external.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    _internal.dispose();
    _followUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasons =
        (widget.options['reason_codes'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
    final operators =
        (widget.options['operators'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
    final reasonRequired = _needsReason(widget.action.value);
    return AlertDialog(
      title: Text(widget.action.label),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.action.value == 'assign')
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.assignedAdvisor),
                  items: [
                    for (final item in operators)
                      DropdownMenuItem(
                        value: (item['id'] as num?)?.toInt(),
                        child: Text(item['name']?.toString() ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => _operatorId = value),
                ),
              if (_needsSlot(widget.action.value))
                DropdownButtonFormField<ToyotaServiceSlot>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.timeWindowLabel),
                  items: [
                    for (final slot in widget.slots)
                      DropdownMenuItem(
                        value: slot,
                        child: Text(_adminSlot(slot)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _slot = value),
                ),
              if (reasonRequired) ...[
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.reasonCodeLabel),
                  items: [
                    for (final item in reasons)
                      DropdownMenuItem(
                        value: item['value']?.toString(),
                        child: Text(item['label']?.toString() ?? ''),
                      ),
                  ],
                  onChanged: (value) => setState(() => _reasonCode = value),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 4,
                  decoration:
                      InputDecoration(labelText: l10n.adminActionReason),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              if (_operationalFields(widget.action.value)) ...[
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _pic,
                  decoration: InputDecoration(labelText: l10n.picNameLabel),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _external,
                  decoration:
                      InputDecoration(labelText: l10n.externalBookingNumber),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _instructions,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.arrivalInstructionsLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMin,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.otoxpertIndicativePrice,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: TextField(
                        controller: _priceMax,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.otoxpertMaximumPrice,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _internal,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.internalNote),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _followUp,
                decoration:
                    InputDecoration(labelText: l10n.otoxpertFollowUpOutcome),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _valid(reasonRequired)
              ? () => Navigator.pop(context, _fields())
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  bool _valid(bool reasonRequired) {
    if (widget.action.value == 'assign' && _operatorId == null) return false;
    if (_needsSlot(widget.action.value) && _slot == null) return false;
    if (reasonRequired &&
        (_reasonCode == null || _reason.text.trim().length < 5)) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> _fields() {
    final minimum = int.tryParse(_priceMin.text);
    final maximum = int.tryParse(_priceMax.text);
    return {
      if (_operatorId != null) 'operator_id': _operatorId,
      if (_slot != null) 'slot': _slot!.toJson(),
      if (_reasonCode != null) 'reason_code': _reasonCode,
      if (_reason.text.trim().isNotEmpty) 'reason': _reason.text.trim(),
      if (_pic.text.trim().isNotEmpty) 'pic_name': _pic.text.trim(),
      if (_instructions.text.trim().isNotEmpty)
        'arrival_instructions': _instructions.text.trim(),
      if (_external.text.trim().isNotEmpty)
        'external_booking_number': _external.text.trim(),
      if (minimum != null) ...{
        'quoted_price_min': minimum,
        'quoted_price_type': maximum == null ? 'from' : 'range',
      },
      if (maximum != null) 'quoted_price_max': maximum,
      if (_internal.text.trim().isNotEmpty)
        'internal_note': _internal.text.trim(),
      if (_followUp.text.trim().isNotEmpty)
        'follow_up_outcome': _followUp.text.trim(),
    };
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.booking});

  final OtoxpertBooking booking;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: booking.slaOverdue
              ? Theme.of(context).colorScheme.errorContainer
              : AppColors.accentSoft,
          borderRadius: AppRadius.large,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            children: [
              const Icon(Icons.handyman_outlined),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.statusLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(booking.referenceNo),
                  ],
                ),
              ),
              if (booking.slaOverdue)
                Chip(
                  avatar: const Icon(Icons.timer_off_outlined),
                  label: Text(
                    AppLocalizations.of(context)!.slaOverdueLabel,
                  ),
                ),
            ],
          ),
        ),
      );
}

class _AdminLine extends StatelessWidget {
  const _AdminLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
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

bool _needsSlot(String action) => const {
      'confirm',
      'propose_alternative',
      'confirm_reschedule',
    }.contains(action);

bool _needsReason(String action) => const {
      'propose_alternative',
      'reject',
      'mark_no_show',
      'cancel',
    }.contains(action);

bool _operationalFields(String action) => const {
      'confirm',
      'propose_alternative',
      'confirm_reschedule',
    }.contains(action);

String _adminSlot(ToyotaServiceSlot? slot) =>
    slot == null ? '—' : '${slot.date} • ${slot.timeWindow}';
