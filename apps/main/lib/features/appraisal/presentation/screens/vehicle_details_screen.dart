import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileage = TextEditingController();
  final _color = TextEditingController();
  final _plate = TextEditingController();
  String? _transmission;
  String? _fuel;
  int? _provinceId;
  int? _cityId;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _mileage.dispose();
    _color.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final provinces = ref.read(provinceOptionsProvider).value ?? const [];
    ProvinceOption? selectedProvince;
    CityOption? selectedCity;
    for (final province in provinces) {
      if (province.id != _provinceId) continue;
      selectedProvince = province;
      for (final city in province.cities) {
        if (city.id == _cityId) {
          selectedCity = city;
          break;
        }
      }
      break;
    }
    if (selectedProvince == null || selectedCity == null) return;
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveDetails(
          transmission: _transmission!,
          fuelType: _fuel!,
          mileage: int.parse(_mileage.text),
          color: _color.text,
          licensePlate: _plate.text,
          provinceId: selectedProvince.id,
          cityId: selectedCity.id,
          city: selectedCity.name,
        );
    if (mounted) context.push(appraisalConditionPath);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = ref.watch(appraisalFlowProvider).value;
    if (value == null) return const AppraisalLoading();
    if (!_initialized) {
      _initialized = true;
      final draft = value.draft;
      _transmission = draft.transmission.isEmpty ? null : draft.transmission;
      _fuel = draft.fuelType.isEmpty ? null : draft.fuelType;
      _mileage.text = draft.mileage?.toString() ?? '';
      _color.text = draft.color;
      _plate.text = draft.licensePlate;
      _provinceId = draft.provinceId;
      _cityId = draft.cityId;
    }
    final regions = ref.watch(provinceOptionsProvider);

    return AppraisalFlowScaffold(
      step: 1,
      title: l10n.vehicleDetailsTitle,
      description: l10n.vehicleDetailsDescription,
      primaryLabel: l10n.next,
      primaryBusy: _saving,
      onPrimary: _continue,
      body: AppraisalCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _VehicleIdentitySummary(
                draft: value.draft,
                onEdit: () => context.go(appraisalIdentityPath),
              ),
              const SizedBox(height: AppSpacing.medium),
              const Divider(),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _transmission,
                decoration: InputDecoration(labelText: l10n.transmission),
                items: [
                  DropdownMenuItem(
                    value: 'automatic',
                    child: Text(l10n.automatic),
                  ),
                  DropdownMenuItem(
                    value: 'manual',
                    child: Text(l10n.manual),
                  ),
                ],
                onChanged: (value) => _transmission = value,
                validator: (value) => value == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _fuel,
                decoration: InputDecoration(labelText: l10n.fuelType),
                items: [
                  DropdownMenuItem(
                    value: 'gasoline',
                    child: Text(l10n.gasoline),
                  ),
                  DropdownMenuItem(
                    value: 'diesel',
                    child: Text(l10n.diesel),
                  ),
                  DropdownMenuItem(
                    value: 'hybrid',
                    child: Text(l10n.hybrid),
                  ),
                  DropdownMenuItem(
                    value: 'electric',
                    child: Text(l10n.electric),
                  ),
                ],
                onChanged: (value) => _fuel = value,
                validator: (value) => value == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _mileage,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.mileage,
                  suffixText: 'km',
                ),
                validator: _requiredNumber,
              ),
              const SizedBox(height: AppSpacing.medium),
              _textField(_color, l10n.vehicleColor),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _plate,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]')),
                ],
                decoration: InputDecoration(labelText: l10n.licensePlate),
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.medium),
              regions.when(
                data: (provinces) {
                  ProvinceOption? selectedProvince;
                  for (final province in provinces) {
                    if (province.id == _provinceId) {
                      selectedProvince = province;
                      break;
                    }
                  }
                  final cities =
                      selectedProvince?.cities ?? const <CityOption>[];
                  CityOption? selectedCity;
                  for (final city in cities) {
                    if (city.id == _cityId) {
                      selectedCity = city;
                      break;
                    }
                  }
                  if (provinces.isEmpty) {
                    return _RegionMessage(
                      message: l10n.regionEmpty,
                      onRetry: () => ref.invalidate(provinceOptionsProvider),
                    );
                  }
                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: selectedProvince?.id,
                        decoration: InputDecoration(
                          labelText: l10n.province,
                          prefixIcon: const Icon(Icons.map_outlined),
                        ),
                        items: [
                          for (final province in provinces)
                            DropdownMenuItem(
                              value: province.id,
                              child: Text(province.name),
                            ),
                        ],
                        onChanged: (value) => setState(() {
                          _provinceId = value;
                          _cityId = null;
                        }),
                        validator: (value) =>
                            value == null ? l10n.fieldRequired : null,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<int>(
                        key: ValueKey(_provinceId),
                        isExpanded: true,
                        initialValue: selectedCity?.id,
                        decoration: InputDecoration(
                          labelText: l10n.vehicleCity,
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          hintText: selectedProvince == null
                              ? l10n.chooseProvinceFirst
                              : l10n.chooseCity,
                        ),
                        items: [
                          for (final city in cities)
                            DropdownMenuItem(
                              value: city.id,
                              child: Text(city.name),
                            ),
                        ],
                        onChanged: selectedProvince == null
                            ? null
                            : (value) => setState(() => _cityId = value),
                        validator: (value) =>
                            value == null ? l10n.fieldRequired : null,
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.small),
                    Text(l10n.regionLoading),
                  ],
                ),
                error: (_, __) => _RegionMessage(
                  message: l10n.regionLoadError,
                  onRetry: () => ref.invalidate(provinceOptionsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool submit = false,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textInputAction: submit ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: _required,
      onFieldSubmitted: submit ? (_) => _continue() : null,
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.fieldRequired
      : null;

  String? _requiredNumber(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 0 || number > 2000000
        ? AppLocalizations.of(context)!.fieldRequired
        : null;
  }
}

class _VehicleIdentitySummary extends StatelessWidget {
  const _VehicleIdentitySummary({
    required this.draft,
    required this.onEdit,
  });

  final AppraisalDraft draft;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.directions_car_outlined),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.vehicleIdentityTitle,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    '${draft.make} ${draft.model}',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    '${draft.variant} · ${draft.year}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.editVehicleIdentity),
          ),
        ),
      ],
    );
  }
}

class _RegionMessage extends StatelessWidget {
  const _RegionMessage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cloud_off_outlined),
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
