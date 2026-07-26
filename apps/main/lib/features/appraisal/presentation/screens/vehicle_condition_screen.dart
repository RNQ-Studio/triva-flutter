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
  bool _initialized = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(appraisalFlowProvider.notifier).saveCondition(
          taxStatus: _tax!,
          floodHistory: _flood!,
          majorAccidentHistory: _accident!,
          serviceHistory: _service!,
          ownership: _ownership!,
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
    }

    return AppraisalFlowScaffold(
      step: 2,
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
