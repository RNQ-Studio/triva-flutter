import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../contact/presentation/whatsapp_handoff.dart';
import '../../../sales_contact/presentation/sales_contact_picker.dart';
import '../../domain/acc_credit_formula.dart';
import '../../domain/credit_models.dart';
import '../credit_controller.dart';
import '../credit_paths.dart';
import 'widgets/credit_result_sections.dart';

/// Simulasi kredit cepat ACC (revisi 4 September 2026).
///
/// Pelanggan memilih unit, mengisi harga OTR, memilih DP 20/25/30% dan tenor
/// 1-5 tahun; angsuran per bulan langsung terlihat. "Hitung simulasi"
/// menyimpan hasil di server dan memberi notifikasi admin; "Konsultasi lebih
/// lanjut" membuka pilihan SPV & sales untuk WhatsApp.
class CreditQuickScreen extends ConsumerStatefulWidget {
  const CreditQuickScreen({super.key, this.sourceProgramId});

  final String? sourceProgramId;

  @override
  ConsumerState<CreditQuickScreen> createState() => _CreditQuickScreenState();
}

class _CreditQuickScreenState extends ConsumerState<CreditQuickScreen> {
  final _otrController = TextEditingController();
  CreditProgram? _program;
  int _dpPercent = 20;
  int _tenorYears = 5;
  bool _submitting = false;
  CreditSimulation? _saved;
  String? _error;

  @override
  void dispose() {
    _otrController.dispose();
    super.dispose();
  }

  int get _otrPrice => rupiahValueOf(_otrController.text);

  void _selectProgram(CreditProgram? program) {
    if (program == null) return;
    setState(() {
      _program = program;
      _otrController.text = formatRupiahAmount(program.otrPrice);
      _saved = null;
      _error = null;
    });
  }

  void _ensureInitialProgram(List<CreditProgram> programs) {
    if (_program != null || programs.isEmpty) return;
    final preferred = widget.sourceProgramId == null
        ? null
        : programs.where((p) => p.id == widget.sourceProgramId).firstOrNull;
    final program = preferred ?? programs.first;
    _program = program;
    _otrController.text = formatRupiahAmount(program.otrPrice);
  }

  AccCreditQuote? _quote(AccRateCard? card) {
    final program = _program;
    if (card == null || program == null) return null;
    return AccCreditFormula(card).quote(
      otrPrice: _otrPrice,
      dpPercent: _dpPercent,
      tenorYears: _tenorYears,
      vehicleModel: program.vehicleModel,
    );
  }

