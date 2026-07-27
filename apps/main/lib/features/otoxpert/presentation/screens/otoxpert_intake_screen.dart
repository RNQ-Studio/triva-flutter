import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../../toyota_service/presentation/toyota_service_paths.dart';
import '../../domain/otoxpert_models.dart';
import '../otoxpert_controller.dart';
import '../otoxpert_paths.dart';

class OtoxpertIntakeScreen extends ConsumerStatefulWidget {
  const OtoxpertIntakeScreen({super.key});

  @override
  ConsumerState<OtoxpertIntakeScreen> createState() =>
      _OtoxpertIntakeScreenState();
}

class _OtoxpertIntakeScreenState extends ConsumerState<OtoxpertIntakeScreen> {
  final _detailsKey = GlobalKey<FormState>();
  final _mileage = TextEditingController();
  final _complaint = TextEditingController();
  final _lastService = TextEditingController();
  var _step = 0;
  var _detailsInitialized = false;
  var _symptoms = <String>{};
  ToyotaServiceSlot? _primarySlot;
  ToyotaServiceSlot? _alternativeSlot;
  var _pickupDelivery = false;
  var _contactChannel = 'whatsapp';
  var _partnerConsent = false;

  @override
  void dispose() {
    _mileage.dispose();
    _complaint.dispose();
    _lastService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(otoxpertFlowProvider);
    final options = ref.watch(otoxpertOptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otoxpertFlowTitle)),
      body: SafeArea(
        child: flow.when(
          data: (state) {
            _initializeDetails(state.draft);
            return options.when(
              data: (value) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Stepper(
                    currentStep: _step,
                    onStepTapped: (value) {
                      if (value <= _furthestStep(state.draft)) {
                        setState(() => _step = value);
                      }
                    },
                    controlsBuilder: (context, details) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.large),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: state.isSubmitting || state.isUploading
                                  ? null
                                  : () => _continue(state, value),
                              child: state.isSubmitting
                                  ? const SizedBox.square(
                                      dimension: AppIconSize.medium,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _step == 4
                                          ? l10n.submitServiceRequest
                                          : l10n.next,
                                    ),
                            ),
                          ),
                          if (_step > 0) ...[
                            const SizedBox(width: AppSpacing.small),
                            TextButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () => setState(() => _step--),
                              child: Text(
                                MaterialLocalizations.of(context)
                                    .backButtonTooltip,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    steps: [
                      Step(
                        title: Text(l10n.bookingStepVehicle),
                        isActive: _step >= 0,
                        state: state.draft.vehicle == null
                            ? StepState.indexed
                            : StepState.complete,
                        content: _VehicleStep(draft: state.draft),
                      ),
                      Step(
                        title: Text(l10n.bookingStepService),
                        isActive: _step >= 1,
                        state: state.draft.service == null
                            ? StepState.indexed
                            : StepState.complete,
                        content: _WorkshopServiceStep(draft: state.draft),
                      ),
                      Step(
                        title: Text(l10n.serviceDetailsTitle),
                        isActive: _step >= 2,
                        state: state.draft.complaint.trim().length >= 5 &&
                                state.draft.symptomCodes.isNotEmpty
                            ? StepState.complete
                            : StepState.indexed,
                        content: _detailsStep(state, value),
                      ),
                      Step(
                        title: Text(l10n.bookingStepSchedule),
                        isActive: _step >= 3,
                        state: state.draft.primarySlot != null &&
                                state.draft.alternativeSlot != null
                            ? StepState.complete
                            : StepState.indexed,
                        content: _scheduleStep(state.draft),
                      ),
                      Step(
                        title: Text(l10n.bookingStepReview),
                        isActive: _step >= 4,
                        content: _reviewStep(state.draft, value),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _LoadError(
                onRetry: () => ref.invalidate(otoxpertOptionsProvider),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _LoadError(
            onRetry: () => ref.invalidate(otoxpertFlowProvider),
          ),
        ),
      ),
    );
  }

  Widget _detailsStep(OtoxpertFlowState state, OtoxpertOptions options) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _detailsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.serviceDetailsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _mileage,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.currentMileage),
            validator: (value) {
              final parsed = int.tryParse(value ?? '');
              return parsed == null || parsed < 0 || parsed > 5000000
                  ? l10n.bookingIncompleteError
                  : null;
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _lastService,
            readOnly: true,
            decoration: InputDecoration(
              labelText: l10n.otoxpertLastServiceDate,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
            onTap: _pickLastServiceDate,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _complaint,
            minLines: 3,
            maxLines: 6,
            maxLength: 3000,
            decoration: InputDecoration(
              labelText: l10n.complaint,
              hintText: l10n.complaintHint,
              alignLabelWithHint: true,
            ),
            validator: (value) => (value?.trim().length ?? 0) < 5
                ? l10n.bookingIncompleteError
                : null,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.otoxpertSymptoms,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.xSmall,
            children: [
              for (final symptom in options.symptoms)
                FilterChip(
                  label: Text(symptom.label),
                  selected: _symptoms.contains(symptom.value),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _symptoms.add(symptom.value)
                        : _symptoms.remove(symptom.value);
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.supportingPhotoOptional,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              OutlinedButton.icon(
                onPressed: state.isUploading ||
                        state.draft.photos.length >= options.maxPhotos
                    ? null
                    : () => ref
                        .read(otoxpertFlowProvider.notifier)
                        .addPhotos(options.maxPhotos),
                icon: state.isUploading
                    ? const SizedBox.square(
                        dimension: AppIconSize.medium,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.addSupportingPhoto),
              ),
            ],
          ),
          for (final photo in state.draft.photos)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: Text(photo.name),
              trailing: IconButton(
                tooltip: l10n.removeSupportingPhoto,
                onPressed: () => ref
                    .read(otoxpertFlowProvider.notifier)
                    .removePhoto(photo.assetId),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          Text(
            l10n.supportingPhotoPrivacy,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.error != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scheduleStep(OtoxpertDraft draft) {
    final l10n = AppLocalizations.of(context)!;
    if (draft.workshop == null || draft.service == null) {
      return Text(l10n.bookingIncompleteError);
    }
    final query = (
      workshopId: draft.workshop!.id,
      serviceId: draft.service!.id,
    );
    final availability = ref.watch(otoxpertAvailabilityProvider(query));
    return availability.when(
      data: (value) {
        if (value.slots.isEmpty) {
          return _InlineEmpty(
            title: l10n.availabilityEmpty,
            description: l10n.availabilityEmptyDescription,
          );
        }
        final primary =
            value.slots.contains(_primarySlot) ? _primarySlot : null;
        final alternative =
            value.slots.contains(_alternativeSlot) ? _alternativeSlot : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.schedulePreferenceDescription),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<ToyotaServiceSlot>(
              initialValue: primary,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.primaryPreference),
              items: [
                for (final slot in value.slots)
                  DropdownMenuItem(
                    value: slot,
                    child: Text(_slotLabel(slot)),
                  ),
              ],
              onChanged: (slot) => setState(() => _primarySlot = slot),
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<ToyotaServiceSlot>(
              initialValue: alternative,
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: l10n.alternativePreference),
              items: [
                for (final slot in value.slots)
                  DropdownMenuItem(
                    value: slot,
                    enabled: slot != _primarySlot,
                    child: Text(_slotLabel(slot)),
                  ),
              ],
              onChanged: (slot) => setState(() => _alternativeSlot = slot),
            ),
            const SizedBox(height: AppSpacing.medium),
            _Notice(text: l10n.preferenceNotSlot),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => _LoadError(
        compact: true,
        onRetry: () => ref.invalidate(otoxpertAvailabilityProvider(query)),
      ),
    );
  }

  Widget _reviewStep(OtoxpertDraft draft, OtoxpertOptions options) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Notice(text: options.notice),
        const SizedBox(height: AppSpacing.medium),
        _SummaryRow(
            label: l10n.reviewVehicle, value: draft.vehicle?.displayName),
        _SummaryRow(label: l10n.location, value: draft.workshop?.name),
        _SummaryRow(label: l10n.service, value: draft.service?.name),
        _SummaryRow(
          label: l10n.primarySchedule,
          value:
              draft.primarySlot == null ? null : _slotLabel(draft.primarySlot!),
        ),
        _SummaryRow(
          label: l10n.alternativeSchedule,
          value: draft.alternativeSlot == null
              ? null
              : _slotLabel(draft.alternativeSlot!),
        ),
        if (draft.service?.indicativePrice != null)
          _PriceCard(price: draft.service!.indicativePrice!),
        const SizedBox(height: AppSpacing.small),
        DropdownButtonFormField<String>(
          initialValue: _contactChannel,
          decoration: InputDecoration(labelText: l10n.contactChannel),
          items: [
            for (final channel in options.contactChannels)
              DropdownMenuItem(
                value: channel.value,
                child: Text(channel.label),
              ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _contactChannel = value);
          },
        ),
        if (draft.workshop?.supportsPickupDelivery == true)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _pickupDelivery,
            title: Text(l10n.otoxpertPickupDelivery),
            onChanged: (value) => setState(() => _pickupDelivery = value),
          ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _partnerConsent,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.otoxpertPartnerConsent),
          onChanged: (value) =>
              setState(() => _partnerConsent = value ?? false),
        ),
      ],
    );
  }

