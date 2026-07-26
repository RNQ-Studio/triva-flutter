import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _variant = TextEditingController();
  final _year = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _variant.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveIdentity(
          make: _make.text,
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
      _make.text = value.draft.make;
      _model.text = value.draft.model;
      _variant.text = value.draft.variant;
      _year.text = value.draft.year?.toString() ?? '';
    }

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
              _field(_make, l10n.vehicleMake, TextInputAction.next),
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
