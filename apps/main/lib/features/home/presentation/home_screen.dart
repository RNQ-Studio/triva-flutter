import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../appraisal/domain/appraisal_models.dart';
import '../../appraisal/presentation/appraisal_controller.dart';
import '../../appraisal/presentation/appraisal_paths.dart';
import '../../toyota_service/presentation/toyota_service_controller.dart';
import '../../toyota_service/presentation/toyota_service_paths.dart';
import '../../toyota_service/domain/toyota_service_models.dart';
import '../../otoxpert/presentation/otoxpert_paths.dart';
import '../../credit/presentation/credit_paths.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final appraisals = ref.watch(appraisalsProvider);
    final draft = ref.watch(appraisalFlowProvider).value?.draft;
    final startPath = appraisalResumePath(
      draft ?? const AppraisalDraft(),
    );
    final serviceDraft = ref.watch(toyotaServiceFlowProvider).value?.draft;
    ref.watch(toyotaServiceOptionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(appraisalsProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        AppSpacing.medium,
                        AppSpacing.large,
                        AppSpacing.xLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            onNotifications: () => context.go('/notifications'),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          Text(
                            l10n.homeGreeting(
                              user?.name.split(' ').first ?? 'TRIVA',
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            l10n.homeGreetingSubtitle,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          _AppraisalHero(
                            onTap: () => context.push(startPath),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          Text(
                            l10n.homeServicesTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _ServiceGrid(
                            onToyotaService: () async {
                              final activeDraft =
                                  serviceDraft ?? const ToyotaServiceDraft();
                              ToyotaServiceOptions? options;
                              try {
                                options = await ref.read(
                                  toyotaServiceOptionsProvider.future,
                                );
                              } on Object {
                                // A stale persisted draft may not bypass the
                                // operational selection step while offline.
                              }
                              if (!context.mounted) return;
                              context.push(
                                options == null && activeDraft.hasFulfillment
                                    ? toyotaServiceFulfillmentPath
                                    : toyotaServiceResumePath(
                                        activeDraft,
                                        options: options,
                                      ),
                              );
                            },
                            onOtoxpert: () => context.push(otoxpertPath),
                            onCredit: () => context.push(creditPath),
                            onUnavailable: () => ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(l10n.comingSoon)),
                              ),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          Text(
                            l10n.myVehicle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          appraisals.when(
                            data: (items) => items.isEmpty
                                ? _EmptyVehicle(
                                    onStart: () => context.push(startPath),
                                  )
                                : _LatestVehicle(appraisal: items.first),
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => _EmptyVehicle(
                              onStart: () => context.push(startPath),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const TrivaLogo(width: 122),
        const Spacer(),
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: AppLocalizations.of(context)!.notifications,
        ),
      ],
    );
  }
}

class _AppraisalHero extends StatelessWidget {
  const _AppraisalHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.price_check_rounded,
                    color: colors.onPrimary,
                    size: AppIconSize.large,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    l10n.serviceAppraisalTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    l10n.serviceAppraisalDescription,
                    style: TextStyle(
                      color: colors.onPrimary.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton.tonal(
                    onPressed: onTap,
                    child: Text(l10n.startAppraisal),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Icon(
              Icons.directions_car_filled_rounded,
              size: AppIconSize.hero,
              color: colors.onPrimary.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.onToyotaService,
    required this.onOtoxpert,
    required this.onCredit,
    required this.onUnavailable,
  });

  final VoidCallback onToyotaService;
  final VoidCallback onOtoxpert;
  final VoidCallback onCredit;
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final services = [
      (
        Icons.car_repair_rounded,
        l10n.serviceToyotaTitle,
        AppColors.serviceOrange,
        AppColors.serviceOrangeSoft,
      ),
      (
        Icons.handyman_rounded,
        l10n.serviceOtoxpertTitle,
        AppColors.serviceViolet,
        AppColors.serviceVioletSoft,
      ),
      (
        Icons.calculate_rounded,
        l10n.serviceCreditTitle,
        AppColors.serviceGreen,
        AppColors.serviceGreenSoft,
      ),
      (
        Icons.format_paint_rounded,
        l10n.serviceBodyPaintTitle,
        AppColors.serviceRose,
        AppColors.serviceRoseSoft,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = textScale < 1.6 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.medium,
            mainAxisSpacing: AppSpacing.medium,
            mainAxisExtent: columns == 1 ? 112 : 168,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Material(
              color: service.$4,
              borderRadius: AppRadius.large,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: switch (index) {
                  0 => onToyotaService,
                  1 => onOtoxpert,
                  2 => onCredit,
                  _ => onUnavailable,
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: columns == 1
                      ? Row(
                          children: [
                            _ServiceIcon(
                              icon: service.$1,
                              foreground: AppColors.surfaceLight,
                              background: service.$3,
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: _ServiceLabel(
                                label: service.$2,
                                color: service.$3,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ServiceIcon(
                              icon: service.$1,
                              foreground: AppColors.surfaceLight,
                              background: service.$3,
                            ),
                            _ServiceLabel(
                              label: service.$2,
                              color: service.$3,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
      ),
      child: SizedBox.square(
        dimension: 56,
        child: Icon(
          icon,
          color: foreground,
          size: AppIconSize.service,
        ),
      ),
    );
  }
}

class _ServiceLabel extends StatelessWidget {
  const _ServiceLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _EmptyVehicle extends StatelessWidget {
  const _EmptyVehicle({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors.surfaceContainerHighest,
              child: const Icon(Icons.garage_outlined),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.emptyVehicleTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(l10n.emptyVehicleDescription),
                  const SizedBox(height: AppSpacing.medium),
                  TextButton(
                    onPressed: onStart,
                    child: Text(l10n.startAppraisal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestVehicle extends StatelessWidget {
  const _LatestVehicle({required this.appraisal});

  final AppraisalData appraisal;

  @override
  Widget build(BuildContext context) {
    final vehicle = appraisal.vehicle;
    if (vehicle == null) return const SizedBox.shrink();
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: const CircleAvatar(
          child: Icon(Icons.directions_car_outlined),
        ),
        title: Text('${vehicle.make} ${vehicle.model} ${vehicle.year}'),
        subtitle: Text(appraisal.statusLabel),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(
          appraisal.resultReady
              ? appraisalResultPath(appraisal.id)
              : appraisalDetailPath(appraisal.id),
        ),
      ),
    );
  }
}
