import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/credit_models.dart';

String creditMoney(int value) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

String creditRate(int basisPoints) => NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: 2,
    ).format(basisPoints / 100);

String creditShareText(
  BuildContext context,
  CreditCalculation calculation,
) {
  final l10n = AppLocalizations.of(context)!;
  return [
    l10n.creditFlowTitle,
    if (calculation.isDemoProgram) l10n.creditDemoProgramNotice,
    '${l10n.creditMonthlyInstallment}: '
        '${creditMoney(calculation.monthlyInstallment)}',
    '${l10n.creditInitialPayment}: '
        '${creditMoney(calculation.initialPayment)}',
    '${l10n.creditTenor}: '
        '${calculation.tenorMonths} ${l10n.creditMonths}',
    '${l10n.creditRatePerYear}: '
        '${creditRate(calculation.annualFlatRateBasisPoints)}%',
    '${l10n.creditTotalPayment}: '
        '${creditMoney(calculation.totalPayment)}',
    calculation.disclaimer,
  ].join('\n');
}

class CreditResultSummary extends StatelessWidget {
  const CreditResultSummary({
    required this.calculation,
    this.showSource = true,
    super.key,
  });

  final CreditCalculation calculation;
  final bool showSource;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final programName = calculation.program['program_name']?.toString() ?? '-';
    final partnerName = calculation.program['partner_name']?.toString() ?? '-';
    final source = calculation.program['source_reference']?.toString() ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (calculation.isDemoProgram) ...[
          _ResultNotice(
            message: l10n.creditDemoProgramNotice,
            icon: Icons.science_outlined,
            background: colors.tertiaryContainer,
            foreground: colors.onTertiaryContainer,
          ),
          const SizedBox(height: AppSpacing.medium),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.creditMonthlyInstallment,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSecondaryContainer,
                      ),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  creditMoney(calculation.monthlyInstallment),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  '$programName · $partnerName · '
                  '${calculation.tenorMonths} ${l10n.creditMonths}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        _BreakdownRow(
          label: l10n.creditOtrPrice,
          value: creditMoney(calculation.otrPrice),
        ),
        _BreakdownRow(
          label: l10n.creditCashDownPayment,
          value: creditMoney(calculation.cashDownPayment),
        ),
        if (calculation.tradeInValue > 0)
          _BreakdownRow(
            label: l10n.creditTradeInEquity,
            value: creditMoney(calculation.tradeInEquity),
          ),
        if (calculation.approvedDiscount > 0)
          _BreakdownRow(
            label: l10n.creditApprovedDiscount,
            value: creditMoney(calculation.approvedDiscount),
          ),
        _BreakdownRow(
          label: l10n.creditTotalDownPayment,
          value: creditMoney(calculation.totalDownPayment),
          emphasized: true,
        ),
        _BreakdownRow(
          label: l10n.creditPrincipal,
          value: creditMoney(calculation.principal),
        ),
        _BreakdownRow(
          label: l10n.creditRatePerYear,
          value: '${creditRate(
            calculation.annualFlatRateBasisPoints,
          )}%',
        ),
        _BreakdownRow(
          label: l10n.creditTotalInterest,
          value: creditMoney(calculation.totalFlatInterest),
        ),
        _BreakdownRow(
          label: l10n.creditAdministrationFee,
          value: calculation.administrationFee == 0
              ? l10n.creditFeeNotIncluded
              : creditMoney(calculation.administrationFee),
        ),
        _BreakdownRow(
          label: l10n.creditProvisionFee,
          value: calculation.provisionFee == 0
              ? l10n.creditFeeNotIncluded
              : creditMoney(calculation.provisionFee),
        ),
        _BreakdownRow(
          label: l10n.creditInsuranceFee,
          value: calculation.upfrontInsurance == 0
              ? l10n.creditFeeNotIncluded
              : creditMoney(calculation.upfrontInsurance),
        ),
        if (calculation.otherUpfrontCosts > 0)
          _BreakdownRow(
            label: calculation.otherUpfrontCostLabel ?? l10n.creditOtherFee,
            value: creditMoney(calculation.otherUpfrontCosts),
          ),
        _BreakdownRow(
          label: l10n.creditInitialPayment,
          value: creditMoney(calculation.initialPayment),
          emphasized: true,
        ),
        _BreakdownRow(
          label: l10n.creditTotalPayment,
          value: creditMoney(calculation.totalPayment),
          emphasized: true,
        ),
        if (calculation.validUntil != null)
          _BreakdownRow(
            label: l10n.creditValidUntil,
            value: DateFormat(
              'd MMMM yyyy',
              Localizations.localeOf(context).toLanguageTag(),
            ).format(calculation.validUntil!.toLocal()),
          ),
        if (showSource) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            '${l10n.creditSource}: $source',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
        if (calculation.warnings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          for (final warning in calculation.warnings) ...[
            _ResultNotice(
              message: _creditWarningText(context, warning),
              icon: Icons.warning_amber_rounded,
              background: colors.errorContainer,
              foreground: colors.onErrorContainer,
            ),
            const SizedBox(height: AppSpacing.small),
          ],
        ],
        const SizedBox(height: AppSpacing.medium),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: AppRadius.medium,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    calculation.disclaimer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _creditWarningText(BuildContext context, String warning) {
  final l10n = AppLocalizations.of(context)!;
  return switch (warning) {
    'Hasil appraisal sudah kedaluwarsa dan perlu verifikasi ulang.' =>
      l10n.creditExpiredAppraisalWarning,
    _ => warning,
  };
}

class _ResultNotice extends StatelessWidget {
  const _ResultNotice({
    required this.message,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String message;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.medium,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
}

class CreditComparisonTable extends StatelessWidget {
  const CreditComparisonTable({
    required this.scenarios,
    super.key,
  });

  final List<CreditCalculation> scenarios;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final width = 128.0 * scenarios.length + 144;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: colors.outlineVariant),
          ),
          columnWidths: {
            0: const FixedColumnWidth(144),
            for (var index = 0; index < scenarios.length; index++)
              index + 1: const FixedColumnWidth(128),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _row(
              context,
              l10n.creditTenor,
              scenarios
                  .map((item) => '${item.tenorMonths} ${l10n.creditMonths}')
                  .toList(),
              header: true,
            ),
            _row(
              context,
              l10n.creditTotalDownPayment,
              scenarios
                  .map((item) => creditMoney(item.totalDownPayment))
                  .toList(),
            ),
            _row(
              context,
              l10n.creditMonthlyInstallment,
              scenarios
                  .map((item) => creditMoney(item.monthlyInstallment))
                  .toList(),
            ),
            _row(
              context,
              l10n.creditTotalInterest,
              scenarios
                  .map((item) => creditMoney(item.totalFlatInterest))
                  .toList(),
            ),
            _row(
              context,
              l10n.creditTotalPayment,
              scenarios.map((item) => creditMoney(item.totalPayment)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _row(
    BuildContext context,
    String label,
    List<String> values, {
    bool header = false,
  }) {
    final style = header
        ? Theme.of(context).textTheme.labelLarge
        : Theme.of(context).textTheme.bodySmall;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.medium,
            horizontal: AppSpacing.small,
          ),
          child: Text(label, style: style),
        ),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.medium,
              horizontal: AppSpacing.small,
            ),
            child: Text(
              value,
              style: style?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = emphasized
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: style?.copyWith(
                color: emphasized ? null : colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: style?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
