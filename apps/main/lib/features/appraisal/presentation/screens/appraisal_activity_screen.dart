import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../../toyota_service/presentation/toyota_service_controller.dart';
import '../../../toyota_service/presentation/toyota_service_paths.dart';
import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';

class AppraisalActivityScreen extends ConsumerWidget {
  const AppraisalActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appraisals = ref.watch(appraisalsProvider);
    final bookings = ref.watch(toyotaServiceBookingsProvider);
    final hasAnyValue = appraisals.hasValue || bookings.hasValue;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: SafeArea(
        child: !hasAnyValue && appraisals.isLoading && bookings.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ActivityList(
                appraisals: appraisals.value ?? const [],
                bookings: bookings.value ?? const [],
                appraisalsLoading: appraisals.isLoading,
                bookingsLoading: bookings.isLoading,
                appraisalsError: appraisals.hasError,
                bookingsError: bookings.hasError,
                onRetryAppraisals: () => ref.invalidate(appraisalsProvider),
                onRetryBookings: () =>
                    ref.invalidate(toyotaServiceBookingsProvider),
                onRefresh: () async {
                  await Future.wait<void>([
                    ref
                        .refresh(appraisalsProvider.future)
                        .then<void>((_) {})
                        .onError((_, __) {}),
                    ref
                        .refresh(toyotaServiceBookingsProvider.future)
                        .then<void>((_) {})
                        .onError((_, __) {}),
                  ]);
                },
              ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({
    required this.appraisals,
    required this.bookings,
    required this.appraisalsLoading,
    required this.bookingsLoading,
    required this.appraisalsError,
    required this.bookingsError,
    required this.onRetryAppraisals,
    required this.onRetryBookings,
    required this.onRefresh,
  });

  final List<AppraisalData> appraisals;
  final List<ToyotaServiceBooking> bookings;
  final bool appraisalsLoading;
  final bool bookingsLoading;
  final bool appraisalsError;
  final bool bookingsError;
  final VoidCallback onRetryAppraisals;
  final VoidCallback onRetryBookings;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSourceNotice = appraisalsError || bookingsError;
    final isLoading = appraisalsLoading || bookingsLoading;
    if (appraisals.isEmpty &&
        bookings.isEmpty &&
        !hasSourceNotice &&
        !isLoading) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            _ActivityEmpty(
              title: l10n.activityEmpty,
              description: l10n.activityEmptyDescription,
            ),
          ],
        ),
      );
    }
    final entries = <({DateTime at, Widget tile})>[
      for (final item in appraisals)
        (
          at: item.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          tile: _AppraisalTile(item: item),
        ),
      for (final item in bookings)
        (
          at: item.updatedAt ??
              item.submittedAt ??
              DateTime.fromMillisecondsSinceEpoch(0),
          tile: _BookingTile(item: item),
        ),
    ]..sort((a, b) => b.at.compareTo(a.at));
    final leading = <Widget>[
      if (appraisalsError)
        _ActivitySourceError(
          key: const ValueKey('activity-appraisals-error'),
          message: l10n.activityAppraisalsLoadFailed,
          onRetry: onRetryAppraisals,
        ),
      if (bookingsError)
        _ActivitySourceError(
          key: const ValueKey('activity-bookings-error'),
          message: l10n.activityBookingsLoadFailed,
          onRetry: onRetryBookings,
        ),
      if (isLoading) const LinearProgressIndicator(),
      if (entries.isEmpty && hasSourceNotice)
        _ActivityEmpty(
          title: l10n.activityEmpty,
          description: l10n.activityEmptyDescription,
        ),
    ];
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.large),
        itemCount: leading.length + entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.small),
        itemBuilder: (_, index) => index < leading.length
            ? leading[index]
            : entries[index - leading.length].tile,
      ),
    );
  }
}

class _ActivitySourceError extends StatelessWidget {
  const _ActivitySourceError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.sync_problem_rounded),
        title: Text(message),
        trailing: TextButton(
          onPressed: onRetry,
          child: Text(l10n.retry),
        ),
      ),
    );
  }
}

class _AppraisalTile extends StatelessWidget {
  const _AppraisalTile({required this.item});
  final AppraisalData item;

  @override
  Widget build(BuildContext context) => Card(
        key: ValueKey('activity-appraisal-${item.id}'),
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.price_check_outlined),
          ),
          title: Text(
            item.vehicle == null
                ? item.referenceNo
                : '${item.vehicle!.make} ${item.vehicle!.model} '
                    '${item.vehicle!.year}',
          ),
          subtitle: Text('${item.referenceNo} • ${item.statusLabel}'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(
            item.resultReady
                ? appraisalResultPath(item.id)
                : appraisalDetailPath(item.id),
          ),
        ),
      );
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.item});
  final ToyotaServiceBooking item;

  @override
  Widget build(BuildContext context) => Card(
        key: ValueKey('activity-booking-${item.id}'),
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.serviceOrangeSoft,
            child: const Icon(
              Icons.car_repair_outlined,
              color: AppColors.serviceOrange,
            ),
          ),
          title: Text(
            item.vehicle == null
                ? item.referenceNo
                : '${item.vehicle!.make} ${item.vehicle!.model}',
          ),
          subtitle: Text('${item.referenceNo} • ${item.statusLabel}'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(toyotaServiceBookingPath(item.id)),
        ),
      );
}

class _ActivityEmpty extends StatelessWidget {
  const _ActivityEmpty({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 56),
              const SizedBox(height: AppSpacing.medium),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