  Future<void> _continue(
    OtoxpertFlowState state,
    OtoxpertOptions options,
  ) async {
    final notifier = ref.read(otoxpertFlowProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    if (_step == 0 && state.draft.vehicle == null) {
      _showIncomplete(l10n);
      return;
    }
    if (_step == 1 &&
        (state.draft.workshop == null || state.draft.service == null)) {
      _showIncomplete(l10n);
      return;
    }
    if (_step == 2) {
      if (!(_detailsKey.currentState?.validate() ?? false) ||
          _symptoms.isEmpty) {
        _showIncomplete(l10n);
        return;
      }
      await notifier.saveDetails(
        mileage: int.parse(_mileage.text),
        complaint: _complaint.text,
        symptoms: _symptoms.toList(growable: false),
        lastServiceDate: _lastService.text.isEmpty ? null : _lastService.text,
      );
    }
    if (_step == 3) {
      if (_primarySlot == null ||
          _alternativeSlot == null ||
          _primarySlot == _alternativeSlot) {
        _showIncomplete(l10n);
        return;
      }
      await notifier.saveSchedule(
        primary: _primarySlot!,
        alternative: _alternativeSlot!,
      );
    }
    if (_step < 4) {
      if (mounted) setState(() => _step++);
      return;
    }
    if (!_partnerConsent) {
      _showIncomplete(l10n);
      return;
    }
    await notifier.saveReview(
      pickupDeliveryRequested: _pickupDelivery,
      contactChannel: _contactChannel,
      partnerConsent: _partnerConsent,
    );
    final booking = await notifier.submit(options);
    if (!mounted) return;
    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookingMutationFailed)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.otoxpertRequestSubmitted)),
    );
    context.go(otoxpertBookingPath(booking.id));
  }

  Future<void> _pickLastServiceDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      initialDate: DateTime.tryParse(_lastService.text) ?? now,
    );
    if (selected == null) return;
    _lastService.text = _date(selected);
  }

  void _initializeDetails(OtoxpertDraft draft) {
    if (_detailsInitialized) return;
    _detailsInitialized = true;
    _mileage.text = draft.currentMileage?.toString() ?? '';
    _complaint.text = draft.complaint;
    _lastService.text = draft.lastServiceDate ?? '';
    _symptoms = draft.symptomCodes.toSet();
    _primarySlot = draft.primarySlot;
    _alternativeSlot = draft.alternativeSlot;
    _pickupDelivery = draft.pickupDeliveryRequested;
    _contactChannel = draft.contactChannel;
    _partnerConsent = draft.partnerConsent;
  }

  int _furthestStep(OtoxpertDraft draft) {
    if (draft.vehicle == null) return 0;
    if (draft.workshop == null || draft.service == null) return 1;
    if (draft.complaint.trim().length < 5 || draft.symptomCodes.isEmpty) {
      return 2;
    }
    if (draft.primarySlot == null || draft.alternativeSlot == null) return 3;
    return 4;
  }

  void _showIncomplete(AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.bookingIncompleteError)));
  }

  String _slotLabel(ToyotaServiceSlot slot) =>
      '${slot.date} • ${slot.timeWindow}';

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _VehicleStep extends ConsumerWidget {
  const _VehicleStep({required this.draft});

  final OtoxpertDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vehicles = ref.watch(otoxpertVehiclesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.otoxpertSelectVehicleDescription),
        const SizedBox(height: AppSpacing.medium),
        vehicles.when(
          data: (items) => items.isEmpty
              ? _InlineEmpty(
                  title: l10n.bookingNoVehicles,
                  description: l10n.bookingNoVehiclesDescription,
                  action: OutlinedButton.icon(
                    onPressed: () => context.push(toyotaServiceAddVehiclePath),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addVehicle),
                  ),
                )
              : Column(
                  children: [
                    for (final vehicle in items)
                      _SelectionCard(
                        selected: vehicle.id == draft.vehicle?.id,
                        title: vehicle.displayName,
                        subtitle: '${vehicle.year} • ${vehicle.licensePlate}',
                        icon: Icons.directions_car_outlined,
                        onTap: () => ref
                            .read(otoxpertFlowProvider.notifier)
                            .selectVehicle(vehicle),
                      ),
                  ],
                ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => _LoadError(
            compact: true,
            onRetry: () => ref.invalidate(otoxpertVehiclesProvider),
          ),
        ),
      ],
    );
  }
}

