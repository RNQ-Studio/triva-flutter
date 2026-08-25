import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/body_paint_models.dart';
import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../../toyota_service/presentation/toyota_service_paths.dart';
import '../body_paint_controller.dart';
import '../body_paint_paths.dart';

class BodyPaintIntakeScreen extends ConsumerStatefulWidget {
  const BodyPaintIntakeScreen({
    super.key,
    this.sourceAppraisalId,
    this.sourceVehicleId,
  });

  final String? sourceAppraisalId;
  final String? sourceVehicleId;

  @override
  ConsumerState<BodyPaintIntakeScreen> createState() =>
      _BodyPaintIntakeScreenState();
}

class _BodyPaintIntakeScreenState extends ConsumerState<BodyPaintIntakeScreen> {
  final _notes = TextEditingController();
  final _insuranceProvider = TextEditingController();
  var _initialized = false;
  var _sourceInitialized = false;

  @override
  void dispose() {
    _notes.dispose();
    _insuranceProvider.dispose();
    super.dispose();
  }

  Future<void> _addVehicle() async {
    final vehicle = await context.push<ToyotaServiceVehicle>(
      toyotaServiceAddVehicleSelectionPath,
    );
    if (vehicle == null || !mounted) return;
    await ref.read(bodyPaintFlowProvider.notifier).selectVehicle(vehicle);
    ref.invalidate(bodyPaintVehiclesProvider);
  }