  Future<void> _submit() async {
    final program = _program;
    final l10n = AppLocalizations.of(context)!;
    if (program == null || _submitting) return;
    if (_otrPrice < 10000000) {
      setState(() => _error = l10n.creditQuickOtrInvalid);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final saved = await ref.read(creditRepositoryProvider).quickSimulate(
            programId: program.id,
            otrPrice: _otrPrice,
            dpPercent: _dpPercent,
            tenorYears: _tenorYears,
          );
      ref.invalidate(creditSimulationsProvider);
      if (!mounted) return;
      setState(() => _saved = saved);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.creditQuickSubmitted)));
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = friendlyCreditError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _consult(AccCreditQuote? quote) async {
    final l10n = AppLocalizations.of(context)!;
    final program = _program;
    final opened = await pickSalesAndOpenWhatsApp(
      context,
      ref,
      message: branchWhatsAppMessage(
        title: l10n.whatsappCreditTitle,
        details: {
          l10n.whatsappHandoffReference: _saved?.referenceNo,
          l10n.whatsappHandoffUnit: program?.vehicleLabel,
          l10n.whatsappHandoffOtr:
              _otrPrice > 0 ? creditMoney(_otrPrice) : null,
          l10n.whatsappHandoffDownPayment: quote == null
              ? '$_dpPercent%'
              : '$_dpPercent% (${creditMoney(quote.downPayment)})',
          l10n.whatsappHandoffTenor: l10n.creditQuickYears(_tenorYears),
          l10n.whatsappHandoffInstallment:
              quote == null ? null : creditMoney(quote.monthlyInstallment),
        },
      ),
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappHandoffFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final programsAsync = ref.watch(creditProgramsProvider);
    final cardAsync = ref.watch(creditRateCardProvider);
    final programs = programsAsync.value ?? const <CreditProgram>[];
    _ensureInitialProgram(programs);
    final card = cardAsync.value;
    final quote = _quote(card);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditFlowTitle)),
      body: SafeArea(
        child: programsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _Retry(
            message: l10n.loadFailed,
            onRetry: () => ref.invalidate(creditProgramsProvider),
          ),
          data: (_) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.creditQuickSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xLarge),
                      DropdownButtonFormField<CreditProgram>(
                        key: ValueKey('quick-unit-${_program?.id ?? 'none'}'),
                        initialValue: _program,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.creditQuickUnit,
                        ),
                        items: [
                          for (final program in programs)
                            DropdownMenuItem(
                              value: program,
                              child: Text(
                                program.vehicleLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _selectProgram,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        key: const ValueKey('quick-otr'),
                        controller: _otrController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                          const RupiahInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.creditOtrPrice,
                          prefixText: 'Rp ',
                        ),
                        onChanged: (_) => setState(() {
                          _saved = null;
                          _error = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        l10n.creditQuickDpPercent,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      SegmentedButton<int>(
                        segments: [
                          for (final percent
                              in card?.dpPercentOptions ?? const [20, 25, 30])
                            ButtonSegment(
                              value: percent,
                              label: Text('$percent%'),
                            ),
                        ],
                        selected: {_dpPercent},
                        onSelectionChanged: (values) => setState(() {
                          _dpPercent = values.first;
                          _saved = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        l10n.creditQuickTenorYears,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: [
                          for (final years in card?.tenorYearsOptions ??
                              const [1, 2, 3, 4, 5])
                            ButtonSegment(
                              value: years,
                              label: Text('$years'),
                            ),
                        ],
                        selected: {_tenorYears},
                        onSelectionChanged: (values) => setState(() {
                          _tenorYears = values.first;
                          _saved = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(
                        l10n.creditQuickYears(_tenorYears),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xLarge),
                      if (cardAsync.isLoading)
                        const LinearProgressIndicator()
                      else if (cardAsync.hasError)
                        _Retry(
                          message: l10n.creditQuickRateCardError,
                          onRetry: () => ref.invalidate(creditRateCardProvider),
                        )
                      else if (quote != null)
                        _QuoteCard(quote: quote),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          _error!,
                          style: TextStyle(color: colors.error),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.large),
                      FilledButton.icon(
                        key: const ValueKey('quick-submit'),
                        onPressed:
                            _submitting || quote == null || _saved != null
                                ? null
                                : _submit,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: AppIconSize.medium,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.calculate_rounded),
                        label: Text(
                          _submitting
                              ? l10n.creditQuickSubmitting
                              : l10n.creditCalculate,
                        ),
                      ),
                      if (_saved != null) ...[
                        const SizedBox(height: AppSpacing.medium),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: AppRadius.large,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _saved!.referenceNo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: colors.onPrimaryContainer,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xSmall),
                                Text(
                                  l10n.creditQuickSubmitted,
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.small),
                      OutlinedButton.icon(
                        key: const ValueKey('quick-consult'),
                        onPressed:
                            _program == null ? null : () => _consult(quote),
                        icon: const Icon(Icons.chat_outlined),
                        label: Text(l10n.creditQuickConsult),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      TextButton(
                        onPressed: () => context.push(creditAdvancedPath),
                        child: Text(l10n.creditQuickAdvanced),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        l10n.creditEstimateDisclaimer,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final AccCreditQuote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.creditQuickInstallmentTitle,
              style: TextStyle(color: colors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                creditMoney(quote.monthlyInstallment),
                key: const ValueKey('quick-installment'),
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${quote.tenorMonths} ${l10n.creditMonths} · '
              '${l10n.creditQuickRate(creditRate(quote.annualFlatRateBps))}',
              style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: AppSpacing.medium),
            Divider(color: colors.onPrimary.withValues(alpha: 0.3)),
            _Line(l10n.creditQuickDownPayment, quote.downPayment),
            _Line(l10n.creditQuickInsurance, quote.insurancePremium),
            _Line(l10n.creditQuickAdminFee, quote.administrationFee),
            _Line(l10n.creditQuickLiabilityFee, quote.liabilityInsuranceFee),
            _Line(l10n.creditQuickFirstInstallment, quote.monthlyInstallment),
            Divider(color: colors.onPrimary.withValues(alpha: 0.3)),
            _Line(
              l10n.creditQuickTotalDownPayment,
              quote.totalDownPayment,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});

  final String label;
  final int value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = TextStyle(
      color: colors.onPrimary,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppSpacing.small),
          Text(creditMoney(value), style: style),
        ],
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.small),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}
