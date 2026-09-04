import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../maintenance_estimate/presentation/maintenance_estimate_paths.dart';
import '../../../vehicle_benefit/presentation/vehicle_benefit_paths.dart';
import '../../../visit_analytics/domain/menu_usage_models.dart';
import '../../../visit_analytics/presentation/visit_analytics_controller.dart';
import '../otoxpert_paths.dart';

/// Pintu masuk OtoXpert. Revisi 4 September 2026 memindahkan Cek No. Rangka
/// dan Simulasi Biaya Servis dari beranda ke dalam menu ini, di samping alur
/// booking bengkel OtoXpert.
class OtoxpertMenuScreen extends ConsumerWidget {
  const OtoxpertMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otoxpertMenuTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.xxLarge,
              ),
              children: [
                Text(
                  l10n.otoxpertMenuDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.large),
                OtoxpertMenuTile(
                  key: const ValueKey('otoxpert-menu-booking'),
                  icon: Icons.build_circle_outlined,
                  title: l10n.otoxpertFlowTitle,
                  description: l10n.otoxpertBookingSubtitle,
                  onTap: () {
                    trackMenuUsage(ref, MenuKey.otoxpert);
                    context.push(otoxpertBookingIntakePath);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                OtoxpertMenuTile(
                  key: const ValueKey('otoxpert-menu-benefit'),
                  icon: Icons.pin_outlined,
                  title: l10n.benefitCheckTitle,
                  description: l10n.benefitCheckSubtitle,
                  onTap: () {
                    trackMenuUsage(ref, MenuKey.vehicleBenefit);
                    context.push(vehicleBenefitCheckPath);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                OtoxpertMenuTile(
                  key: const ValueKey('otoxpert-menu-maintenance'),
                  icon: Icons.receipt_long_outlined,
                  title: l10n.maintenanceEstimateTitle,
                  description: l10n.maintenanceEstimateSubtitle,
                  onTap: () {
                    trackMenuUsage(ref, MenuKey.maintenanceEstimate);
                    context.push(maintenanceEstimatePath);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtoxpertMenuTile extends StatelessWidget {
  const OtoxpertMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