  void _initializeSource(List<ToyotaServiceVehicle> vehicles) {
    final appraisalId = widget.sourceAppraisalId;
    if (_sourceInitialized || appraisalId == null) return;
    _sourceInitialized = true;
    ToyotaServiceVehicle? sourceVehicle;
    for (final vehicle in vehicles) {
      if (vehicle.id == widget.sourceVehicleId) {
        sourceVehicle = vehicle;
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(bodyPaintFlowProvider.notifier).initializeSource(
            appraisalId: appraisalId,
            vehicle: sourceVehicle,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(bodyPaintFlowProvider);
    final options = ref.watch(bodyPaintOptionsProvider);
    final vehicles = ref.watch(bodyPaintVehiclesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintFlowTitle)),
      body: SafeArea(
        child: flow.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _LoadError(
            onRetry: () => ref.invalidate(bodyPaintFlowProvider),
          ),
          data: (state) {
            if (!_initialized) {
              _notes.text = state.draft.notes;
              _insuranceProvider.text = state.draft.insuranceProvider;
              _initialized = true;
            }
            return options.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _LoadError(
                onRetry: () => ref.invalidate(bodyPaintOptionsProvider),
              ),
              data: (catalog) => vehicles.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _LoadError(
                  onRetry: () => ref.invalidate(bodyPaintVehiclesProvider),
                ),
                data: (vehicleItems) {
                  _initializeSource(vehicleItems);
                  return _content(state, catalog, vehicleItems);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(
    BodyPaintFlowState state,
    BodyPaintOptions options,
    List<ToyotaServiceVehicle> vehicles,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(bodyPaintFlowProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.medium,
        AppSpacing.large,
        AppSpacing.xLarge,
      ),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_paint_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bodyPaintFlowTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(l10n.bodyPaintFlowSubtitle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        _SectionTitle(number: 1, title: l10n.bodyPaintVehicle),
        const SizedBox(height: AppSpacing.small),
        if (vehicles.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.bookingNoVehicles,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(l10n.bookingNoVehiclesDescription),
                  const SizedBox(height: AppSpacing.medium),
                  OutlinedButton.icon(
                    key: const Key('body-paint-add-vehicle'),
                    onPressed: state.isSubmitting ? null : _addVehicle,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addVehicle),
                  ),
                ],
              ),
            ),
          )
        else ...[
          DropdownButtonFormField<ToyotaServiceVehicle>(
            key: ValueKey('body-paint-vehicle-${state.draft.vehicle?.id}'),
            initialValue: state.draft.vehicle,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.bodyPaintVehicle),
            items: [
              for (final vehicle in vehicles)
                DropdownMenuItem<ToyotaServiceVehicle>(
                  value: vehicle,
                  child: Text(
                    '${vehicle.displayName} - ${vehicle.licensePlate}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: state.isSubmitting
                ? null
                : (vehicle) {
                    if (vehicle != null) controller.selectVehicle(vehicle);
                  },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('body-paint-add-another-vehicle'),
              onPressed: state.isSubmitting ? null : _addVehicle,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addVehicle),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        DropdownButtonFormField<ToyotaServiceLocation>(
          key: ValueKey('body-paint-location-${state.draft.location?.id}'),
          initialValue: state.draft.location,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.bodyPaintLocation),
          items: [
            for (final location in options.locations)
              DropdownMenuItem(
                value: location,
                child: Text(
                  '${location.name} - ${location.city}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: state.isSubmitting
              ? null
              : (location) {
                  if (location != null) controller.selectLocation(location);
                },
        ),
        const SizedBox(height: AppSpacing.xLarge),
        _SectionTitle(number: 2, title: l10n.bodyPaintDamage),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          l10n.bodyPaintRequirementNotice,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.medium),
        for (var index = 0; index < state.draft.damages.length; index++) ...[
          _DamageCard(
            index: index,
            damage: state.draft.damages[index],
            options: options,
            enabled: !state.isSubmitting && !state.isUploading,
          ),
          const SizedBox(height: AppSpacing.medium),
        ],
        OutlinedButton.icon(
          onPressed: state.draft.damages.length >= 9 ||
                  state.isSubmitting ||
                  state.isUploading
              ? null
              : controller.addDamage,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.bodyPaintAddDamage),
        ),
        const SizedBox(height: AppSpacing.large),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: state.draft.contextPhotoAssetId == null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : AppColors.accentSoft,
              child: Icon(
                state.draft.contextPhotoAssetId == null
                    ? Icons.add_a_photo_outlined
                    : Icons.check_rounded,
                color: state.draft.contextPhotoAssetId == null
                    ? null
                    : AppColors.accent,
              ),
            ),
            title: Text(l10n.bodyPaintContextPhoto),
            subtitle: Text(
              state.draft.contextPhotoName ?? l10n.bodyPaintChoosePhoto,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: state.isSubmitting || state.isUploading
                ? null
                : controller.pickContextPhoto,
          ),
        ),
        const SizedBox(height: AppSpacing.xLarge),
        _SectionTitle(number: 3, title: l10n.bodyPaintNotes),
        const SizedBox(height: AppSpacing.small),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 4,
          maxLength: 3000,
          decoration: InputDecoration(labelText: l10n.bodyPaintNotes),
          onChanged: controller.setNotes,
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.bodyPaintInsuranceQuestion,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.small),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(l10n.bodyPaintInsuranceNo),
            ),
            ButtonSegment(
              value: true,
              label: Text(l10n.bodyPaintInsuranceYes),
            ),
          ],
          selected: {state.draft.isInsured},
          onSelectionChanged: state.isSubmitting
              ? null
              : (selection) => controller.setInsured(selection.first),
        ),
        if (state.draft.isInsured) ...[
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _insuranceProvider,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: l10n.bodyPaintInsuranceProvider,
              helperText: l10n.bodyPaintInsuranceHint,
              helperMaxLines: 3,
            ),
            onChanged: controller.setInsuranceProvider,
          ),
        ],
        CheckboxListTile(
          value: state.draft.consent,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.bodyPaintConsent),
          onChanged: state.isSubmitting
              ? null
              : (value) => controller.setConsent(value ?? false),
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
          ),
          onPressed: state.isSubmitting || state.isUploading
              ? null
              : () => _submit(state),
          icon: state.isSubmitting
              ? const SizedBox.square(
                  dimension: AppIconSize.medium,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(
            state.isSubmitting
                ? l10n.bodyPaintSubmitting
                : l10n.bodyPaintSubmit,
          ),
        ),
      ],
    );
  }

  Future<void> _submit(BodyPaintFlowState state) async {
    final l10n = AppLocalizations.of(context)!;
    if (!state.draft.canSubmit) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.bodyPaintCompleteFields)),
        );
      return;
    }
    final estimate = await ref.read(bodyPaintFlowProvider.notifier).submit();
    if (!mounted || estimate == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.accent,
        ),
        title: Text(l10n.bodyPaintSubmittedTitle),
        content: Text(l10n.bodyPaintSubmittedDescription),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.bodyPaintViewEstimate),
          ),
        ],
      ),
    );
    if (mounted) context.go(bodyPaintEstimatePath(estimate.id));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
}