class _WorkshopServiceStep extends ConsumerWidget {
  const _WorkshopServiceStep({required this.draft});

  final OtoxpertDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (draft.vehicle == null) return Text(l10n.bookingIncompleteError);
    final workshops = ref.watch(otoxpertWorkshopsProvider(draft.vehicle!.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.otoxpertChooseWorkshop,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.small),
        workshops.when(
          data: (items) => items.isEmpty
              ? _InlineEmpty(
                  title: l10n.otoxpertWorkshopEmpty,
                  description: l10n.availabilityEmptyDescription,
                )
              : Column(
                  children: [
                    for (final workshop in items)
                      _SelectionCard(
                        selected: workshop.id == draft.workshop?.id,
                        title: workshop.name,
                        subtitle: '${workshop.address}\n${workshop.city}',
                        icon: Icons.home_repair_service_outlined,
                        onTap: () => ref
                            .read(otoxpertFlowProvider.notifier)
                            .selectWorkshop(workshop),
                      ),
                  ],
                ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => _LoadError(
            compact: true,
            onRetry: () =>
                ref.invalidate(otoxpertWorkshopsProvider(draft.vehicle!.id)),
          ),
        ),
        if (draft.workshop != null) ...[
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.otoxpertChooseService,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          _Services(draft: draft),
        ],
      ],
    );
  }
}

