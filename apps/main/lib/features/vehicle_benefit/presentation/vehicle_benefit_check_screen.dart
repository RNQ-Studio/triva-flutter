import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../otoxpert/presentation/otoxpert_paths.dart';
import '../../toyota_service/presentation/toyota_service_paths.dart';
import '../domain/vehicle_benefit_models.dart';
import 'vehicle_benefit_controller.dart';

/// Pemeriksaan mandiri No. Rangka terhadap kampanye SSC dan sisa T-Care.
///
/// Notulensi 19 Agustus 2026 meminta halaman ini supaya pelanggan yang masih
/// punya fasilitas T-Care terarahkan servis ke Auto2000 alih-alih OtoXpert.
class VehicleBenefitCheckScreen extends ConsumerStatefulWidget {
  const VehicleBenefitCheckScreen({super.key});

  @override
  ConsumerState<VehicleBenefitCheckScreen> createState() =>
      _VehicleBenefitCheckScreenState();
}

class _VehicleBenefitCheckScreenState
    extends ConsumerState<VehicleBenefitCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vin = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _vin.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (!_formKey.currentState!.validate()) return;
    final year = int.tryParse(_year.text.trim());
    await ref.read(vehicleBenefitCheckProvider.notifier).check(
          vin: _vin.text.trim(),
          year: year,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(vehicleBenefitCheckProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.benefitCheckTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            Text(
              l10n.benefitCheckSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.large),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _vin,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.benefitCheckVin,
                      helperText: l10n.benefitCheckVinHint,
                    ),
                    validator: (value) => (value ?? '').trim().length < 5
                        ? l10n.benefitCheckVinRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.benefitCheckYear,
                    ),
                    validator: (value) {
                      final raw = (value ?? '').trim();
                      if (raw.isEmpty) return null;
                      final year = int.tryParse(raw);
                      if (year == null ||
                          year < 1980 ||
                          year > DateTime.now().year + 1) {
                        return l10n.benefitCheckYearInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton(
                    onPressed: state.isChecking ? null : _check,
                    child: state.isChecking
                        ? const SizedBox.square(
                            dimension: AppIconSize.medium,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.benefitCheckSubmit),
                  ),
                ],
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: AppSpacing.large),
              Text(
                l10n.errorGeneral,
                style: TextStyle(color: colors.error),
              ),
            ],
            if (state.result != null) ...[
              const SizedBox(height: AppSpacing.xLarge),
              _SscCard(status: state.result!.ssc),
              const SizedBox(height: AppSpacing.medium),
              _TCareCard(status: state.result!.tCare),
              const SizedBox(height: AppSpacing.medium),
              _RecommendationCard(
                recommendation: state.result!.recommendation,
                onBook: () => context.push(
                  state.result!.recommendation.isToyotaService
                      ? toyotaServiceVehiclePath
                      : otoxpertBookingIntakePath,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SscCard extends StatelessWidget {
  const _SscCard({required this.status});

  final SscStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tone = status.isAffected
        ? colors.errorContainer
        : status.isUnverified
            ? colors.surfaceContainerHighest
            : colors.secondaryContainer;

    return Card(
      margin: EdgeInsets.zero,
      color: tone,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.benefitCheckSscTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              status.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(status.message),
            for (final campaign in status.campaigns) ...[
              const Divider(height: AppSpacing.xLarge),
              Text(
                '${campaign.campaignCode} - ${campaign.title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (campaign.description != null)
                Text(
                  campaign.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (campaign.recommendedAction != null)
                Text(
                  campaign.recommendedAction!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TCareCard extends StatelessWidget {
  const _TCareCard({required this.status});

  final TCareStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.benefitCheckTcareTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              status.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (status.isActive && status.monthsRemaining != null) ...[
              const SizedBox(height: AppSpacing.xSmall),
              Text(l10n.benefitCheckTcareRemaining(status.monthsRemaining!)),
            ],
            if (status.expiresOn != null)
              Text(
                l10n.benefitCheckTcareUntil(status.expiresOn!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(status.message),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onBook,
  });

  final BenefitRecommendation recommendation;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              recommendation.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              recommendation.message,
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: AppSpacing.medium),
            FilledButton(
              onPressed: onBook,
              child: Text(recommendation.title),
            ),
          ],
        ),
      ),
    );
  }
}
