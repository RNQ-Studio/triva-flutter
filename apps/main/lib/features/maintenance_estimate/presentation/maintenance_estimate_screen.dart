import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../toyota_service/presentation/toyota_service_paths.dart';
import '../domain/maintenance_estimate_models.dart';
import 'maintenance_estimate_controller.dart';

String _money(int value) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

/// Simulasi biaya servis berkala sebelum pelanggan memutuskan booking.
///
/// Diminta notulensi 19 Agustus 2026: "simulasi penghitungan biaya service -
/// khusus berkala saja misalnya / just ganti oli".
class MaintenanceEstimateScreen extends ConsumerStatefulWidget {
  const MaintenanceEstimateScreen({super.key});

  @override
  ConsumerState<MaintenanceEstimateScreen> createState() =>
      _MaintenanceEstimateScreenState();
}

class _MaintenanceEstimateScreenState
    extends ConsumerState<MaintenanceEstimateScreen> {
  final _mileage = TextEditingController();
  final _model = TextEditingController();

  @override
  void dispose() {
    _mileage.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _estimate() async {
    await ref.read(maintenanceEstimateProvider.notifier).estimate(
          vehicleModel: _model.text,
          mileage:
              int.tryParse(_mileage.text.replaceAll(RegExp(r'[^0-9]'), '')),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(maintenanceEstimateProvider);
    final colors = Theme.of(context).colorScheme;
    final estimate = state.estimate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenanceEstimateTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            Text(
              l10n.maintenanceEstimateSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.large),
            TextField(
              controller: _model,
              decoration: InputDecoration(
                labelText: l10n.maintenanceEstimateModel,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: _mileage,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.maintenanceEstimateMileage,
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton(
              onPressed: state.isLoading ? null : _estimate,
              child: state.isLoading
                  ? const SizedBox.square(
                      dimension: AppIconSize.medium,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.maintenanceEstimateSubmit),
            ),
            if (state.error != null) ...[
              const SizedBox(height: AppSpacing.large),
              Text(l10n.errorGeneral, style: TextStyle(color: colors.error)),
            ],
            if (estimate != null && !estimate.hasPackages) ...[
              const SizedBox(height: AppSpacing.xLarge),
              Text(l10n.maintenanceEstimateEmpty),
            ],
            if (estimate?.recommended != null) ...[
              const SizedBox(height: AppSpacing.xLarge),
              _PackageCard(
                package: estimate!.recommended!,
                highlighted: true,
              ),
              const SizedBox(height: AppSpacing.medium),
              FilledButton.icon(
                onPressed: () => context.push(toyotaServiceVehiclePath),
                icon: const Icon(Icons.event_available_outlined),
                label: Text(l10n.maintenanceEstimateBook),
              ),
              if (estimate.packages.length > 1) ...[
                const SizedBox(height: AppSpacing.xLarge),
                Text(
                  l10n.maintenanceEstimateOtherPackages,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.medium),
                for (final package in estimate.packages)
                  if (package.id != estimate.recommended!.id) ...[
                    _PackageCard(package: package, highlighted: false),
                    const SizedBox(height: AppSpacing.medium),
                  ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.highlighted});

  final MaintenancePackage package;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: highlighted ? colors.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: highlighted ? colors.onPrimaryContainer : null,
                  ),
            ),
            if (package.description != null) ...[
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                package.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            _CostRow(
              label: l10n.maintenanceEstimateParts,
              value: _money(package.partsCost),
            ),
            _CostRow(
              label: l10n.maintenanceEstimateLabor,
              value: _money(package.laborCost),
            ),
            const Divider(height: AppSpacing.xLarge),
            _CostRow(
              label: l10n.maintenanceEstimateTotal,
              value: _money(package.totalCost),
              emphasized: true,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.maintenanceEstimateDuration(
                package.durationMinMinutes,
                package.durationMaxMinutes,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (package.includes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                l10n.maintenanceEstimateIncludes,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              for (final item in package.includes) Text('- $item'),
            ],
            if (package.disclaimer != null) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                package.disclaimer!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      // Label panjang berdampingan dengan nominal enam digit tidak muat di
      // layar sempit, jadi labelnya yang mengalah.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppSpacing.small),
          Text(value, style: style),
        ],
      ),
    );
  }
}
