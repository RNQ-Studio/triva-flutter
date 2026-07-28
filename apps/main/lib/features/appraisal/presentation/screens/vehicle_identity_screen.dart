import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';

class VehicleIdentityScreen extends ConsumerStatefulWidget {
  const VehicleIdentityScreen({super.key});

  @override
  ConsumerState<VehicleIdentityScreen> createState() =>
      _VehicleIdentityScreenState();
}

class _VehicleIdentityScreenState extends ConsumerState<VehicleIdentityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _variant = TextEditingController();
  VehicleMakeOption? _selectedMake;
  VehicleModelOption? _selectedModel;
  VehicleVariantOption? _selectedVariant;
  int? _selectedYear;
  bool _manualVariant = false;
  bool _restoreVariantFromDraft = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _variant.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final make = _selectedMake;
    final model = _selectedModel;
    final selectedVariant = _selectedVariant;
    final year = _selectedYear;
    if (make == null || model == null || year == null) return;
    final variant = selectedVariant?.name ?? _variant.text.trim();
    if (variant.isEmpty) return;

    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveIdentity(
          makeId: make.id,
          modelId: model.id,
          make: make.name,
          model: model.name,
          variantId: selectedVariant?.id,
          variant: variant,
          year: year,
          variantTransmission: selectedVariant?.transmission,
          variantFuelType: selectedVariant?.fuelType,
        );
    if (mounted) context.push(appraisalDetailsPath);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(appraisalFlowProvider);
    final value = flow.value;
    if (value == null) return const AppraisalLoading();

    if (!_initialized) {
      _initialized = true;
      _variant.text = value.draft.variant;
      _selectedYear = value.draft.year;
      _manualVariant =
          value.draft.variantId == null && value.draft.variant.isNotEmpty;
      _restoreVariantFromDraft = value.draft.variantId != null;
    }

    final makes = ref.watch(vehicleMakesProvider);
    makes.whenData((items) {
      if (_selectedMake != null || value.draft.makeId == null) return;
      for (final item in items) {
        if (item.id == value.draft.makeId) {
          _selectedMake = item;
          break;
        }
      }
    });

    final make = _selectedMake;
    final models =
        make == null ? null : ref.watch(vehicleModelsProvider(make.id));
    models?.whenData((items) {
      if (_selectedModel != null) return;
      for (final item in items) {
        final matchesId =
            value.draft.modelId != null && item.id == value.draft.modelId;
        final matchesLegacyName = value.draft.modelId == null &&
            item.name.toLowerCase() == value.draft.model.toLowerCase();
        if (matchesId || matchesLegacyName) {
          _selectedModel = item;
          break;
        }
      }
    });

    final model = _selectedModel;
    final year = _selectedYear;
    final variantSelection =
        model == null || year == null ? null : (modelId: model.id, year: year);
    final variants = variantSelection == null
        ? null
        : ref.watch(vehicleVariantsProvider(variantSelection));
    variants?.whenData((items) {
      if (!_restoreVariantFromDraft) return;
      _restoreVariantFromDraft = false;
      for (final item in items) {
        if (item.id == value.draft.variantId) {
          _selectedVariant = item;
          _variant.text = item.name;
          return;
        }
      }
      if (value.draft.variant.isNotEmpty) {
        _manualVariant = true;
      }
    });

    return AppraisalFlowScaffold(
      step: 1,
      title: l10n.vehicleIdentityTitle,
      description: l10n.vehicleIdentityDescription,
      primaryLabel: l10n.next,
      primaryBusy: _saving,
      onPrimary: _continue,
      body: AppraisalCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              makes.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _MasterDataMessage(
                      icon: Icons.directions_car_outlined,
                      message: l10n.vehicleMakeEmpty,
                      onRetry: () => ref.invalidate(vehicleMakesProvider),
                    );
                  }
                  return _VehicleMakeField(
                    items: items,
                    value: _selectedMake,
                    onChanged: (selected) {
                      if (selected.id == _selectedMake?.id) return;
                      setState(() {
                        _selectedMake = selected;
                        _selectedModel = null;
                        _selectedVariant = null;
                        _selectedYear = null;
                        _manualVariant = false;
                        _restoreVariantFromDraft = false;
                        _variant.clear();
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => _MasterDataMessage(
                  icon: Icons.cloud_off_outlined,
                  message: l10n.vehicleMakeLoadError,
                  onRetry: () => ref.invalidate(vehicleMakesProvider),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              _VehicleModelField(
                make: make,
                models: models,
                value: _selectedModel,
                onChanged: (selected) {
                  if (selected.id == _selectedModel?.id) return;
                  setState(() {
                    _selectedModel = selected;
                    _selectedVariant = null;
                    _selectedYear = null;
                    _manualVariant = false;
                    _restoreVariantFromDraft = false;
                    _variant.clear();
                  });
                },
                onRetry: make == null
                    ? null
                    : () => ref.invalidate(vehicleModelsProvider(make.id)),
              ),
              const SizedBox(height: AppSpacing.medium),
              _VehicleYearField(
                value: _selectedYear,
                onChanged: (selected) {
                  if (selected == _selectedYear) return;
                  setState(() {
                    _selectedYear = selected;
                    _selectedVariant = null;
                    _manualVariant = false;
                    _restoreVariantFromDraft = false;
                    _variant.clear();
                  });
                },
              ),
              const SizedBox(height: AppSpacing.medium),
              _VehicleVariantField(
                model: model,
                year: year,
                variants: variants,
                value: _selectedVariant,
                manual: _manualVariant,
                manualController: _variant,
                onChanged: (selected) {
                  setState(() {
                    _selectedVariant = selected;
                    _manualVariant = false;
                    _variant.text = selected.name;
                  });
                },
                onManual: () {
                  setState(() {
                    _selectedVariant = null;
                    _manualVariant = true;
                    _variant.clear();
                  });
                },
                onMaster: () {
                  setState(() {
                    _selectedVariant = null;
                    _manualVariant = false;
                    _variant.clear();
                  });
                },
                onRetry: variantSelection == null
                    ? null
                    : () => ref.invalidate(
                          vehicleVariantsProvider(variantSelection),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleMakeField extends StatelessWidget {
  const _VehicleMakeField({
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<VehicleMakeOption> items;
  final VehicleMakeOption? value;
  final ValueChanged<VehicleMakeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormField<VehicleMakeOption>(
      key: ValueKey(value?.id),
      initialValue: value,
      validator: (selection) => selection == null ? l10n.fieldRequired : null,
      builder: (field) => InkWell(
        onTap: () async {
          final selected = await showModalBottomSheet<VehicleMakeOption>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => _VehicleMakePicker(
              items: items,
              selectedId: value?.id,
            ),
          );
          if (selected == null || !context.mounted) return;
          field.didChange(selected);
          onChanged(selected);
        },
        borderRadius: AppRadius.small,
        child: InputDecorator(
          key: const ValueKey('vehicle-make-field'),
          isEmpty: value == null,
          decoration: InputDecoration(
            labelText: l10n.vehicleMake,
            hintText: l10n.chooseVehicleMake,
            errorText: field.errorText,
            prefixIcon: _MakeLogo(make: value),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          child: value == null
              ? null
              : Text(
                  value!.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}

class _VehicleModelField extends StatelessWidget {
  const _VehicleModelField({
    required this.make,
    required this.models,
    required this.value,
    required this.onChanged,
    required this.onRetry,
  });

  final VehicleMakeOption? make;
  final AsyncValue<List<VehicleModelOption>>? models;
  final VehicleModelOption? value;
  final ValueChanged<VehicleModelOption> onChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = models?.value;
    final isLoading = models?.isLoading ?? false;
    final hasError = models?.hasError ?? false;
    final isEnabled = make != null &&
        !isLoading &&
        !hasError &&
        items != null &&
        items.isNotEmpty;

    final hint = switch ((make, isLoading, hasError, items?.isEmpty)) {
      (null, _, _, _) => l10n.chooseVehicleMakeFirst,
      (_, true, _, _) => l10n.vehicleModelLoading,
      (_, _, true, _) => l10n.vehicleModelLoadError,
      (_, _, _, true) => l10n.vehicleModelEmpty,
      _ => l10n.chooseVehicleModel,
    };

    return FormField<VehicleModelOption>(
      key: ValueKey((make?.id, value?.id)),
      initialValue: value,
      validator: (selection) => selection == null ? l10n.fieldRequired : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: !isEnabled
                ? null
                : () async {
                    final selected =
                        await showModalBottomSheet<VehicleModelOption>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => _VehicleModelPicker(
                        items: items,
                        selectedId: value?.id,
                        makeName: make!.name,
                      ),
                    );
                    if (selected == null || !context.mounted) return;
                    field.didChange(selected);
                    onChanged(selected);
                  },
            borderRadius: AppRadius.small,
            child: InputDecorator(
              key: const ValueKey('vehicle-model-field'),
              isEmpty: value == null,
              decoration: InputDecoration(
                enabled: isEnabled,
                labelText: l10n.vehicleModel,
                hintText: hint,
                errorText: field.errorText,
                prefixIcon: const Icon(Icons.directions_car_outlined),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.medium),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              child: value == null
                  ? null
                  : Text(
                      value!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
          if ((hasError || items?.isEmpty == true) && onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleVariantField extends StatelessWidget {
  const _VehicleVariantField({
    required this.model,
    required this.year,
    required this.variants,
    required this.value,
    required this.manual,
    required this.manualController,
    required this.onChanged,
    required this.onManual,
    required this.onMaster,
    required this.onRetry,
  });

  final VehicleModelOption? model;
  final int? year;
  final AsyncValue<List<VehicleVariantOption>>? variants;
  final VehicleVariantOption? value;
  final bool manual;
  final TextEditingController manualController;
  final ValueChanged<VehicleVariantOption> onChanged;
  final VoidCallback onManual;
  final VoidCallback onMaster;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (manual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const ValueKey('vehicle-variant-manual-field'),
            controller: manualController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.vehicleVariant,
              helperText: l10n.vehicleVariantManualHelper,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            validator: (text) =>
                text == null || text.trim().isEmpty ? l10n.fieldRequired : null,
          ),
          if (model != null && year != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onMaster,
                icon: const Icon(Icons.list_alt_rounded),
                label: Text(l10n.chooseFromVariantMaster),
              ),
            ),
        ],
      );
    }

    final items = variants?.value;
    final isLoading = variants?.isLoading ?? false;
    final hasError = variants?.hasError ?? false;
    final isEnabled = model != null &&
        year != null &&
        !isLoading &&
        !hasError &&
        items != null &&
        items.isNotEmpty;
    final hint = switch ((model, year, isLoading, hasError, items?.isEmpty)) {
      (null, _, _, _, _) ||
      (_, null, _, _, _) =>
        l10n.chooseVehicleModelAndYearFirst,
      (_, _, true, _, _) => l10n.vehicleVariantLoading,
      (_, _, _, true, _) => l10n.vehicleVariantLoadError,
      (_, _, _, _, true) => l10n.vehicleVariantEmpty,
      _ => l10n.chooseVehicleVariant,
    };

    return FormField<VehicleVariantOption>(
      key: ValueKey((model?.id, year, value?.id)),
      initialValue: value,
      validator: (selection) => selection == null ? l10n.fieldRequired : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: !isEnabled
                ? null
                : () async {
                    final selected =
                        await showModalBottomSheet<VehicleVariantOption>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => _VehicleVariantPicker(
                        items: items,
                        selectedId: value?.id,
                        modelName: model!.name,
                        year: year!,
                      ),
                    );
                    if (selected == null || !context.mounted) return;
                    field.didChange(selected);
                    onChanged(selected);
                  },
            borderRadius: AppRadius.small,
            child: InputDecorator(
              key: const ValueKey('vehicle-variant-field'),
              isEmpty: value == null,
              decoration: InputDecoration(
                enabled: isEnabled,
                labelText: l10n.vehicleVariant,
                hintText: hint,
                errorText: field.errorText,
                prefixIcon: const Icon(Icons.tune_rounded),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.medium),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              child: value == null
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value!.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_variantMetadata(context, value!).isNotEmpty)
                          Text(
                            _variantMetadata(context, value!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
            ),
          ),
          if ((hasError || items?.isEmpty == true) && onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
          if (model != null && year != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onManual,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.vehicleVariantNotFound),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleYearField extends StatelessWidget {
  const _VehicleYearField({
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormField<int>(
      key: ValueKey(value),
      initialValue: value,
      validator: (selection) => selection == null ? l10n.fieldRequired : null,
      builder: (field) => InkWell(
        onTap: () async {
          final selected = await showModalBottomSheet<int>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => _VehicleYearPicker(selectedYear: value),
          );
          if (selected == null || !context.mounted) return;
          field.didChange(selected);
          onChanged(selected);
        },
        borderRadius: AppRadius.small,
        child: InputDecorator(
          key: const ValueKey('vehicle-year-field'),
          isEmpty: value == null,
          decoration: InputDecoration(
            labelText: l10n.vehicleYear,
            hintText: l10n.chooseVehicleYear,
            errorText: field.errorText,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          child: value == null ? null : Text(value.toString()),
        ),
      ),
    );
  }
}

class _MakeLogo extends StatelessWidget {
  const _MakeLogo({required this.make});

  final VehicleMakeOption? make;

  @override
  Widget build(BuildContext context) {
    final logoUrl = make?.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return const Icon(Icons.directions_car_outlined);
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.small),
      child: Image.network(
        logoUrl,
        width: AppIconSize.large,
        height: AppIconSize.large,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.directions_car_outlined,
        ),
      ),
    );
  }
}

class _MasterDataMessage extends StatelessWidget {
  const _MasterDataMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: AppSpacing.medium),
        Expanded(child: Text(message)),
        TextButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    );
  }
}

class _VehicleMakePicker extends StatefulWidget {
  const _VehicleMakePicker({
    required this.items,
    required this.selectedId,
  });

  final List<VehicleMakeOption> items;
  final int? selectedId;

  @override
  State<_VehicleMakePicker> createState() => _VehicleMakePickerState();
}

class _VehicleMakePickerState extends State<_VehicleMakePicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.small,
            ),
            child: Text(
              l10n.chooseVehicleMake,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.small,
            ),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchVehicleMake,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final make = filtered[index];
                return ListTile(
                  minTileHeight: 56,
                  leading: SizedBox.square(
                    dimension: AppIconSize.large,
                    child: _MakeLogo(make: make),
                  ),
                  title: Text(make.name),
                  trailing: make.id == widget.selectedId
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(make),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleModelPicker extends StatefulWidget {
  const _VehicleModelPicker({
    required this.items,
    required this.selectedId,
    required this.makeName,
  });

  final List<VehicleModelOption> items;
  final int? selectedId;
  final String makeName;

  @override
  State<_VehicleModelPicker> createState() => _VehicleModelPickerState();
}

class _VehicleModelPickerState extends State<_VehicleModelPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.small,
            ),
            child: Text(
              l10n.chooseVehicleModelFor(widget.makeName),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.small,
            ),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchVehicleModel,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final model = filtered[index];
                return ListTile(
                  minTileHeight: 56,
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text(model.name),
                  trailing: model.id == widget.selectedId
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleVariantPicker extends StatefulWidget {
  const _VehicleVariantPicker({
    required this.items,
    required this.selectedId,
    required this.modelName,
    required this.year,
  });

  final List<VehicleVariantOption> items;
  final int? selectedId;
  final String modelName;
  final int year;

  @override
  State<_VehicleVariantPicker> createState() => _VehicleVariantPickerState();
}

class _VehicleVariantPickerState extends State<_VehicleVariantPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.small,
            ),
            child: Text(
              l10n.chooseVehicleVariantFor(widget.modelName, widget.year),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.small,
            ),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchVehicleVariant,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l10n.vehicleVariantEmpty))
                : ListView.separated(
                    controller: scrollController,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final variant = filtered[index];
                      final metadata = _variantMetadata(context, variant);
                      return ListTile(
                        minTileHeight: 56,
                        leading: const Icon(Icons.tune_rounded),
                        title: Text(variant.name),
                        subtitle: metadata.isEmpty ? null : Text(metadata),
                        trailing: variant.id == widget.selectedId
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(variant),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

String _variantMetadata(
  BuildContext context,
  VehicleVariantOption variant,
) {
  final l10n = AppLocalizations.of(context)!;
  final labels = <String>[
    switch (variant.transmission) {
      'automatic' => l10n.automatic,
      'manual' => l10n.manual,
      final value? => value,
      null => '',
    },
    switch (variant.fuelType) {
      'gasoline' => l10n.gasoline,
      'diesel' => l10n.diesel,
      'hybrid' => l10n.hybrid,
      'electric' => l10n.electric,
      final value? => value,
      null => '',
    },
  ]..removeWhere((label) => label.isEmpty);
  return labels.join(' · ');
}

class _VehicleYearPicker extends StatelessWidget {
  const _VehicleYearPicker({required this.selectedYear});

  final int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxYear = DateTime.now().year + 1;
    final years = List<int>.generate(
      maxYear - 1949,
      (index) => maxYear - index,
    );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Text(
              l10n.chooseVehicleYear,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: years.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final year = years[index];
                return ListTile(
                  minTileHeight: 56,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(year.toString()),
                  trailing: year == selectedYear
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(year),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
