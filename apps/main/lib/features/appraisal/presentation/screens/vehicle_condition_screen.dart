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

/// Kondisi umum memakai empat tier yang sama dengan OLX (A-D), tetapi hanya
/// deskripsinya yang ditampilkan: label huruf grade sengaja disembunyikan
/// supaya pelanggan memilih berdasarkan kondisi nyata, bukan menebak grade.
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

  /// Kode grade internal (`a`-`d`) yang dikirim ke server; tidak ditampilkan.
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: ValueKey('condition-grade-$code'),
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
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
