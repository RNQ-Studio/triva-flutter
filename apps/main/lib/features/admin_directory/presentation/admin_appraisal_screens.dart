import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_directory_models.dart';
import 'admin_directory_controller.dart';
import 'admin_directory_paths.dart';
import 'admin_directory_widgets.dart';

/// Daftar seluruh appraisal yang dibuat pelanggan.
class AdminAppraisalQueueScreen extends ConsumerWidget {
  const AdminAppraisalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(adminAppraisalListProvider);
    final statuses = ref.watch(adminAppraisalStatusesProvider).value ??
        const <AdminStatusOption>[];

    return AdminListScaffold<AdminAppraisalRecord>(
      title: l10n.adminAppraisalQueueTitle,
      searchHint: l10n.adminReferenceOrCustomerHint,
      state: state,
      controller: ref.read(adminAppraisalListProvider.notifier),
      statusOptions: [
        for (final status in statuses)
          (value: status.value, label: status.label),
      ],
      allStatusLabel: l10n.adminFilterAll,
      emptyTitle: l10n.adminAppraisalEmptyTitle,
      emptyDescription: l10n.adminAppraisalEmptyDescription,
      itemBuilder: (context, appraisal) =>
          _AdminAppraisalTile(appraisal: appraisal),
    );
  }
}

class _AdminAppraisalTile extends StatelessWidget {
  const _AdminAppraisalTile({required this.appraisal});

  final AdminAppraisalRecord appraisal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customer = appraisal.customer?.name;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => context.push(adminAppraisalDetailPath(appraisal.id)),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(Icons.price_check_rounded, color: colors.primary),
        ),
        title: Text(
          appraisal.vehicleLabel?.isNotEmpty == true
              ? appraisal.vehicleLabel!
              : appraisal.referenceNo,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appraisal.referenceNo),
            Text(
              [
                if (customer != null && customer.isNotEmpty) customer,
                appraisal.statusLabel,
                formatAdminDate(context, appraisal.updatedAt),
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

/// Detail satu appraisal termasuk kondisi kendaraan dan riwayat statusnya.
class AdminAppraisalDetailScreen extends ConsumerWidget {
  const AdminAppraisalDetailScreen({super.key, required this.appraisalId});

  final String appraisalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(adminAppraisalDetailProvider(appraisalId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminAppraisalDetailTitle)),
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
              onPressed: () =>
                  ref.invalidate(adminAppraisalDetailProvider(appraisalId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
          data: (appraisal) => ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              AdminDetailCard(
                title: l10n.adminSectionSummary,
                children: [
                  AdminDetailRow(
                    label: l10n.adminFieldReference,
                    value: appraisal.referenceNo,
                  ),
                  AdminDetailRow(
                    label: l10n.status,
                    value: appraisal.statusLabel,
                  ),
                  AdminDetailRow(
                    label: l10n.myVehicle,
                    value: appraisal.vehicleLabel ?? '—',
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldSubmittedAt,
                    value: formatAdminDate(context, appraisal.submittedAt),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldUpdatedAt,
                    value: formatAdminDate(context, appraisal.updatedAt),
                  ),
                ],
              ),
              if (appraisal.customer != null) ...[
                const SizedBox(height: AppSpacing.medium),
                _CustomerCard(customer: appraisal.customer!),
              ],
              const SizedBox(height: AppSpacing.medium),
              AdminDetailCard(
                title: l10n.adminSectionValuation,
                children: [
                  AdminDetailRow(
                    label: l10n.adminFieldExpectedPrice,
                    value: formatAdminCurrency(
                      context,
                      appraisal.expectedPrice,
                    ),
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldTradeInEstimate,
                    value: appraisal.tradeInLow == null
                        ? '—'
                        : '${formatAdminCurrency(context, appraisal.tradeInLow)}'
                            ' – '
                            '${formatAdminCurrency(context, appraisal.tradeInHigh)}',
                  ),
                  AdminDetailRow(
                    label: l10n.adminFieldDecision,
                    value: appraisal.customerDecision ?? '—',
                  ),
                ],
              ),
              if (appraisal.condition.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.medium),
                AdminDetailCard(
                  title: l10n.adminSectionCondition,
                  children: [
                    for (final entry in appraisal.condition.entries)
                      AdminDetailRow(
                        label: _conditionLabel(l10n, entry.key),
                        value: entry.value?.toString().isNotEmpty == true
                            ? entry.value.toString()
                            : '—',
                      ),
                  ],
                ),
              ],
              if (appraisal.timeline.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.medium),
                AdminDetailCard(
                  title: l10n.adminSectionTimeline,
                  children: [
                    for (final event in appraisal.timeline)
                      AdminDetailRow(
                        label: formatAdminDate(
                          context,
                          parseDate(event['occurred_at']),
                        ),
                        value: event['title'] as String? ??
                            event['status'] as String? ??
                            '—',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final AdminCustomerRef customer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdminDetailCard(
      title: l10n.adminSectionCustomer,
      children: [
        AdminDetailRow(label: l10n.name, value: customer.name),
        AdminDetailRow(label: l10n.email, value: customer.email ?? '—'),
        AdminDetailRow(
          label: l10n.phoneNumber,
          value: customer.phone ?? '—',
        ),
        AdminDetailRow(
          label: l10n.cityOrRegency,
          value: customer.city ?? '—',
        ),
      ],
    );
  }
}

String _conditionLabel(AppLocalizations l10n, String key) => switch (key) {
      'tax_status' => l10n.adminConditionTaxStatus,
      'flood_history' => l10n.adminConditionFlood,
      'major_accident_history' => l10n.adminConditionAccident,
      'service_history' => l10n.adminConditionService,
      'ownership' => l10n.adminConditionOwnership,
      'condition_grade' => l10n.adminConditionGrade,
      'engine_condition' => l10n.adminConditionEngine,
      'tyre_condition' => l10n.adminConditionTyre,
      _ => key,
    };
