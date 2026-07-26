import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  final _city = TextEditingController();
  String? _transmission;
  String? _fuel;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _mileage.dispose();
    _color.dispose();
    _plate.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveDetails(
          transmission: _transmission!,
          fuelType: _fuel!,
          mileage: int.parse(_mileage.text),
          color: _color.text,
          licensePlate: _plate.text,
          city: _city.text,
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
      _city.text = draft.city;
    }

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
              _textField(_city, l10n.vehicleCity, submit: true),
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