class _Services extends ConsumerWidget {
  const _Services({required this.draft});

  final OtoxpertDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final provider = otoxpertServicesProvider(draft.workshop!.id);
    return ref.watch(provider).when(
          data: (items) => items.isEmpty
              ? _InlineEmpty(
                  title: l10n.serviceTypesEmpty,
                  description: l10n.serviceTypesEmptyDescription,
                )
              : Column(
                  children: [
                    for (final service in items)
                      _SelectionCard(
                        selected: service.id == draft.service?.id,
                        title: service.name,
                        subtitle: service.indicativePrice == null
                            ? service.description
                            : '${service.description}\n'
                                '${l10n.otoxpertIndicativePrice}: '
                                '${_formatPrice(context, service.indicativePrice!)}',
                        icon: Icons.build_outlined,
                        onTap: () => ref
                            .read(otoxpertFlowProvider.notifier)
                            .selectService(service),
                      ),
                  ],
                ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => _LoadError(
            compact: true,
            onRetry: () => ref.invalidate(provider),
          ),
        );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      color: selected ? colors.primaryContainer : null,
      child: ListTile(
        leading: Icon(icon, color: AppColors.serviceViolet),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
          color: selected ? colors.primary : null,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.price});

  final OtoxpertPrice price;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: AppColors.serviceVioletSoft,
      margin: const EdgeInsets.only(top: AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.otoxpertIndicativePrice,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.serviceViolet,
                  ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              _formatPrice(context, price),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              price.disclaimer.isEmpty
                  ? l10n.otoxpertPriceDisclaimer
                  : price.disclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String? value;

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
            Expanded(
              child: Text(value ?? '—'),
            ),
          ],
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: AppRadius.medium,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded),
              const SizedBox(width: AppSpacing.small),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.title,
    required this.description,
    this.action,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: AppIconSize.service),
            const SizedBox(height: AppSpacing.small),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.medium),
              action!,
            ],
          ],
        ),
      );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry, this.compact = false});

  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          compact ? AppSpacing.medium : AppSpacing.xLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem_rounded),
            const SizedBox(height: AppSpacing.small),
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

String _formatPrice(BuildContext context, OtoxpertPrice price) {
  final formatter = NumberFormat.currency(
    locale: Localizations.localeOf(context).toLanguageTag(),
    symbol: 'Rp',
    decimalDigits: 0,
  );
  final minimum = formatter.format(price.minimumAmount);
  if (price.type == 'range' && price.maximumAmount != null) {
    return '$minimum – ${formatter.format(price.maximumAmount)}';
  }
  return minimum;
}
