import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_directory_models.dart';
import 'admin_directory_controller.dart';
import 'admin_directory_paths.dart';
import 'admin_directory_widgets.dart';

/// Daftar simulasi kredit yang disimpan pelanggan.
class AdminCreditSimulationQueueScreen extends ConsumerWidget {
  const AdminCreditSimulationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(adminCreditSimulationListProvider);
    final statuses = ref.watch(adminCreditSimulationStatusesProvider).value ??
        const <AdminStatusOption>[];

    return AdminListScaffold<AdminCreditSimulationRecord>(
      title: l10n.adminCreditQueueTitle,
      searchHint: l10n.adminReferenceOrCustomerHint,
      state: state,
      controller: ref.read(adminCreditSimulationListProvider.notifier),
      statusOptions: [
        for (final status in statuses)
          (value: status.value, label: status.label),
      ],
      allStatusLabel: l10n.adminFilterAll,
      emptyTitle: l10n.adminCreditEmptyTitle,
      emptyDescription: l10n.adminCreditEmptyDescription,
      itemBuilder: (context, simulation) =>
          _AdminCreditSimulationTile(simulation: simulation),
    );
  }
}

class _AdminCreditSimulationTile extends StatelessWidget {
  const _AdminCreditSimulationTile({required this.simulation});

  final AdminCreditSimulationRecord simulation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () =>
            context.push(adminCreditSimulationDetailPath(simulation.id)),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(Icons.calculate_rounded, color: colors.primary),
        ),
        title: Text(
          simulation.programName?.isNotEmpty == true
              ? simulation.programName!
              : simulation.referenceNo,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminCreditInstallmentPerMonth(
                formatAdminCurrency(context, simulation.monthlyInstallment),
                simulation.tenorMonths ?? 0,
              ),
            ),
            Text(
              [
                if (simulation.customer?.name.isNotEmpty == true)
                  simulation.customer!.name,
                simulation.statusLabel,
                formatAdminDate(context, simulation.savedAt),
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// Rincian satu simulasi kredit beserta pelanggannya.
class AdminCreditSimulationDetailScreen extends ConsumerWidget {
  const AdminCreditSimulationDetailScreen({
    super.key,
    required this.simulationId,
  });

  final String simulationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(
      adminCreditSimulationDetailProvider(simulationId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminCreditDetailTitle)),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AdminDirectoryMessage(
            icon: isAdminDirectoryOffline(error)
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded,
            title: isAdminDirectoryOffline(error)
                ? l10n.bookingOfflineError
                : l10n.loadFailed,
            description: isAdminDirectoryOffline(error)
                ? l10n.submissionNetworkError
                : l10n.errorGeneral,
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(
                adminCreditSimulationDetailProvider(simulationId),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (simulation) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              AdminDetailCard(
                title: l10n.adminSectionSummary,
                children: [
                  AdminDetailRow(
                    label: l10n.adminFieldReference,
                    value: simulation.referenceNo,
                  ),
                  AdminDetailRow(
                    label: l10n.status,
                    value: simulation.statusLabel,
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldProgram,
                    value: simulation.programName ?? '—',
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldSavedAt,
                    value: formatAdminDate(context, simulation.savedAt),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldFollowUp,
                    value: simulation.followUpStatusLabel ?? '—',
                  ),
                ],
              ),
              if (simulation.customer != null) ...[
                const SizedBox(height: AppSpacing.medium),
                AdminDetailCard(
                  title: l10n.adminSectionCustomer,
                  children: [
                    AdminDetailRow(
                      label: l10n.name,
                      value: simulation.customer!.name,
                    ),
                    AdminDetailRow(
                      label: l10n.email,
                      value: simulation.customer!.email ?? '—',
                    ),
                    AdminDetailRow(
                      label: l10n.phoneNumber,
                      value: simulation.customer!.phone ?? '—',
                    ),
                    AdminDetailRow(
                      label: l10n.cityOrRegency,
                      value: simulation.customer!.city ?? '—',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              AdminDetailCard(
                title: l10n.adminSectionSimulation,
                children: [
                  AdminDetailRow(
                    label: l10n.adminFieldOtr,
                    value: formatAdminCurrency(context, simulation.otrPrice),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldDownPayment,
                    value: formatAdminCurrency(
                      context,
                      simulation.totalDownPayment,
                    ),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldTradeIn,
                    value: formatAdminCurrency(
                      context,
                      simulation.tradeInValue,
                    ),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldTenor,
                    value: simulation.tenorMonths == null
                        ? '—'
                        : l10n.adminTenorMonths(simulation.tenorMonths!),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldMonthlyInstallment,
                    value: formatAdminCurrency(
                      context,
                      simulation.monthlyInstallment,
                    ),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldInitialPayment,
                    value: formatAdminCurrency(
                      context,
                      simulation.initialPayment,
                    ),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldTotalPayment,
                    value: formatAdminCurrency(
                      context,
                      simulation.totalPayment,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
