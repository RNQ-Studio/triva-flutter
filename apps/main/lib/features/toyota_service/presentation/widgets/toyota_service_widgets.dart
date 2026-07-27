import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/toyota_service_models.dart';

class ToyotaServiceFlowScaffold extends StatelessWidget {
  const ToyotaServiceFlowScaffold({
    required this.step,
    required this.title,
    required this.description,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryBusy = false,
    this.secondary,
    super.key,
  });

  final int step;
  final String title;
  final String description;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryBusy;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingToyotaTitle)),
      body: SafeArea(
        child: Column(
          children: [
            BookingProgress(step: step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.medium,
                  AppSpacing.large,
                  AppSpacing.xLarge,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xLarge),
                        body,
                        const SizedBox(height: AppSpacing.large),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_done_outlined,
                              size: 16,
                              color: colors.secondary,
                            ),
                            const SizedBox(width: AppSpacing.xSmall),
                            Flexible(
                              child: Text(
                                l10n.draftSaved,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.medium,
                  AppSpacing.large,
                  AppSpacing.large,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Row(
                      children: [
                        if (secondary != null) ...[
                          Expanded(child: secondary!),
                          const SizedBox(width: AppSpacing.medium),
                        ],
                        Expanded(
                          flex: secondary == null ? 1 : 2,
                          child: FilledButton(
                            onPressed: primaryBusy ? null : onPrimary,
                            child: primaryBusy
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(primaryLabel),
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

class BookingProgress extends StatelessWidget {
  const BookingProgress({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceColors = Theme.of(context).extension<AppServiceColors>()!;
    final colors = Theme.of(context).colorScheme;
    final stages = [
      (Icons.directions_car_outlined, l10n.bookingStepVehicle),
      (Icons.build_outlined, l10n.bookingStepService),
      (Icons.calendar_month_outlined, l10n.bookingStepSchedule),
      (Icons.receipt_long_outlined, l10n.bookingStepReview),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        AppSpacing.medium,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < stages.length; index++) ...[
            Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Durations.short4,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < step
                          ? serviceColors.confirmed
                          : index == step
                              ? serviceColors.bookingContainer
                              : colors.surfaceContainer,
                      border: Border.all(
                        color: index <= step
                            ? index < step
                                ? serviceColors.confirmed
                                : serviceColors.booking
                            : colors.outline,
                      ),
                    ),
                    child: Icon(
                      index < step ? Icons.check_rounded : stages[index].$1,
                      color: index < step
                          ? serviceColors.onBooking
                          : index == step
                              ? serviceColors.booking
                              : colors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    stages[index].$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: index == step
                              ? serviceColors.booking
                              : index < step
                                  ? serviceColors.confirmed
                                  : colors.onSurfaceVariant,
                          fontWeight:
                              index == step ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            if (index != stages.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Divider(
                    color: index < step
                        ? serviceColors.confirmed
                        : colors.outlineVariant,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class BookingSection extends StatelessWidget {
  const BookingSection({
    required this.child,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final serviceColors = Theme.of(context).extension<AppServiceColors>()!;
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: child,
    );
    return Material(
      color: selected ? serviceColors.bookingContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(
          color: selected ? serviceColors.booking : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class BookingNotice extends StatelessWidget {
  const BookingNotice({
    required this.message,
    this.kind = BookingNoticeKind.information,
    super.key,
  });

  final String message;
  final BookingNoticeKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final serviceColors = Theme.of(context).extension<AppServiceColors>()!;
    final background = switch (kind) {
      BookingNoticeKind.information => serviceColors.bookingContainer,
      BookingNoticeKind.success => serviceColors.confirmedContainer,
      BookingNoticeKind.error => colors.errorContainer,
    };
    final foreground = switch (kind) {
      BookingNoticeKind.information => serviceColors.onBookingContainer,
      BookingNoticeKind.success => serviceColors.onConfirmedContainer,
      BookingNoticeKind.error => colors.onErrorContainer,
    };
    final icon = switch (kind) {
      BookingNoticeKind.information => Icons.info_outline_rounded,
      BookingNoticeKind.success => Icons.check_circle_outline_rounded,
      BookingNoticeKind.error => Icons.error_outline_rounded,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: foreground,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum BookingNoticeKind { information, success, error }

class BookingAsyncView<T> extends StatelessWidget {
  const BookingAsyncView({
    required this.value,
    required this.data,
    required this.onRetry,
    this.isEmpty,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyAction,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback onRetry;
  final bool Function(T value)? isEmpty;
  final String? emptyTitle;
  final String? emptyDescription;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (result) {
        if (isEmpty?.call(result) ?? false) {
          return BookingEmptyState(
            title: emptyTitle ?? AppLocalizations.of(context)!.loadFailed,
            description:
                emptyDescription ?? AppLocalizations.of(context)!.errorGeneral,
            action: emptyAction,
          );
        }
        return data(result);
      },
      loading: BookingLoading.new,
      error: (error, _) => BookingErrorState(
        offline: isNetworkFailure(error),
        onRetry: onRetry,
      ),
    );
  }
}

class BookingLoading extends StatelessWidget {
  const BookingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context)!.loadingData,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.large),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.medium),
        itemBuilder: (_, index) => DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: AppRadius.medium,
          ),
          child: const SizedBox(height: 88),
        ),
      ),
    );
  }
}

class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({
    required this.title,
    required this.description,
    this.action,
    super.key,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(
                dimension: 72,
                child: Icon(Icons.event_busy_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.large),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class BookingErrorState extends StatelessWidget {
  const BookingErrorState({
    required this.offline,
    required this.onRetry,
    super.key,
  });

  final bool offline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BookingEmptyState(
      title: offline ? l10n.bookingOfflineError : l10n.loadFailed,
      description: offline ? l10n.submissionNetworkError : l10n.errorGeneral,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.retry),
      ),
    );
  }
}

bool isNetworkFailure(Object error) {
  final cause =
      error is DioException && error.error != null ? error.error! : error;
  return cause is NetworkException;
}

class BookingReferenceCard extends StatelessWidget {
  const BookingReferenceCard({
    required this.booking,
    super.key,
  });

  final ToyotaServiceBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BookingSection(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.referenceNumber,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                SelectableText(
                  booking.referenceNo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: booking.referenceNo),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(l10n.referenceCopied)),
                );
            },
            icon: const Icon(Icons.copy_rounded),
            tooltip: l10n.copyReference,
          ),
        ],
      ),
    );
  }
}

class BookingTimeline extends StatelessWidget {
  const BookingTimeline({
    required this.items,
    this.showAdminDetails = false,
    super.key,
  });

  final List<ToyotaServiceTimelineItem> items;
  final bool showAdminDetails;

  @override
  Widget build(BuildContext context) {
    final serviceColors = Theme.of(context).extension<AppServiceColors>()!;
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: serviceColors.confirmed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: serviceColors.onBooking,
                          size: 20,
                        ),
                      ),
                      if (index != items.length - 1)
                        Expanded(
                          child: VerticalDivider(
                            color: serviceColors.confirmed,
                            width: 2,
                            thickness: 2,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index].title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (items[index].description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            items[index].description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                        ],
                        if (showAdminDetails &&
                            (items[index].actorName?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            AppLocalizations.of(context)!.timelineActor(
                              items[index].actorName!,
                              items[index].actorType ?? '-',
                            ),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                        ],
                        if (showAdminDetails &&
                            (items[index].reasonCode?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            '${AppLocalizations.of(context)!.reasonCodeLabel}: '
                            '${items[index].reasonCode}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                        ],
                        if (showAdminDetails &&
                            (items[index].internalNote?.isNotEmpty ??
                                false)) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            '${AppLocalizations.of(context)!.internalNote}: '
                            '${items[index].internalNote}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                        ],
                        if (items[index].occurredAt != null) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            formatBookingDateTime(
                              context,
                              items[index].occurredAt!,
                            ),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String formatBookingSlot(BuildContext context, ToyotaServiceSlot slot) {
  final date = DateTime.tryParse(slot.date);
  if (date == null) return '${slot.date} · ${slot.timeWindow}';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat('EEE, d MMM yyyy', locale).format(date)} · '
      '${slot.timeWindow}';
}

String formatBookingDateTime(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final jakarta = value.toUtc().add(const Duration(hours: 7));
  return DateFormat('d MMM yyyy · HH.mm', locale).format(jakarta);
}
