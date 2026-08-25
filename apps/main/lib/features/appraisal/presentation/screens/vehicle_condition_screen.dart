import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';

class VehicleConditionScreen extends ConsumerStatefulWidget {
  const VehicleConditionScreen({super.key});

  @override
  ConsumerState<VehicleConditionScreen> createState() =>
      _VehicleConditionScreenState();
}

class _VehicleConditionScreenState
    extends ConsumerState<VehicleConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tax;
  String? _flood;
  String? _accident;
  String? _service;
  String? _ownership;
  String? _grade;
  String? _engine;
  String? _tyre;
  int _conditionPercentage = 90;
  bool _gradeMissing = false;
  bool _initialized = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_grade == null) {
      setState(() => _gradeMissing = true);
      return;
    }
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveCondition(
          taxStatus: _tax!,
          floodHistory: _flood!,
          majorAccidentHistory: _accident!,
          serviceHistory: _service!,
          ownership: _ownership!,
          conditionPercentage: _conditionPercentage,
          conditionGrade: _grade!,
          engineCondition: _engine!,
          tyreCondition: _tyre!,
        );
    if (mounted) context.push(appraisalPhotosPath);
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
      _tax = draft.taxStatus.isEmpty ? null : draft.taxStatus;
      _flood = draft.floodHistory.isEmpty ? null : draft.floodHistory;
      _accident = draft.majorAccidentHistory.isEmpty
          ? null
          : draft.majorAccidentHistory;
      _service = draft.serviceHistory.isEmpty ? null : draft.serviceHistory;
      _ownership = draft.ownership.isEmpty ? null : draft.ownership;
      _grade = draft.conditionGrade.isEmpty ? null : draft.conditionGrade;
      _engine = draft.engineCondition.isEmpty ? null : draft.engineCondition;
      _tyre = draft.tyreCondition.isEmpty ? null : draft.tyreCondition;
      _conditionPercentage = draft.conditionPercentage;
    }

    return AppraisalFlowScaffold(
      step: 2,
      fallbackLocation: appraisalDetailsPath,
      title: l10n.conditionTitle,
      description: l10n.conditionDescription,
      primaryLabel: l10n.next,
      primaryBusy: _saving,
      onPrimary: _continue,
      body: AppraisalCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _ConditionGradeField(
                value: _grade,
                showError: _gradeMissing,
                onChanged: (value) => setState(() {
                  _grade = value;
                  _gradeMissing = false;
                }),
              ),
              const SizedBox(height: AppSpacing.large),
              _ConditionPercentageField(
                value: _conditionPercentage,
                onChanged: (value) {
                  setState(() => _conditionPercentage = value);
                },
              ),
              const SizedBox(height: AppSpacing.large),
              _choice(
                label: l10n.engineCondition,
                value: _engine,
                options: {
                  'normal': l10n.engineConditionNormal,
                  'wet': l10n.engineConditionWet,
                },
                onChanged: (value) => _engine = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.tyreCondition,
                value: _tyre,
                options: {
                  'normal': l10n.tyreConditionNormal,
                  'damaged': l10n.tyreConditionDamaged,
                },
                onChanged: (value) => _tyre = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.taxStatus,
                value: _tax,
                options: {
                  'active': l10n.taxActive,
                  'overdue': l10n.taxOverdue,
                  'unknown': l10n.unknown,
                },
                onChanged: (value) => _tax = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.floodHistory,
                value: _flood,
                options: {
                  'no': l10n.answerNo,
                  'yes': l10n.answerYes,
                  'unknown': l10n.unknown,
                },
                onChanged: (value) => _flood = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.majorAccidentHistory,
                value: _accident,
                options: {
                  'no': l10n.answerNo,
                  'yes': l10n.answerYes,
                  'unknown': l10n.unknown,
                },
                onChanged: (value) => _accident = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.serviceHistory,
                value: _service,
                options: {
                  'complete': l10n.serviceComplete,
                  'partial': l10n.servicePartial,
                  'none': l10n.serviceNone,
                  'unknown': l10n.unknown,
                },
                onChanged: (value) => _service = value,
              ),
              const SizedBox(height: AppSpacing.medium),
              _choice(
                label: l10n.ownership,
                value: _ownership,
                options: {
                  'first': l10n.ownershipFirst,
                  'second': l10n.ownershipSecond,
                  'more': l10n.ownershipMore,
                  'unknown': l10n.unknown,
                },
                onChanged: (value) => _ownership = value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choice({
    required String label,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: options.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }
}

class _ConditionPercentageField extends StatelessWidget {
  const _ConditionPercentageField({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.vehicleConditionPercentage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              l10n.conditionPercentageValue(value),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.vehicleConditionPercentageDescription,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: l10n.conditionPercentageValue(value),
          semanticFormatterCallback: (sliderValue) =>
              l10n.conditionPercentageValue(sliderValue.round()),
          onChanged: (sliderValue) => onChanged(sliderValue.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.conditionPercentageValue(0),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              l10n.conditionPercentageValue(100),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

/// Grade kondisi memakai tier yang sama dengan OLX, lengkap dengan penjelasan
/// tiap pilihan supaya pelanggan tidak menebak-nebak seperti saat memakai
/// persentase.
class _ConditionGradeField extends StatelessWidget {
  const _ConditionGradeField({
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final String? value;
  final bool showError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final options = <String, String>{
      'a': l10n.conditionGradeA,
      'b': l10n.conditionGradeB,
      'c': l10n.conditionGradeC,
      'd': l10n.conditionGradeD,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.conditionGrade,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          l10n.conditionGradeDescription,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.medium),
        for (final option in options.entries) ...[
          _GradeOption(
            code: option.key,
            label: option.value,
            selected: value == option.key,
            onTap: () => onChanged(option.key),
          ),
          if (option.key != options.keys.last)
            const SizedBox(height: AppSpacing.small),
        ],
        if (showError) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.fieldRequired,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
          ),
        ],
      ],
    );
  }
}

class _GradeOption extends StatelessWidget {
  const _GradeOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    selected ? colors.primary : colors.surfaceContainerHighest,
                child: Text(
                  code.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                      ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
