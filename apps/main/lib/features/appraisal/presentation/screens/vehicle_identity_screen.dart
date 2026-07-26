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
  final _model = TextEditingController();
  final _variant = TextEditingController();
  final _year = TextEditingController();
  VehicleMakeOption? _selectedMake;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _model.dispose();
    _variant.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final make = _selectedMake;
    if (make == null) return;
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveIdentity(
          makeId: make.id,
          make: make.name,
          model: _model.text,
          variant: _variant.text,
          year: int.parse(_year.text),
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
      _model.text = value.draft.model;
      _variant.text = value.draft.variant;
      _year.text = value.draft.year?.toString() ?? '';
    }
    final makes = ref.watch(vehicleMakesProvider);

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
                  if (_selectedMake == null && value.draft.makeId != null) {
                    for (final item in items) {
                      if (item.id == value.draft.makeId) {
                        _selectedMake = item;
                        break;
                      }
                    }
                  }
                  if (items.isEmpty) {
                    return _MasterDataMessage(
                      icon: Icons.directions_car_outlined,
                      message: l10n.vehicleMakeEmpty,
                      onRetry: () => ref.invalidate(vehicleMakesProvider),
                    );
                  }
                  return FormField<VehicleMakeOption>(
                    initialValue: _selectedMake,
                    validator: (selection) =>
                        selection == null ? l10n.fieldRequired : null,
                    builder: (field) => InkWell(
                      onTap: () async {
                        final selected =
                            await showModalBottomSheet<VehicleMakeOption>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) => _VehicleMakePicker(
                            items: items,
                            selectedId: _selectedMake?.id,
                          ),
                        );
                        if (selected == null || !mounted) return;
                        setState(() => _selectedMake = selected);
                        field.didChange(selected);
                      },
                      borderRadius: AppRadius.small,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.vehicleMake,
                          errorText: field.errorText,
                          prefixIcon: _MakeLogo(make: _selectedMake),
                          suffixIcon:
                              const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                        child: Text(
                          _selectedMake?.name ?? l10n.chooseVehicleMake,
                          style: _selectedMake == null
                              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )
                              : null,
                        ),
                      ),
                    ),
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
              _field(_model, l10n.vehicleModel, TextInputAction.next),
              const SizedBox(height: AppSpacing.medium),
              _field(_variant, l10n.vehicleVariant, TextInputAction.next),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.vehicleYear,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  final max = DateTime.now().year + 1;
                  return year == null || year < 1950 || year > max
                      ? l10n.fieldRequired
                      : null;
                },
                onFieldSubmitted: (_) => _continue(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputAction action,
  ) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.directions_car_outlined),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? AppLocalizations.of(context)!.fieldRequired
          : null,
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
        errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_outlined),
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
            child: Text(AppLocalizations.of(context)!.retry)),
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
                    dimension: 40,
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
