import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../toyota_service/domain/toyota_service_models.dart';
import '../../../toyota_service/presentation/toyota_service_controller.dart';
import '../../../toyota_service/presentation/toyota_service_paths.dart';
import '../../../otoxpert/domain/otoxpert_models.dart';
import '../../../otoxpert/presentation/otoxpert_controller.dart';
import '../../../otoxpert/presentation/otoxpert_paths.dart';
import '../../../credit/domain/credit_models.dart';
import '../../../credit/presentation/credit_controller.dart';
import '../../../credit/presentation/credit_paths.dart';
import '../../../body_paint/domain/body_paint_models.dart';
import '../../../body_paint/presentation/body_paint_controller.dart';
import '../../../body_paint/presentation/body_paint_paths.dart';
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
    final otoxpertBookings = ref.watch(otoxpertBookingsProvider);
    final creditSimulations = ref.watch(creditSimulationsProvider);
    final bodyPaintEstimates = ref.watch(bodyPaintEstimatesProvider);
    final hasAnyValue = appraisals.hasValue ||
        bookings.hasValue ||
        otoxpertBookings.hasValue ||
        creditSimulations.hasValue ||
        bodyPaintEstimates.hasValue;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: SafeArea(
        child: !hasAnyValue &&
                appraisals.isLoading &&
                bookings.isLoading &&
                otoxpertBookings.isLoading &&
                creditSimulations.isLoading &&
                bodyPaintEstimates.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ActivityList(
                appraisals: appraisals.value ?? const [],
                bookings: bookings.value ?? const [],
                otoxpertBookings: otoxpertBookings.value ?? const [],
                creditSimulations: creditSimulations.value ?? const [],
                bodyPaintEstimates: bodyPaintEstimates.value ?? const [],
                appraisalsLoading: appraisals.isLoading,
                bookingsLoading: bookings.isLoading,
                otoxpertLoading: otoxpertBookings.isLoading,
                creditLoading: creditSimulations.isLoading,
                bodyPaintLoading: bodyPaintEstimates.isLoading,
                appraisalsError: appraisals.hasError,
                bookingsError: bookings.hasError,
                otoxpertError: otoxpertBookings.hasError,
                creditError: creditSimulations.hasError,
                bodyPaintError: bodyPaintEstimates.hasError,
                onRetryAppraisals: () => ref.invalidate(appraisalsProvider),
                onRetryBookings: () =>
                    ref.invalidate(toyotaServiceBookingsProvider),
                onRetryOtoxpert: () => ref.invalidate(otoxpertBookingsProvider),
                onRetryCredit: () => ref.invalidate(creditSimulationsProvider),
                onRetryBodyPaint: () =>
                    ref.invalidate(bodyPaintEstimatesProvider),
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
                    ref
                        .refresh(otoxpertBookingsProvider.future)
                        .then<void>((_) {})
                        .onError((_, __) {}),
                    ref
                        .refresh(creditSimulationsProvider.future)
                        .then<void>((_) {})
                        .onError((_, __) {}),
                    ref
                        .refresh(bodyPaintEstimatesProvider.future)
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
    required this.otoxpertBookings,
    required this.creditSimulations,
    required this.bodyPaintEstimates,
    required this.appraisalsLoading,
    required this.bookingsLoading,
    required this.otoxpertLoading,
    required this.creditLoading,
    required this.bodyPaintLoading,
    required this.appraisalsError,
    required this.bookingsError,
    required this.otoxpertError,
    required this.creditError,
    required this.bodyPaintError,
    required this.onRetryAppraisals,
    required this.onRetryBookings,
    required this.onRetryOtoxpert,
    required this.onRetryCredit,
    required this.onRetryBodyPaint,
    required this.onRefresh,
  });

  final List<AppraisalData> appraisals;
  final List<ToyotaServiceBooking> bookings;
  final List<OtoxpertBooking> otoxpertBookings;
  final List<CreditSimulation> creditSimulations;
  final List<BodyPaintEstimate> bodyPaintEstimates;
  final bool appraisalsLoading;
  final bool bookingsLoading;
  final bool otoxpertLoading;
  final bool creditLoading;
  final bool bodyPaintLoading;
  final bool appraisalsError;
  final bool bookingsError;
  final bool otoxpertError;
  final bool creditError;
  final bool bodyPaintError;
  final VoidCallback onRetryAppraisals;
  final VoidCallback onRetryBookings;
  final VoidCallback onRetryOtoxpert;
  final VoidCallback onRetryCredit;
  final VoidCallback onRetryBodyPaint;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSourceNotice = appraisalsError ||
        bookingsError ||
        otoxpertError ||
        creditError ||
        bodyPaintError;
    final isLoading = appraisalsLoading ||
        bookingsLoading ||
        otoxpertLoading ||
        creditLoading ||
        bodyPaintLoading;
    if (appraisals.isEmpty &&
        bookings.isEmpty &&
        otoxpertBookings.isEmpty &&
        creditSimulations.isEmpty &&
        bodyPaintEstimates.isEmpty &&
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
      for (final item in otoxpertBookings)
        (
          at: item.updatedAt ?? item.submittedAt,
          tile: _OtoxpertBookingTile(item: item),
        ),
      for (final item in creditSimulations)
        (
          at: item.updatedAt ?? item.savedAt,
          tile: _CreditSimulationTile(item: item),
        ),
      for (final item in bodyPaintEstimates)
        (
          at: item.updatedAt ??
              item.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0),
          tile: _BodyPaintEstimateTile(item: item),
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
      if (otoxpertError)
        _ActivitySourceError(
          key: const ValueKey('activity-otoxpert-error'),
          message: l10n.activityOtoxpertLoadFailed,
          onRetry: onRetryOtoxpert,
        ),
      if (creditError)
        _ActivitySourceError(
          key: const ValueKey('activity-credit-error'),
          message: l10n.creditActivityLoadFailed,
          onRetry: onRetryCredit,
        ),
      if (bodyPaintError)
        _ActivitySourceError(
          key: const ValueKey('activity-body-paint-error'),
          message: l10n.bodyPaintActivityLoadFailed,
          onRetry: onRetryBodyPaint,
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
            backgroundColor: AppColors.accentSoft,
            child: const Icon(
              Icons.car_repair_outlined,
              color: AppColors.accent,
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

class _OtoxpertBookingTile extends StatelessWidget {
  const _OtoxpertBookingTile({required this.item});

  final OtoxpertBooking item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      key: ValueKey('activity-otoxpert-${item.id}'),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: Icon(
            Icons.handyman_outlined,
            color: AppColors.accent,
          ),
        ),
        title: Text(
          item.vehicle == null ? item.referenceNo : item.vehicle!.displayName,
        ),
        subtitle: Text(
          '${l10n.activityOtoxpertBookingLabel} • ${item.statusLabel}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(otoxpertBookingPath(item.id)),
      ),
    );
  }
}

class _CreditSimulationTile extends StatelessWidget {
  const _CreditSimulationTile({required this.item});

  final CreditSimulation item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final program = item.calculation.program['program_name']?.toString() ??
        item.referenceNo;
    return Card(
      key: ValueKey('activity-credit-${item.id}'),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: Icon(
            Icons.calculate_outlined,
            color: AppColors.accent,
          ),
        ),
        title: Text(program),
        subtitle: Text(
          '${l10n.creditActivityLabel} · ${item.statusLabel}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(creditSimulationPath(item.id)),
      ),
    );
  }
}

class _BodyPaintEstimateTile extends StatelessWidget {
  const _BodyPaintEstimateTile({required this.item});

  final BodyPaintEstimate item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      key: ValueKey('activity-body-paint-${item.id}'),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: Icon(
            Icons.format_paint_outlined,
            color: AppColors.accent,
          ),
        ),
        title: Text(
          item.vehicle?.displayName ?? item.referenceNo,
        ),
        subtitle: Text(
          '${l10n.bodyPaintActivityLabel} â€¢ ${item.statusLabel}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(bodyPaintEstimatePath(item.id)),
      ),
    );
  }
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
