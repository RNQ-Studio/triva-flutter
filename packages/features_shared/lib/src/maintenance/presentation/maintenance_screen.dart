import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../branding/triva_logo.dart';

/// Layar yang menggantikan seluruh aplikasi ketika backend sedang dimatikan.
///
/// Ditulis mandiri: tidak memakai router, provider fitur, atau data cache,
/// karena justru tampil ketika lapisan-lapisan itu tidak bisa diandalkan.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({
    super.key,
    required this.status,
    required this.onRetry,
    this.isRetrying = false,
  });

  final MaintenanceStatus status;
  final Future<void> Function() onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final title = status.title ?? l10n.maintenanceTitle;
    final message = status.message ?? l10n.maintenanceDefaultMessage;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TrivaLogo(height: 34)),
                  const SizedBox(height: AppSpacing.xxLarge),
                  _StatusBadge(label: l10n.maintenanceBadge),
                  const SizedBox(height: AppSpacing.xLarge),
                  _MaintenanceGlyph(isDark: isDark),
                  const SizedBox(height: AppSpacing.xLarge),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  if (status.until != null) ...[
                    const SizedBox(height: AppSpacing.xLarge),
                    _EstimateCard(
                      label: l10n.maintenanceEstimate(
                        AppDateUtils.formatDateTime(status.until!),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxLarge),
                  AppButton(
                    label: l10n.retry,
                    onPressed: isRetrying ? null : () => onRetry(),
                    isLoading: isRetrying,
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  Text(
                    l10n.maintenanceThanks,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.small,
        ),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.onSecondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceGlyph extends StatelessWidget {
  const _MaintenanceGlyph({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.accentSoftDark : AppColors.accentSoft,
          border: Border.all(
            color: isDark ? AppColors.accentMutedDark : AppColors.accentMuted,
          ),
        ),
        child: Icon(
          Icons.build_outlined,
          size: AppIconSize.large,
          color: isDark ? AppColors.accentDark : AppColors.accent,
        ),
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.medium,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.medium,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: AppIconSize.small,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
