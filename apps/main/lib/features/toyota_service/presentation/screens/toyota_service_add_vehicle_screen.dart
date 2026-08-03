import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../appraisal/domain/appraisal_models.dart';
import '../../../appraisal/presentation/appraisal_controller.dart';
import '../../domain/toyota_service_models.dart';
import '../toyota_service_controller.dart';
import '../toyota_service_paths.dart';
import '../widgets/toyota_service_widgets.dart';

class ToyotaServiceAddVehicleScreen extends ConsumerStatefulWidget {
  const ToyotaServiceAddVehicleScreen({
    this.returnToCaller = false,
    super.key,
  });

  final bool returnToCaller;

  @override
  ConsumerState<ToyotaServiceAddVehicleScreen> createState() =>
      _ToyotaServiceAddVehicleScreenState();
}

class _ToyotaServiceAddVehicleScreenState
    extends ConsumerState<ToyotaServiceAddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _variantController = TextEditingController();
  final _mileageController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();

  VehicleMakeOption? _make;
  VehicleModelOption? _model;
  ProvinceOption? _province;
  CityOption? _city;
  int? _year;
  String? _transmission;
  String? _fuelType;
  bool _submitted = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _variantController.dispose();
    _mileageController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final makes = ref.watch(vehicleMakesProvider);
    final provinces = ref.watch(provinceOptionsProvider);
    final models = _make == null
        ? const AsyncData<List<VehicleModelOption>>([])
        : ref.watch(vehicleModelsProvider(_make!.id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingAddVehicleTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.bookingAddVehicleTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            l10n.bookingAddVehicleDescription,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          _AsyncDropdown<VehicleMakeOption>(
                            value: makes,
                            current: _make,
                            label: l10n.vehicleMake,
                            empty: l10n.vehicleMakeEmpty,
                            itemLabel: (item) => item.name,
                            onRetry: () => ref.invalidate(vehicleMakesProvider),
                            onChanged: (item) {
                              setState(() {
                                _make = item;
                                _model = null;
                              });
                            },
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _AsyncDropdown<VehicleModelOption>(
                            value: models,
                            current: _model,
                            label: l10n.vehicleModel,
                            empty: _make == null
                                ? l10n.chooseVehicleMakeFirst
                                : l10n.vehicleModelEmpty,
                            itemLabel: (item) => item.name,
                            onRetry: () {
                              if (_make != null) {
                                ref.invalidate(
                                  vehicleModelsProvider(_make!.id),
                                );
                              }
                            },
                            onChanged: _make == null
                                ? null
                                : (item) => setState(() => _model = item),
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          TextFormField(
                            controller: _variantController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration:
                                InputDecoration(labelText: l10n.vehicleVariant),
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          DropdownButtonFormField<int>(
                            initialValue: _year,
                            isExpanded: true,
                            decoration:
                                InputDecoration(labelText: l10n.vehicleYear),
                            items: List.generate(
                              DateTime.now().year - 1949,
                              (index) => DateTime.now().year - index,
                            )
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) => setState(() => _year = value),
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          DropdownButtonFormField<String>(
                            initialValue: _transmission,
                            isExpanded: true,
                            decoration:
                                InputDecoration(labelText: l10n.transmission),
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
                            onChanged: (value) =>
                                setState(() => _transmission = value),
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          DropdownButtonFormField<String>(
                            initialValue: _fuelType,
                            isExpanded: true,
                            decoration:
                                InputDecoration(labelText: l10n.fuelType),
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
                            onChanged: (value) =>
                                setState(() => _fuelType = value),
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          TextFormField(
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.mileage,
                              suffixText: 'km',
                            ),
                            validator: (value) {
                              final number = int.tryParse(value ?? '');
                              return number == null ||
                                      number < 0 ||
                                      number > 2000000
                                  ? l10n.fieldRequired
                                  : null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          TextFormField(
                            controller: _colorController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration:
                                InputDecoration(labelText: l10n.vehicleColor),
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          TextFormField(
                            controller: _plateController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            decoration:
                                InputDecoration(labelText: l10n.licensePlate),
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _AsyncDropdown<ProvinceOption>(
                            value: provinces,
                            current: _province,
                            label: l10n.province,
                            empty: l10n.regionEmpty,
                            itemLabel: (item) => item.name,
                            onRetry: () =>
                                ref.invalidate(provinceOptionsProvider),
                            onChanged: (item) {
                              setState(() {
                                _province = item;
                                _city = null;
                              });
                            },
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          DropdownButtonFormField<CityOption>(
                            initialValue: _city,
                            isExpanded: true,
                            decoration:
                                InputDecoration(labelText: l10n.cityOrRegency),
                            items: (_province?.cities ?? const [])
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: _province == null
                                ? null
                                : (value) => setState(() => _city = value),
                            validator: (value) =>
                                value == null ? l10n.fieldRequired : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.medium),
                            BookingNotice(
                              message: _error!,
                              kind: BookingNoticeKind.error,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveAndContinue),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? AppLocalizations.of(context)!.fieldRequired
        : null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final saved = await ref.read(appraisalRepositoryProvider).createVehicle(
            VehicleData(
              makeId: _make!.id,
              modelId: _model!.id,
              make: _make!.name,
              model: _model!.name,
              variant: _variantController.text.trim(),
              year: _year!,
              transmission: _transmission!,
              fuelType: _fuelType!,
              mileage: int.parse(_mileageController.text),
              color: _colorController.text.trim(),
              licensePlate: _plateController.text.trim().toUpperCase(),
              provinceId: _province!.id,
              cityId: _city!.id,
              city: _city!.name,
            ),
          );
      final vehicle = ToyotaServiceVehicle(
        id: saved.id!,
        make: saved.make,
        makeSlug: _make!.slug,
        model: saved.model,
        variant: saved.variant,
        year: saved.year,
        mileage: saved.mileage,
        licensePlate: saved.licensePlate,
      );
      ref.invalidate(toyotaServiceVehiclesProvider);
      if (!mounted) return;
      if (widget.returnToCaller && context.canPop()) {
        context.pop(vehicle);
        return;
      }
      await ref.read(toyotaServiceFlowProvider.notifier).selectVehicle(vehicle);
      if (!mounted) return;
      context.go(
        vehicle.isToyota
            ? toyotaServiceFulfillmentPath
            : toyotaServiceNonToyotaPath,
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = isNetworkFailure(error)
            ? AppLocalizations.of(context)!.bookingOfflineError
            : AppLocalizations.of(context)!.errorGeneral;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _AsyncDropdown<T> extends StatelessWidget {
  const _AsyncDropdown({
    required this.value,
    required this.current,
    required this.label,
    required this.empty,
    required this.itemLabel,
    required this.onRetry,
    required this.onChanged,
    required this.validator,
  });

  final AsyncValue<List<T>> value;
  final T? current;
  final String label;
  final String empty;
  final String Function(T item) itemLabel;
  final VoidCallback onRetry;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T> validator;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) => DropdownButtonFormField<T>(
        initialValue: current,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          helperText: items.isEmpty ? empty : null,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  itemLabel(item),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: items.isEmpty ? null : onChanged,
        validator: validator,
      ),
      loading: () => TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          errorText: AppLocalizations.of(context)!.loadFailed,
          suffixIcon: IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.of(context)!.retry,
          ),
        ),
      ),
    );
  }
}
