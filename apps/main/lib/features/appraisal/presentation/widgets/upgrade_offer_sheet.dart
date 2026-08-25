import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/appraisal_models.dart';

String _money(int value) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

/// Pop-up dua opsi unit baru yang uang mukanya tertutup harga appraisal.
///
/// Notulensi 19 Agustus 2026 meminta opsi ini muncul langsung begitu hasil
/// appraisal terbit, menggantikan rentang harga dan data pembanding yang
/// dihapus. Mengembalikan program yang dipilih pelanggan, atau null bila
/// pop-up ditutup.
Future<AppraisalUpgradeOption?> showUpgradeOfferSheet(
  BuildContext context, {
  required AppraisalUpgradeOffer offer,
}) {
  return showModalBottomSheet<AppraisalUpgradeOption>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _UpgradeOfferSheet(offer: offer),
  );
}

class _UpgradeOfferSheet extends StatelessWidget {
  const _UpgradeOfferSheet({required this.offer});

  final AppraisalUpgradeOffer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      // Judul dan tombol tutup tetap terlihat; hanya daftar opsinya yang
      // digulir, supaya pelanggan di layar kecil tidak terjebak di pop-up.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            0,
            AppSpacing.large,
            AppSpacing.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.upgradeOfferTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                l10n.upgradeOfferSubtitle(_money(offer.tradeInValue)),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.large),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in offer.options) ...[
                        _UpgradeOptionCard(
                          option: option,
                          onTap: () => Navigator.of(context).pop(option),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                      ],
                    ],
                  ),
                ),
              ),
              Text(
                l10n.upgradeOfferEstimateNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.small),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.upgradeOfferDismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeOptionCard extends StatelessWidget {
  const _UpgradeOptionCard({required this.option, required this.onTap});

  final AppraisalUpgradeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.vehicleLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                '${option.partnerName} · ${_money(option.otrPrice)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.upgradeOfferInstallment(option.tenorMonths),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                        ),
                        Text(
                          _money(option.monthlyInstallment),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.upgradeOfferDownPayment,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        _money(option.downPaymentFromAppraisal),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              FilledButton(
                onPressed: onTap,
                child: Text(l10n.upgradeOfferSimulate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
