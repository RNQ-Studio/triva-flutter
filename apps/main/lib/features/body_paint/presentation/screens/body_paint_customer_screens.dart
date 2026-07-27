import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../../toyota_service/presentation/toyota_service_paths.dart';
import '../../domain/body_paint_models.dart';
import '../body_paint_controller.dart';
import '../body_paint_paths.dart';

class BodyPaintEstimateScreen extends ConsumerWidget {
  const BodyPaintEstimateScreen({required this.estimateId, super.key});

  final String estimateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final estimate = ref.watch(bodyPaintEstimateProvider(estimateId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintFlowTitle)),
      body: SafeArea(
        child: estimate.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _BodyPaintError(
            onRetry: () =>
                ref.invalidate(bodyPaintEstimateProvider(estimateId)),
          ),
          data: (value) => RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(bodyPaintEstimateProvider(estimateId).future),
            child: _EstimateContent(estimate: value),
          ),
        ),
      ),
    );
  }
}

class _EstimateContent extends ConsumerWidget {
  const _EstimateContent({required this.estimate});

  final BodyPaintEstimate estimate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mutation = ref.watch(bodyPaintMutationProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.medium,
        AppSpacing.large,
        AppSpacing.xLarge,
      ),
      children: [
        _StatusCard(estimate: estimate),
        if (estimate.result != null) ...[
          const SizedBox(height: AppSpacing.medium),
          _ResultCard(result: estimate.result!),
        ],
        if (estimate.status == 'needs_customer_action') ...[
          const SizedBox(height: AppSpacing.medium),
          _PhotoCorrectionCard(estimate: estimate),
        ],
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.bodyPaintDamage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        for (final damage in estimate.damages)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.small),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: damage.isHighRisk
                    ? Theme.of(context).colorScheme.errorContainer
                    : AppColors.serviceRoseSoft,
                child: Icon(
                  damage.isHighRisk
                      ? Icons.warning_amber_rounded
                      : Icons.format_paint_outlined,
                  color: damage.isHighRisk
                      ? Theme.of(context).colorScheme.error
                      : AppColors.serviceRose,
                ),
              ),
              title: Text(damage.panelLabel),
              subtitle: Text(
                '${damage.damageTypeLabel} - ${damage.severity}',
              ),
            ),
          ),
        if (estimate.timeline.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.bodyPaintTimeline,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0;
                    index < estimate.timeline.length;
                    index++) ...[
                  ListTile(
                    leading: const Icon(Icons.radio_button_checked_rounded),
                    title: Text(estimate.timeline[index].title),
                    subtitle: Text(estimate.timeline[index].description),
                    trailing: estimate.timeline[index].createdAt == null
                        ? null
                        : Text(
                            DateFormat(
                              'dd MMM',
                              Localizations.localeOf(context).languageCode,
                            ).format(
                                estimate.timeline[index].createdAt!.toLocal()),
                          ),
                  ),
                  if (index < estimate.timeline.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
        if (mutation.hasError) ...[
          const SizedBox(height: AppSpacing.medium),
          Text(
            l10n.errorGeneral,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        if (estimate.allows('accept'))
          FilledButton.icon(
            onPressed: mutation.isLoading ? null : () => _accept(context, ref),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.bodyPaintAccept),
          ),
        if (estimate.allows('decline')) ...[
          const SizedBox(height: AppSpacing.small),
          OutlinedButton(
            onPressed: mutation.isLoading ? null : () => _decline(context, ref),
            child: Text(l10n.bodyPaintDecline),
          ),
        ],
        if (estimate.allows('request_booking'))
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.serviceRose,
            ),
            onPressed: mutation.isLoading
                ? null
                : () => context.push(bodyPaintBookingPath(estimate.id)),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(l10n.bodyPaintRequestBooking),
          ),
        if (estimate.bookingRoute != null) ...[
          const SizedBox(height: AppSpacing.small),
          OutlinedButton.icon(
            onPressed: () => context.push(
              estimate.bookingRoute ??
                  toyotaServiceBookingPath(estimate.bookingId!),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(l10n.viewBookingDetail),
          ),
        ],
      ],
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(bodyPaintMutationProvider.notifier)
        .decide(estimate.id, 'accept');
    if (!context.mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.bodyPaintAccept)),
    );
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bodyPaintDecline),
        content: TextField(
          controller: reason,
          maxLength: 2000,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(labelText: l10n.bodyPaintDeclineReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.bodyPaintDecline),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      reason.dispose();
      return;
    }
    await ref.read(bodyPaintMutationProvider.notifier).decide(
          estimate.id,
          'decline',
          reason: reason.text,
        );
    reason.dispose();
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.estimate});

  final BodyPaintEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.serviceRoseSoft,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.format_paint_rounded,
                  color: AppColors.serviceRose,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    estimate.referenceNo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(label: Text(estimate.statusLabel)),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(estimate.vehicle?.displayName ?? l10n.bodyPaintVehicle),
            if (estimate.location != null)
              Text(
                estimate.location!.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.bodyPaintPhysicalInspection,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BodyPaintResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final date = result.validUntil == null
        ? null
        : DateFormat(
            'dd MMM yyyy',
            Localizations.localeOf(context).languageCode,
          ).format(result.validUntil!.toLocal());
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyPaintEstimateResult,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.small),
            FittedBox(
              child: Text(
                '${money.format(result.low)} - ${money.format(result.high)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.serviceRose,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              '${l10n.bodyPaintVersion} ${result.version} - '
              '${l10n.bodyPaintDuration} ${result.minDays}-'
              '${result.maxDays} ${l10n.bodyPaintDays}',
            ),
            if (date != null) Text('${l10n.bodyPaintValidUntil} $date'),
            const Divider(height: AppSpacing.xLarge),
            for (final item in result.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.build_outlined, size: AppIconSize.medium),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.panelLabel} - ${item.workTypeLabel}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            '${money.format(item.totalLow)} - '
                            '${money.format(item.totalHigh)}',
                          ),
                          if (item.recommendation?.isNotEmpty == true)
                            Text(
                              item.recommendation!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (result.assumptions.isNotEmpty) ...[
              Text(
                l10n.bodyPaintAssumptions,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              for (final assumption in result.assumptions)
                Text('- $assumption'),
            ],
            const SizedBox(height: AppSpacing.medium),
            Text(
              result.disclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCorrectionCard extends ConsumerWidget {
  const _PhotoCorrectionCard({required this.estimate});

  final BodyPaintEstimate estimate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mutation = ref.watch(bodyPaintMutationProvider);
    final rejected = <({BodyPaintPhoto photo, String? damageId})>[
      for (final damage in estimate.damages)
        for (final photo in damage.photos)
          if (photo.isRejected) (photo: photo, damageId: damage.id),
      for (final photo in estimate.contextPhotos)
        if (photo.isRejected) (photo: photo, damageId: null),
    ];
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bodyPaintRequestPhotos,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.small),
            for (final item in rejected)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.broken_image_outlined),
                title: Text(
                  item.photo.rejectionReason ?? l10n.bodyPaintReplacePhoto,
                ),
                trailing: TextButton(
                  onPressed: mutation.isLoading
                      ? null
                      : () => ref
                          .read(bodyPaintMutationProvider.notifier)
                          .replacePhoto(
                            estimate.id,
                            photoType:
                                item.damageId == null ? 'context' : 'close',
                            damageId: item.damageId,
                          ),
                  child: Text(l10n.bodyPaintReplacePhoto),
                ),
              ),
            const SizedBox(height: AppSpacing.small),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: mutation.isLoading
                    ? null
                    : () => ref
                        .read(bodyPaintMutationProvider.notifier)
                        .resubmit(estimate.id),
                child: Text(l10n.bodyPaintResubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BodyPaintBookingScreen extends ConsumerStatefulWidget {
  const BodyPaintBookingScreen({required this.estimateId, super.key});

  final String estimateId;

  @override
  ConsumerState<BodyPaintBookingScreen> createState() =>
      _BodyPaintBookingScreenState();
}

class _BodyPaintBookingScreenState
    extends ConsumerState<BodyPaintBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaint = TextEditingController();
  final _mileage = TextEditingController();
  ToyotaServiceSlot? _primary;
  ToyotaServiceSlot? _alternative;
  var _contactChannel = 'whatsapp';
  var _consent = false;
  var _initialized = false;

  @override
  void dispose() {
    _complaint.dispose();
    _mileage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final estimate = ref.watch(bodyPaintEstimateProvider(widget.estimateId));
    final options = ref.watch(bodyPaintOptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintBookingTitle)),
      body: SafeArea(
        child: estimate.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _BodyPaintError(
            onRetry: () => ref.invalidate(
              bodyPaintEstimateProvider(widget.estimateId),
            ),
          ),
          data: (value) {
            if (!_initialized) {
              _mileage.text = '${value.vehicle?.mileage ?? 0}';
              _complaint.text = value.damages
                  .map((damage) => '${damage.panelLabel}: '
                      '${damage.damageTypeLabel}')
                  .join(', ');
              _initialized = true;
            }
            return options.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _BodyPaintError(
                onRetry: () => ref.invalidate(bodyPaintOptionsProvider),
              ),
              data: (catalog) {
                final serviceTypeId = catalog.serviceTypeId;
                if (value.location == null || serviceTypeId == null) {
                  return _BodyPaintError(
                    onRetry: () => ref.invalidate(bodyPaintOptionsProvider),
                  );
                }
                final availability = ref.watch(
                  bodyPaintAvailabilityProvider(
                    BodyPaintAvailabilityQuery(
                      locationId: value.location!.id,
                      serviceTypeId: serviceTypeId,
                    ),
                  ),
                );
                return availability.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _BodyPaintError(
                    onRetry: () => ref.invalidate(
                      bodyPaintAvailabilityProvider(
                        BodyPaintAvailabilityQuery(
                          locationId: value.location!.id,
                          serviceTypeId: serviceTypeId,
                        ),
                      ),
                    ),
                  ),
                  data: (slots) => _form(value, slots.slots),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _form(
    BodyPaintEstimate estimate,
    List<ToyotaServiceSlot> slots,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final mutation = ref.watch(bodyPaintMutationProvider);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          Text(
            estimate.referenceNo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(estimate.location?.name ?? ''),
          const SizedBox(height: AppSpacing.large),
          DropdownButtonFormField<ToyotaServiceSlot>(
            initialValue: _primary,
            decoration: InputDecoration(labelText: l10n.bodyPaintPrimarySlot),
            items: _slotItems(context, slots, disabled: _alternative),
            validator: (value) => value == null ? l10n.errorGeneral : null,
            onChanged: (value) => setState(() => _primary = value),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<ToyotaServiceSlot>(
            initialValue: _alternative,
            decoration:
                InputDecoration(labelText: l10n.bodyPaintAlternativeSlot),
            items: _slotItems(context, slots, disabled: _primary),
            validator: (value) => value == null ? l10n.errorGeneral : null,
            onChanged: (value) => setState(() => _alternative = value),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _mileage,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.bodyPaintMileage),
            validator: (value) {
              final number = int.tryParse(value ?? '');
              return number == null || number < 0 ? l10n.errorGeneral : null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _complaint,
            minLines: 2,
            maxLines: 4,
            maxLength: 3000,
            decoration: InputDecoration(labelText: l10n.bodyPaintComplaint),
            validator: (value) =>
                (value?.trim().length ?? 0) < 5 ? l10n.errorGeneral : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: _contactChannel,
            decoration: InputDecoration(labelText: l10n.creditContactChannel),
            items: [
              DropdownMenuItem(
                value: 'whatsapp',
                child: Text(l10n.creditContactWhatsapp),
              ),
              DropdownMenuItem(
                value: 'phone',
                child: Text(l10n.creditContactPhone),
              ),
              DropdownMenuItem(
                value: 'email',
                child: Text(l10n.creditContactEmail),
              ),
            ],
            onChanged: (value) =>
                setState(() => _contactChannel = value ?? 'whatsapp'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _consent,
            title: Text(l10n.bodyPaintBookingConsent),
            onChanged: (value) => setState(() => _consent = value ?? false),
          ),
          const SizedBox(height: AppSpacing.large),
          FilledButton.icon(
            onPressed: mutation.isLoading ? null : () => _submit(estimate),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(l10n.bodyPaintRequestBooking),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BodyPaintEstimate estimate) async {
    if (!(_formKey.currentState?.validate() ?? false) ||
        !_consent ||
        _primary == null ||
        _alternative == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bodyPaintCompleteFields),
        ),
      );
      return;
    }
    final bookingId =
        await ref.read(bodyPaintMutationProvider.notifier).requestBooking(
              estimate,
              primary: _primary!,
              alternative: _alternative!,
              complaint: _complaint.text,
              mileage: int.parse(_mileage.text),
              contactChannel: _contactChannel,
            );
    if (!mounted || bookingId == null) return;
    context.go(toyotaServiceBookingPath(bookingId));
  }

  List<DropdownMenuItem<ToyotaServiceSlot>> _slotItems(
    BuildContext context,
    List<ToyotaServiceSlot> slots, {
    ToyotaServiceSlot? disabled,
  }) =>
      [
        for (final slot in slots)
          DropdownMenuItem(
            value: slot,
            enabled: slot != disabled,
            child: Text(
              '${DateFormat('dd MMM', Localizations.localeOf(context).languageCode).format(DateTime.parse(slot.date))} '
              '${slot.timeWindow}',
            ),
          ),
      ];
}

class _BodyPaintError extends StatelessWidget {
  const _BodyPaintError({required this.onRetry});

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
            const Icon(Icons.sync_problem_rounded, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.bodyPaintLoadFailed, textAlign: TextAlign.center),
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
