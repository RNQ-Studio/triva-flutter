import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/play_store_installs_models.dart';
import 'admin_analytics_widgets.dart';
import 'visit_analytics_controller.dart';

/// Total pemasangan aplikasi di Google Play.
class AdminPlayStoreSection extends ConsumerWidget {
  const AdminPlayStoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final installs = ref.watch(adminPlayStoreInstallsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminAnalyticsHeader(
          title: l10n.adminPlayStoreTitle,
          description: l10n.adminPlayStoreDescription,
          refreshTooltip: l10n.adminPlayStoreRefresh,
          onRefresh: installs.isLoading
              ? null
              : () => ref.invalidate(adminPlayStoreInstallsProvider),
        ),
        const SizedBox(height: AppSpacing.medium),
        installs.when(
          loading: () => const _PlayStoreLoading(),
          error: (error, _) => AdminAnalyticsMessageCard(
            icon: isAnalyticsOffline(error)
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded,
            title: isAnalyticsOffline(error)
                ? l10n.adminVisitOfflineTitle
                : l10n.adminVisitErrorTitle,
            description: isAnalyticsOffline(error)
                ? l10n.adminVisitOfflineDescription
                : l10n.adminVisitErrorDescription,
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(adminPlayStoreInstallsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (snapshot) => snapshot.isConfigured
              ? _PlayStoreContent(snapshot: snapshot)
              : AdminAnalyticsMessageCard(
                  key: const ValueKey('admin-play-store-empty'),
                  icon: Icons.shop_outlined,
                  title: l10n.adminPlayStoreEmptyTitle,
                  description: l10n.adminPlayStoreEmptyDescription,
                ),
        ),
      ],
    );
  }
}

class _PlayStoreContent extends StatelessWidget {
  const _PlayStoreContent({required this.snapshot});

  final PlayStoreInstallsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final dateFormat = DateFormat.yMMMd(locale);
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('admin-play-store-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.download_rounded, color: colors.primary),
            title: Row(
              children: [
                Expanded(child: Text(l10n.adminPlayStoreTotal)),
                const SizedBox(width: AppSpacing.small),
                Text(
                  number.format(snapshot.totalInstalls),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            subtitle: snapshot.packageName.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xSmall),
                    child: Text(snapshot.packageName),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          switch (snapshot.source) {
            PlayStoreInstallsSource.playReports =>
              l10n.adminPlayStoreSourceReports,
            _ => l10n.adminPlayStoreSourceManual,
          },
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        if (snapshot.reportedAt != null) ...[
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            l10n.adminPlayStoreReportedAt(
              dateFormat.format(snapshot.reportedAt!.toLocal()),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _PlayStoreLoading extends StatelessWidget {
  const _PlayStoreLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey('admin-play-store-loading'),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: colors.surfaceContainerHighest),
        title: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: .5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: AppRadius.small,
              ),
              child: const SizedBox(height: AppSpacing.medium),
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: FractionallySizedBox(
            widthFactor: .7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: AppRadius.small,
              ),
              child: const SizedBox(height: AppSpacing.small),
            ),
          ),
        ),
      ),
    );
  }
}
