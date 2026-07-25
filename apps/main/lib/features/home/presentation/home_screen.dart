import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
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
                      AppSpacing.xxLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeHeader(
                          userName: user?.name,
                          onProfileTap: user == null
                              ? null
                              : () => context.push(AppRoutes.profile),
                          onSettingsTap: () => context.push(AppRoutes.settings),
                        ),
                        const SizedBox(height: AppSpacing.xLarge),
                        _HeroSection(
                          isAuthenticated: user != null,
                          onAction: () => context.push(
                            user == null ? authLoginPath : AppRoutes.profile,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxLarge),
                        Text(
                          l10n.homeServicesTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          l10n.homeServicesSubtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        const _ServicesList(),
                        const SizedBox(height: AppSpacing.xxLarge),
                        Text(
                          l10n.homeProcessTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        const _ProcessList(),
                        const SizedBox(height: AppSpacing.xxLarge),
                        const Divider(),
                        const SizedBox(height: AppSpacing.large),
                        Text(
                          l10n.homeFooter,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.onProfileTap,
    required this.onSettingsTap,
  });

  final String? userName;
  final VoidCallback? onProfileTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        const TrivaLogo(width: 128),
        const Spacer(),
        if (userName != null)
          IconButton(
            onPressed: onProfileTap,
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.profile,
          ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n.settings,
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.isAuthenticated,
    required this.onAction,
  });

  final bool isAuthenticated;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.directions_car_filled_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              l10n.homeHeroTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.homeHeroDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xLarge),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(
                isAuthenticated
                    ? Icons.person_outline_rounded
                    : Icons.login_rounded,
              ),
              label: Text(
                isAuthenticated ? l10n.homeProfileAction : l10n.homeLoginAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceDefinition {
  const _ServiceDefinition({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _ServicesList extends StatelessWidget {
  const _ServicesList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final services = [
      _ServiceDefinition(
        icon: Icons.car_crash_outlined,
        title: l10n.serviceAppraisalTitle,
        description: l10n.serviceAppraisalDescription,
      ),
      _ServiceDefinition(
        icon: Icons.build_circle_outlined,
        title: l10n.serviceToyotaTitle,
        description: l10n.serviceToyotaDescription,
      ),
      _ServiceDefinition(
        icon: Icons.handyman_outlined,
        title: l10n.serviceOtoxpertTitle,
        description: l10n.serviceOtoxpertDescription,
      ),
      _ServiceDefinition(
        icon: Icons.calculate_outlined,
        title: l10n.serviceCreditTitle,
        description: l10n.serviceCreditDescription,
      ),
      _ServiceDefinition(
        icon: Icons.auto_fix_high_outlined,
        title: l10n.serviceBodyPaintTitle,
        description: l10n.serviceBodyPaintDescription,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < services.length; index++) ...[
            _ServiceRow(service: services[index]),
            if (index != services.length - 1) const Divider(indent: 72),
          ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});

  final _ServiceDefinition service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: AppRadius.small,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Icon(
                service.icon,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessList extends StatelessWidget {
  const _ProcessList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _ProcessStep(
          number: '1',
          title: l10n.processVehicleTitle,
          description: l10n.processVehicleDescription,
        ),
        const SizedBox(height: AppSpacing.large),
        _ProcessStep(
          number: '2',
          title: l10n.processReviewTitle,
          description: l10n.processReviewDescription,
        ),
        const SizedBox(height: AppSpacing.large),
        _ProcessStep(
          number: '3',
          title: l10n.processResultTitle,
          description: l10n.processResultDescription,
        ),
      ],
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: Text(number),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
