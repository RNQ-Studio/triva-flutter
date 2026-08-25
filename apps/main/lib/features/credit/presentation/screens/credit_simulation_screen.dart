import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/credit_models.dart';
import '../credit_controller.dart';
import '../credit_paths.dart';
import 'widgets/credit_follow_up_dialog.dart';
import 'widgets/credit_result_sections.dart';

class CreditSimulationScreen extends ConsumerStatefulWidget {
  const CreditSimulationScreen({
    this.sourceAppraisalId,
    this.sourceProgramId,
    this.campaignSource,
    super.key,
  });

  final String? sourceAppraisalId;
  final String? sourceProgramId;
  final String? campaignSource;

  @override
  ConsumerState<CreditSimulationScreen> createState() =>
      _CreditSimulationScreenState();
}

class _CreditSimulationScreenState
    extends ConsumerState<CreditSimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _tradeInController = TextEditingController();
  final _payoffController = TextEditingController();
  Timer? _draftSaveTimer;
  CreditFlowController? _flowController;
  CreditSimulationDraft? _latestDraft;
  bool _hydrated = false;
  bool _entryContextApplied = false;

  @override
  void dispose() {
    _flushPendingDraft();
    _cashController.dispose();
    _tradeInController.dispose();
    _payoffController.dispose();
    super.dispose();
  }

  void _hydrate(CreditSimulationDraft draft) {
    if (_hydrated) return;
    _hydrated = true;
    _cashController.text = draft.cashDownPayment == 0
        ? ''
        : formatRupiahAmount(draft.cashDownPayment);
    _tradeInController.text = draft.manualTradeInValue == 0
        ? ''
        : formatRupiahAmount(draft.manualTradeInValue);
    _payoffController.text = draft.oldVehiclePayoff == 0
        ? ''
        : formatRupiahAmount(draft.oldVehiclePayoff);
  }

  int _amount(TextEditingController controller) =>
      rupiahValueOf(controller.text);

  int _manualTradeInAmount(CreditSimulationDraft draft) =>
      draft.tradeInAppraisalId == null ? _amount(_tradeInController) : 0;

  Future<void> _calculate(
    CreditSimulationDraft draft,
  ) async {
    _draftSaveTimer?.cancel();
    if (!(_formKey.currentState?.validate() ?? false) ||
        draft.tenorMonths == null) {
      return;
    }
    await ref.read(creditFlowProvider.notifier).updateInputs(
          cashDownPayment: _amount(_cashController),
          manualTradeInValue: _manualTradeInAmount(draft),
          useTradeInAsDp: draft.useTradeInAsDp,
          oldVehiclePayoff: _amount(_payoffController),
          tenorMonths: draft.tenorMonths!,
          acceptExpiredAppraisal: draft.acceptExpiredAppraisal,
        );
    await ref.read(creditFlowProvider.notifier).calculate();
  }

  Future<void> _showFollowUp() async {
    final l10n = AppLocalizations.of(context)!;
    final channel = await showCreditFollowUpDialog(context);
    if (channel == null || !mounted) return;
    final simulation =
        await ref.read(creditFlowProvider.notifier).requestFollowUp(channel);
    if (simulation != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.creditFollowUpSuccess)));
    }
  }

  Future<void> _share(CreditCalculation calculation) =>
      SharePlus.instance.share(
        ShareParams(
          subject: AppLocalizations.of(context)!.creditFlowTitle,
          text: creditShareText(context, calculation),
        ),
      );

  void _scheduleDraftSave() {
    ref.read(creditFlowProvider.notifier).markInputsDirty();
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _persistDraftFromControllers();
    });
  }

  void _flushPendingDraft() {
    if (!(_draftSaveTimer?.isActive ?? false)) return;
    _draftSaveTimer?.cancel();
    final notifier = _flowController;
    final draft = _latestDraft;
    final tenor = draft?.tenorMonths;
    if (notifier == null || draft == null || tenor == null) return;
    unawaited(
      notifier.persistInputsOnExit(
        cashDownPayment: _amount(_cashController),
        manualTradeInValue: _manualTradeInAmount(draft),
        useTradeInAsDp: draft.useTradeInAsDp,
        oldVehiclePayoff: _amount(_payoffController),
        tenorMonths: tenor,
        acceptExpiredAppraisal: draft.acceptExpiredAppraisal,
      ),
    );
  }

  void _persistDraftFromControllers() {
    final state = ref.read(creditFlowProvider).value;
    final tenor = state?.draft.tenorMonths;
    if (state == null || tenor == null) return;
    unawaited(
      ref.read(creditFlowProvider.notifier).updateInputs(
            cashDownPayment: _amount(_cashController),
            manualTradeInValue: _manualTradeInAmount(state.draft),
            useTradeInAsDp: state.draft.useTradeInAsDp,
            oldVehiclePayoff: _amount(_payoffController),
            tenorMonths: tenor,
            acceptExpiredAppraisal: state.draft.acceptExpiredAppraisal,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final programs = ref.watch(creditProgramsProvider);
    final flow = ref.watch(creditFlowProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditFlowTitle)),
      body: SafeArea(
        child: programs.when(
          loading: () => const _CreditLoading(),
          error: (_, __) => _CreditLoadError(
            onRetry: () => ref.invalidate(creditProgramsProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _CreditEmpty(
                onRetry: () => ref.invalidate(creditProgramsProvider),
              );
            }
            return flow.when(
              loading: () => const _CreditLoading(),
              error: (_, __) => _CreditLoadError(
                onRetry: () => ref.invalidate(creditFlowProvider),
              ),
              data: (state) {
                _flowController = ref.read(creditFlowProvider.notifier);
                _latestDraft = state.draft;
                _hydrate(state.draft);
                if (!_entryContextApplied) {
                  _entryContextApplied = true;
                  final linkedProgram = items
                      .where((item) => item.id == widget.sourceProgramId)
                      .firstOrNull;
                  if (widget.sourceAppraisalId != null) {
                    _tradeInController.clear();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final notifier = ref.read(creditFlowProvider.notifier);
                    () async {
                      await notifier.setCampaignSource(
                        widget.campaignSource,
                      );
                      await notifier.setSourceAppraisal(
                        widget.sourceAppraisalId,
                      );
                      if (linkedProgram != null) {
                        _cashController.text = formatRupiahAmount(
                          (linkedProgram.suggestedDpAmount -
                                  linkedProgram.approvedDiscount)
                              .clamp(0, linkedProgram.otrPrice),
                        );
                        await notifier.selectProgram(linkedProgram);
                      }
                    }();
                  });
                }
                final selected = items
                    .where((item) => item.id == state.draft.programId)
                    .firstOrNull;
                return _CreditForm(
                  formKey: _formKey,
                  state: state,
                  programs: items,
                  selectedProgram: selected,
                  cashController: _cashController,
                  tradeInController: _tradeInController,
                  payoffController: _payoffController,
                  onProgramChanged: (program) async {
                    if (program == null) return;
                    _cashController.text = formatRupiahAmount(
                      (program.suggestedDpAmount - program.approvedDiscount)
                          .clamp(0, program.otrPrice),
                    );
                    await ref
                        .read(creditFlowProvider.notifier)
                        .selectProgram(program);
                  },
                  onUseTradeInChanged: (value) => ref
                      .read(creditFlowProvider.notifier)
                      .updateInputs(
                        cashDownPayment: _amount(_cashController),
                        manualTradeInValue: _manualTradeInAmount(state.draft),
                        useTradeInAsDp: value,
                        oldVehiclePayoff: _amount(_payoffController),
                        tenorMonths: state.draft.tenorMonths ??
                            selected?.tenorOptions.first.tenorMonths ??
                            1,
                        acceptExpiredAppraisal:
                            state.draft.acceptExpiredAppraisal,
                      ),
                  onTenorChanged: (value) {
                    if (value == null) return;
                    ref.read(creditFlowProvider.notifier).updateInputs(
                          cashDownPayment: _amount(_cashController),
                          manualTradeInValue: _manualTradeInAmount(state.draft),
                          useTradeInAsDp: state.draft.useTradeInAsDp,
                          oldVehiclePayoff: _amount(_payoffController),
                          tenorMonths: value,
                          acceptExpiredAppraisal:
                              state.draft.acceptExpiredAppraisal,
                        );
                  },
                  onExpiredConsentChanged: (value) => ref
                      .read(creditFlowProvider.notifier)
                      .updateInputs(
                        cashDownPayment: _amount(_cashController),
                        manualTradeInValue: _manualTradeInAmount(state.draft),
                        useTradeInAsDp: state.draft.useTradeInAsDp,
                        oldVehiclePayoff: _amount(_payoffController),
                        tenorMonths: state.draft.tenorMonths ??
                            selected?.tenorOptions.first.tenorMonths ??
                            1,
                        acceptExpiredAppraisal: value,
                      ),
                  onMoneyChanged: (_) => _scheduleDraftSave(),
                  onCalculate: () => _calculate(state.draft),
                  onAddScenario: () =>
                      ref.read(creditFlowProvider.notifier).addScenario(),
                  onShare: () => _share(state.calculation!),
                  onSave: () => ref.read(creditFlowProvider.notifier).save(),
                  onFollowUp: _showFollowUp,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CreditForm extends StatelessWidget {
  const _CreditForm({
    required this.formKey,
    required this.state,
    required this.programs,
    required this.selectedProgram,
    required this.cashController,
    required this.tradeInController,
    required this.payoffController,
    required this.onProgramChanged,
    required this.onUseTradeInChanged,
    required this.onTenorChanged,
    required this.onExpiredConsentChanged,
    required this.onMoneyChanged,
    required this.onCalculate,
    required this.onAddScenario,
    required this.onShare,
    required this.onSave,
    required this.onFollowUp,
  });

  final GlobalKey<FormState> formKey;
  final CreditFlowState state;
  final List<CreditProgram> programs;
  final CreditProgram? selectedProgram;
  final TextEditingController cashController;
  final TextEditingController tradeInController;
  final TextEditingController payoffController;
  final ValueChanged<CreditProgram?> onProgramChanged;
  final ValueChanged<bool> onUseTradeInChanged;
  final ValueChanged<int?> onTenorChanged;
  final ValueChanged<bool> onExpiredConsentChanged;
  final ValueChanged<String> onMoneyChanged;
  final VoidCallback onCalculate;
  final VoidCallback onAddScenario;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.creditFlowSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  _SectionTitle(
                    title: l10n.creditProgramLabel,
                    subtitle: l10n.creditProgramHelper,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  DropdownButtonFormField<CreditProgram>(
                    key: ValueKey(
                      'credit-program-${selectedProgram?.id ?? 'none'}',
                    ),
                    initialValue: selectedProgram,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.creditTargetVehicle,
                    ),
                    items: programs
                        .map(
                          (program) => DropdownMenuItem(
                            value: program,
                            child: Text(
                              '${program.isSpekta ? '${l10n.creditSpektaBadge} · ' : ''}'
                              '${program.isDemo ? '${l10n.creditDemoBadge} · ' : ''}'
                              '${program.vehicleLabel} · ${program.city} · '
                              '${program.partnerName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    selectedItemBuilder: (context) => programs
                        .map(
                          (program) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${program.isSpekta ? '${l10n.creditSpektaBadge} · ' : ''}'
                              '${program.isDemo ? '${l10n.creditDemoBadge} · ' : ''}'
                              '${program.programName} · '
                              '${program.vehicleModel} · ${program.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onProgramChanged,
                    validator: (value) =>
                        value == null ? l10n.fieldRequired : null,
                  ),
                  if (selectedProgram != null) ...[
                    const SizedBox(height: AppSpacing.medium),
                    _ProgramMeta(program: selectedProgram!),
                    const SizedBox(height: AppSpacing.xLarge),
                    _SectionTitle(title: l10n.creditDownPaymentSection),
                    const SizedBox(height: AppSpacing.medium),
                    _MoneyField(
                      controller: cashController,
                      label: l10n.creditCashDownPayment,
                      onChanged: onMoneyChanged,
                      validator: (value) => _validateDownPayment(
                        context,
                        selectedProgram!,
                        value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (state.draft.tradeInAppraisalId != null)
                      _AppraisalNotice(
                        accepted: state.draft.acceptExpiredAppraisal,
                        onChanged: onExpiredConsentChanged,
                      )
                    else
                      _MoneyField(
                        controller: tradeInController,
                        label: l10n.creditTradeInManual,
                        required: false,
                        onChanged: onMoneyChanged,
                        validator: (value) {
                          if (!state.draft.useTradeInAsDp) return null;
                          return rupiahValueOf(value ?? '') <= 0
                              ? l10n.creditTradeInRequired
                              : null;
                        },
                      ),
                    const SizedBox(height: AppSpacing.small),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: state.draft.useTradeInAsDp,
                      onChanged: onUseTradeInChanged,
                      title: Text(l10n.creditUseTradeInAsDp),
                    ),
                    if (state.draft.useTradeInAsDp) ...[
                      const SizedBox(height: AppSpacing.small),
                      _MoneyField(
                        controller: payoffController,
                        label: l10n.creditOldVehiclePayoff,
                        required: false,
                        onChanged: onMoneyChanged,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xLarge),
                    _SectionTitle(
                      title: l10n.creditTenorSection,
                      subtitle: l10n.creditTenorSectionHelper,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    DropdownButtonFormField<int>(
                      key: ValueKey(
                        'credit-tenor-${selectedProgram!.id}-'
                        '${_selectedTenor(selectedProgram!)}',
                      ),
                      initialValue: _selectedTenor(selectedProgram!),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.creditTenor,
                      ),
                      items: selectedProgram!.tenorOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option.tenorMonths,
                              child: Text(
                                '${option.tenorMonths} ${l10n.creditMonths} · '
                                '${creditRate(
                                  option.annualFlatRateBasisPoints,
                                )}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: onTenorChanged,
                      validator: (value) =>
                          value == null ? l10n.fieldRequired : null,
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      _InlineError(message: _errorText(context, state.error!)),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.isCalculating ? null : onCalculate,
                        icon: state.isCalculating
                            ? const SizedBox.square(
                                dimension: AppIconSize.medium,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.calculate_rounded),
                        label: Text(
                          state.isCalculating
                              ? l10n.creditCalculating
                              : l10n.creditCalculate,
                        ),
                      ),
                    ),
                  ],
                  if (state.calculation != null) ...[
                    const SizedBox(height: AppSpacing.xxLarge),
                    Text(
                      l10n.creditResultTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CreditResultSummary(
                      calculation: state.calculation!,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.small,
                      children: [
                        OutlinedButton.icon(
                          onPressed: state.scenarios.length >= 3
                              ? null
                              : onAddScenario,
                          icon: const Icon(Icons.compare_arrows_rounded),
                          label: Text(l10n.creditAddComparison),
                        ),
                        OutlinedButton.icon(
                          onPressed: onShare,
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.creditShareSummary),
                        ),
                        FilledButton.icon(
                          onPressed: state.isSaving ? null : onSave,
                          icon: state.isSaving
                              ? const SizedBox.square(
                                  dimension: AppIconSize.medium,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            state.isSaving
                                ? l10n.creditSaving
                                : l10n.creditSave,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (state.scenarios.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxLarge),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.creditComparisonTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(l10n.creditScenarioCount(
                          state.scenarios.length,
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CreditComparisonTable(scenarios: state.scenarios),
                  ],
                  if (state.savedSimulation != null) ...[
                    const SizedBox(height: AppSpacing.xxLarge),
                    _SavedPanel(
                      simulation: state.savedSimulation!,
                      busy: state.isRequestingFollowUp,
                      onView: () => context.push(
                        creditSimulationPath(state.savedSimulation!.id),
                      ),
                      onFollowUp: onFollowUp,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _errorText(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    return switch (error) {
      'scenario_limit' => l10n.creditScenarioLimit,
      'scenario_duplicate' => l10n.creditScenarioDuplicate,
      'general' => l10n.errorGeneral,
      _ => error,
    };
  }

  int? _selectedTenor(CreditProgram program) {
    final tenor = state.draft.tenorMonths;
    return program.tenorOptions.any((item) => item.tenorMonths == tenor)
        ? tenor
        : null;
  }

  String? _validateDownPayment(
    BuildContext context,
    CreditProgram program,
    String? rawValue,
  ) {
    // Nilai yang dibaca sudah berpemisah ribuan, jadi pemisahnya dibuang
    // dulu sebelum dihitung.
    if (digitsOnly(rawValue ?? '').isEmpty) return null;
    final cash = rupiahValueOf(rawValue ?? '');
    final hasAppraisal = state.draft.tradeInAppraisalId != null;
    final manualTradeIn = rupiahValueOf(tradeInController.text);
    final payoff = rupiahValueOf(payoffController.text);
    final usesKnownTradeIn = state.draft.useTradeInAsDp && !hasAppraisal;
    if (usesKnownTradeIn && manualTradeIn <= 0) return null;

    var total = cash + program.approvedDiscount;
    if (usesKnownTradeIn) {
      total += max(manualTradeIn - payoff, 0);
    }
    final l10n = AppLocalizations.of(context)!;
    if ((!state.draft.useTradeInAsDp || !hasAppraisal) &&
        total < program.minimumDpAmount) {
      return l10n.creditDpBelowMinimum(
        creditMoney(program.minimumDpAmount),
      );
    }
    final maximum = min(program.maximumDpAmount, program.otrPrice);
    if (total > maximum) {
      return l10n.creditDpAboveMaximum(creditMoney(maximum));
    }
    return null;
  }
}

class _ProgramMeta extends StatelessWidget {
  const _ProgramMeta({required this.program});

  final CreditProgram program;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (program.isDemo) ...[
          _DemoProgramNotice(message: l10n.creditDemoProgramNotice),
          const SizedBox(height: AppSpacing.medium),
        ],
        _MetaRow(label: l10n.creditProgramName, value: program.programName),
        _MetaRow(label: l10n.creditPartner, value: program.partnerName),
        _MetaRow(label: l10n.creditOtrCity, value: program.city),
        _MetaRow(
          label: l10n.creditOtrPrice,
          value: creditMoney(program.otrPrice),
        ),
        if (program.recommendedDpAmount != null)
          _MetaRow(
            label: l10n.creditRecommendedDp,
            value: creditMoney(program.recommendedDpAmount!),
          ),
        _MetaRow(
          label: l10n.creditDpRange,
          value: '${creditMoney(program.minimumDpAmount)} – '
              '${creditMoney(program.maximumDpAmount)}',
        ),
        if (program.approvedDiscount > 0)
          _MetaRow(
            label: l10n.creditApprovedDiscount,
            value: creditMoney(program.approvedDiscount),
          ),
        const SizedBox(height: AppSpacing.small),
        Text(
          program.disclaimer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _DemoProgramNotice extends StatelessWidget {
  const _DemoProgramNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.science_outlined, color: colors.onTertiaryContainer),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppraisalNotice extends StatelessWidget {
  const _AppraisalNotice({
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.price_check_outlined),
                const SizedBox(width: AppSpacing.small),
                Expanded(child: Text(l10n.creditDraftAppraisalNotice)),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (value) => onChanged(value ?? false),
              title: Text(l10n.creditExpiredAppraisalConsent),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPanel extends StatelessWidget {
  const _SavedPanel({
    required this.simulation,
    required this.busy,
    required this.onView,
    required this.onFollowUp,
  });

  final CreditSimulation simulation;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.creditSavedTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              '${simulation.referenceNo}\n${l10n.creditSavedDescription}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                OutlinedButton(
                  onPressed: onView,
                  child: Text(l10n.creditViewSaved),
                ),
                if (simulation.followUp == null)
                  FilledButton(
                    onPressed: busy ? null : onFollowUp,
                    child: Text(l10n.creditRequestSales),
                  )
                else
                  Text(simulation.followUp!.statusLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    this.required = true,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
        const RupiahInputFormatter(),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rp ',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return required ? l10n.fieldRequired : null;
        }
        if (rupiahValueOf(value) <= 0) return l10n.creditInvalidNumber;
        return validator?.call(value);
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditLoading extends StatelessWidget {
  const _CreditLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.xLarge),
        for (final factor in [1.0, 0.72, 0.86])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: FractionallySizedBox(
              widthFactor: factor,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: AppSpacing.xLarge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: AppRadius.small,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CreditLoadError extends StatelessWidget {
  const _CreditLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: AppIconSize.service),
            const SizedBox(height: AppSpacing.medium),
            Text(
              l10n.creditLoadFailed,
              textAlign: TextAlign.center,
            ),
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

class _CreditEmpty extends StatelessWidget {
  const _CreditEmpty({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        children: [
          const SizedBox(height: AppSpacing.xxLarge),
          const Icon(Icons.calculate_outlined, size: AppIconSize.hero),
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.creditNoProgramsTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.creditNoProgramsDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          Center(
            child: OutlinedButton.icon(
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