class _DamageCard extends ConsumerWidget {
  const _DamageCard({
    required this.index,
    required this.damage,
    required this.options,
    required this.enabled,
  });

  final int index;
  final BodyPaintDraftDamage damage;
  final BodyPaintOptions options;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(bodyPaintFlowProvider.notifier);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.bodyPaintDamage} ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: enabled
                      ? () => controller.removeDamage(damage.key)
                      : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('${damage.key}-panel-${damage.panelCode}'),
              initialValue: damage.panelCode.isEmpty ? null : damage.panelCode,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.bodyPaintPanel),
              items: [
                for (final item in options.panels)
                  DropdownMenuItem(value: item.value, child: Text(item.label)),
              ],
              onChanged: enabled
                  ? (value) => controller.updateDamage(
                        damage.key,
                        panelCode: value,
                      )
                  : null,
            ),
            const SizedBox(height: AppSpacing.small),
            DropdownButtonFormField<String>(
              key: ValueKey('${damage.key}-type-${damage.damageType}'),
              initialValue:
                  damage.damageType.isEmpty ? null : damage.damageType,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.bodyPaintDamageType),
              items: [
                for (final item in options.damageTypes)
                  DropdownMenuItem(
                    value: item.value,
                    child: Row(
                      children: [
                        Expanded(child: Text(item.label)),
                        if (item.isHighRisk)
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: AppIconSize.medium,
                          ),
                      ],
                    ),
                  ),
              ],
              onChanged: enabled
                  ? (value) => controller.updateDamage(
                        damage.key,
                        damageType: value,
                      )
                  : null,
            ),
            const SizedBox(height: AppSpacing.small),
            DropdownButtonFormField<String>(
              key: ValueKey('${damage.key}-severity-${damage.severity}'),
              initialValue: damage.severity,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.bodyPaintSeverity),
              items: [
                for (final item in options.severities)
                  DropdownMenuItem(value: item.value, child: Text(item.label)),
              ],
              onChanged: enabled
                  ? (value) => controller.updateDamage(
                        damage.key,
                        severity: value,
                      )
                  : null,
            ),
            const SizedBox(height: AppSpacing.small),
            TextFormField(
              initialValue: damage.note,
              maxLength: 1000,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.bodyPaintDamageNote),
              onChanged: enabled
                  ? (value) => controller.updateDamage(damage.key, note: value)
                  : null,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: damage.closePhotoAssetId == null
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : AppColors.accentSoft,
                child: Icon(
                  damage.closePhotoAssetId == null
                      ? Icons.add_a_photo_outlined
                      : Icons.check_rounded,
                  color: damage.closePhotoAssetId == null
                      ? null
                      : AppColors.accent,
                ),
              ),
              title: Text(l10n.bodyPaintClosePhoto),
              subtitle: Text(
                damage.closePhotoName ?? l10n.bodyPaintChoosePhoto,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap:
                  enabled ? () => controller.pickDamagePhoto(damage.key) : null,
            ),
          ],
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
