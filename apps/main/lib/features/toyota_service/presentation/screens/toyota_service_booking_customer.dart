part of 'toyota_service_booking_screens.dart';

class ToyotaServiceBookingDetailScreen extends ConsumerWidget {
  const ToyotaServiceBookingDetailScreen({
    required this.bookingId,
    super.key,
  });

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final booking = ref.watch(toyotaServiceBookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailTitle)),
      body: SafeArea(
        child: booking.when(
          data: (value) => RefreshIndicator(
            onRefresh: () async => ref
                .refresh(toyotaServiceBookingDetailProvider(bookingId).future),
            child: _BookingDetailBody(
              booking: value,
              admin: false,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => BookingErrorState(
            offline: isNetworkFailure(error),
            onRetry: () =>
                ref.invalidate(toyotaServiceBookingDetailProvider(bookingId)),
          ),
        ),
      ),
    );
  }
}

class _BookingDetailBody extends ConsumerWidget {
  const _BookingDetailBody({
    required this.booking,
    required this.admin,
  });

  final ToyotaServiceBooking booking;
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mutating = ref.watch(toyotaServiceMutationProvider).isLoading;
    final slot =
        booking.confirmedSlot ?? booking.proposedSlot ?? booking.primarySlot;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        BookingReferenceCard(booking: booking),
        const SizedBox(height: AppSpacing.medium),
        _BookingStatusContext(booking: booking),
        const SizedBox(height: AppSpacing.medium),
        BookingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.vehicle == null
                          ? l10n.vehicleBeingServiced
                          : '${booking.vehicle!.make} '
                              '${booking.vehicle!.model} '
                              '${booking.vehicle!.year}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _StatusChip(
                    label: booking.statusLabel,
                    urgent: booking.slaOverdue,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              _InfoRow(
                icon: Icons.build_circle_outlined,
                label: l10n.service,
                value: booking.serviceType?.name ?? '-',
              ),
              _InfoRow(
                icon: Icons.pin_drop_outlined,
                label: l10n.fulfillment,
                value: booking.fulfillmentType == ToyotaServiceFulfillment.ths
                    ? l10n.thsService
                    : booking.serviceLocation?.name ?? '-',
              ),
              if (slot != null)
                _InfoRow(
                  icon: Icons.event_available_outlined,
                  label: l10n.scheduleInspection,
                  value: formatBookingSlot(context, slot),
                ),
              _InfoRow(
                icon: Icons.speed_rounded,
                label: l10n.mileage,
                value: '${booking.currentMileage} km',
              ),
              if (booking.complaint.isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_rounded,
                  label: l10n.complaint,
                  value: booking.complaint,
                ),
              if (booking.thsAddress?.isNotEmpty ?? false)
                _InfoRow(
                  icon: Icons.home_work_outlined,
                  label: l10n.location,
                  value: '${booking.thsAddress}, ${booking.thsCity ?? ''}',
                ),
              if (booking.reason?.isNotEmpty ?? false)
                _InfoRow(
                  icon: Icons.info_outline,
                  label: l10n.adminActionReason,
                  value: booking.reason!,
                ),
              if (admin && booking.customerName != null)
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.customer,
                  value:
                      '${booking.customerName} • ${booking.customerPhone ?? '-'}',
                ),
              if (admin && booking.assignedAdvisorName != null)
                _InfoRow(
                  icon: Icons.assignment_ind_outlined,
                  label: l10n.assignedAdvisor,
                  value: booking.assignedAdvisorName!,
                ),
              if (booking.externalBookingNumber != null)
                _InfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: l10n.referenceNumber,
                  value: booking.externalBookingNumber!,
                ),
              if (booking.arrivalInstructions != null)
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: l10n.serviceAdvisorConfirmation,
                  value: booking.arrivalInstructions!,
                ),
              if (booking.picName != null)
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.picNameLabel,
                  value: booking.picName!,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        BookingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.serviceAdvisor,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                booking.serviceAdvisorName ??
                    booking.picName ??
                    booking.serviceLocation?.name ??
                    '-',
              ),
              Wrap(
                spacing: AppSpacing.small,
                children: [
                  // Revisi 4 September 2026: kontak diarahkan ke WhatsApp PIC
                  // Admin Booking (nomor yang sama dengan handoff booking),
                  // bukan telepon Service Advisor.
                  TextButton.icon(
                    onPressed: () => _contactBookingAdmin(context, ref, l10n),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(l10n.contactServiceAdvisor),
                  ),
                  if (booking.serviceLocation?.directionsUrl != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(booking.serviceLocation!.directionsUrl!),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(l10n.location),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        // Revisi 4 September 2026: T-Care dan Warranty tidak ditampilkan lagi;
        // SSC mengarah ke halaman resmi Toyota Astra Motor.
        BookingSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sscCheckTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                l10n.sscCheckDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              for (final benefit in booking.benefitChecks.where(
                (item) => item.type.toLowerCase() == 'ssc',
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    benefit.status == 'active'
                        ? Icons.verified_outlined
                        : benefit.status == 'inactive'
                            ? Icons.block_outlined
                            : Icons.hourglass_top_rounded,
                  ),
                  title: Text(benefit.type.toUpperCase()),
                  subtitle: Text(
                    benefit.status == 'pending_verification'
                        ? l10n.pendingVerificationLabel
                        : '${benefit.status}'
                            '${benefit.notes == null ? '' : ' • ${benefit.notes}'}',
                  ),
                ),
              const SizedBox(height: AppSpacing.small),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  toyotaSscLookupUri,
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.sscCheckAction),
              ),
            ],
          ),
        ),
        if (booking.photos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          BookingSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.supportingPhotosTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                for (final photo in booking.photos)
                  if (photo.url.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          photo.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
        if (!admin && booking.allowedCustomerActions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          _CustomerActions(
            booking: booking,
            disabled: mutating,
          ),
        ],
        if (!admin &&
            const {
              'rejected',
              'cancelled',
              'expired',
              'no_show',
            }.contains(booking.status)) ...[
          const SizedBox(height: AppSpacing.medium),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(toyotaServiceFlowProvider.notifier).reset();
              if (context.mounted) context.go(toyotaServiceVehiclePath);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.bookingToyotaTitle),
          ),
        ],
        if (!admin && booking.status == 'completed') ...[
          const SizedBox(height: AppSpacing.medium),
          OutlinedButton.icon(
            onPressed: () => context.go('/activity'),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(l10n.activity),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.bookingTimelineTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        if (booking.timeline.isEmpty)
          Text(l10n.bookingGenericDescription)
        else
          BookingTimeline(
            items: booking.timeline,
            showAdminDetails: admin,
          ),
      ],
    );
  }

  Future<void> _contactBookingAdmin(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final vehicle = booking.vehicle;
    final opened = await openBranchWhatsApp(
      ref,
      channel: BranchChannel.toyotaService,
      message: branchWhatsAppMessage(
        title: l10n.contactBookingAdminMessage,
        details: {
          l10n.whatsappHandoffReference: booking.referenceNo,
          l10n.whatsappHandoffVehicle: vehicle == null
              ? null
              : '${vehicle.make} ${vehicle.model} ${vehicle.year}',
          l10n.whatsappHandoffPlate: vehicle?.licensePlate,
        },
      ),
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappHandoffFailed)),
      );
    }
  }
}

/// Halaman resmi Toyota Astra Motor untuk memeriksa keterlibatan kendaraan
/// dalam Special Service Campaign berdasarkan nomor rangka.
final Uri toyotaSscLookupUri = Uri.https('ssc.toyota.astra.co.id', '/');

class _BookingStatusContext extends StatelessWidget {
  const _BookingStatusContext({required this.booking});

  final ToyotaServiceBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = <String>[];
    if (booking.status == 'awaiting_confirmation') {
      messages.add(l10n.bookingAwaitingNotice);
    } else if (booking.status == 'alternative_proposed') {
      messages.add(l10n.bookingAlternativeNotice);
    } else if (booking.status == 'reschedule_requested') {
      messages.add(l10n.bookingRescheduleNotice);
    } else if (booking.status == 'checked_in') {
      messages.add(l10n.bookingCheckedInNotice);
    } else if (booking.status == 'in_service') {
      messages.add(l10n.bookingInServiceNotice);
    } else if (booking.status == 'completed') {
      messages.add(l10n.bookingCompletedNotice);
    } else if (booking.status == 'rejected' ||
        booking.status == 'cancelled' ||
        booking.status == 'expired' ||
        booking.status == 'no_show') {
      messages.add(booking.reason ?? l10n.bookingTerminalNotice);
    }
    final slots = <({String label, ToyotaServiceSlot slot})>[
      if (booking.primarySlot != null)
        (label: l10n.preferencePrimary, slot: booking.primarySlot!),
      if (booking.alternativeSlot != null)
        (label: l10n.preferenceAlternative, slot: booking.alternativeSlot!),
      if (booking.proposedSlot != null)
        (label: l10n.proposedScheduleLabel, slot: booking.proposedSlot!),
      if (booking.confirmedSlot != null)
        (label: l10n.confirmedScheduleLabel, slot: booking.confirmedSlot!),
      if (booking.reschedulePrimarySlot != null)
        (
          label: l10n.reschedulePrimaryLabel,
          slot: booking.reschedulePrimarySlot!,
        ),
      if (booking.rescheduleAlternativeSlot != null)
        (
          label: l10n.rescheduleAlternativeLabel,
          slot: booking.rescheduleAlternativeSlot!,
        ),
    ];
    if (messages.isEmpty && slots.isEmpty) return const SizedBox.shrink();
    return BookingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final message in messages) ...[
            BookingNotice(message: message),
            const SizedBox(height: AppSpacing.small),
          ],
          for (final entry in slots)
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: entry.label,
              value: formatBookingSlot(context, entry.slot),
            ),
          if (booking.proposalReason?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.notes_outlined,
              label: l10n.proposalReasonLabel,
              value: booking.proposalReason!,
            ),
          if (booking.proposalContext?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.info_outline,
              label: l10n.proposalContextLabel,
              value: booking.proposalContext!,
            ),
          if (booking.proposedPicName?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.badge_outlined,
              label: l10n.proposedPicName,
              value: booking.proposedPicName!,
            ),
          if (booking.proposedArrivalInstructions?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.directions_car_outlined,
              label: l10n.proposedArrivalInstructions,
              value: booking.proposedArrivalInstructions!,
            ),
          if (booking.proposedExternalBookingNumber?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: l10n.externalBookingNumber,
              value: booking.proposedExternalBookingNumber!,
            ),
          if (booking.rescheduleReason?.isNotEmpty ?? false)
            _InfoRow(
              icon: Icons.notes_outlined,
              label: l10n.rescheduleReasonLabel,
              value: booking.rescheduleReason!,
            ),
          if (booking.proposalExpiresAt != null)
            _InfoRow(
              icon: Icons.timer_outlined,
              label: l10n.responseDeadline,
              value: formatBookingDateTime(
                context,
                booking.proposalExpiresAt!,
              ),
            ),
          if (booking.completedAt != null)
            _InfoRow(
              icon: Icons.task_alt_outlined,
              label: l10n.completedAtLabel,
              value: formatBookingDateTime(context, booking.completedAt!),
            ),
        ],
      ),
    );
  }
}

class _CustomerActions extends ConsumerWidget {
  const _CustomerActions({
    required this.booking,
    required this.disabled,
  });

  final ToyotaServiceBooking booking;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final needsAvailability =
        booking.canRejectAlternative || booking.canReschedule;
    final availability = needsAvailability &&
            booking.serviceType != null &&
            booking.serviceLocation != null
        ? ref.watch(
            toyotaServiceAvailabilityProvider(
              ToyotaServiceAvailabilityQuery(
                serviceTypeId: booking.serviceType!.id,
                fulfillment: booking.fulfillmentType,
                fromDate: DateTime.now(),
                serviceLocationId: booking.serviceLocation!.id,
                city: booking.thsCity,
                latitude: booking.thsLatitude,
                longitude: booking.thsLongitude,
              ),
            ),
          )
        : null;
    final availableSlots =
        availability?.value?.slots ?? const <ToyotaServiceSlot>[];
    final scheduleReady = availableSlots.length >= 2;
    return BookingSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (booking.canAcceptAlternative)
            FilledButton(
              onPressed: disabled
                  ? null
                  : () => _run(
                        context,
                        ref,
                        () => ref
                            .read(toyotaServiceMutationProvider.notifier)
                            .acceptAlternative(booking.id),
                      ),
              child: Text(l10n.acceptAlternative),
            ),
          if (booking.canRejectAlternative)
            OutlinedButton(
              onPressed: disabled || !scheduleReady
                  ? null
                  : () async {
                      final result = await showDialog<_SlotRequest>(
                        context: context,
                        builder: (_) => _SlotRequestDialog(
                          title: l10n.alternativeSchedule,
                          initialPrimary:
                              booking.primarySlot ?? booking.proposedSlot,
                          initialAlternative: booking.alternativeSlot,
                          availableSlots: availableSlots,
                        ),
                      );
                      if (result == null || !context.mounted) return;
                      await _run(
                        context,
                        ref,
                        () => ref
                            .read(toyotaServiceMutationProvider.notifier)
                            .rejectAlternative(
                              booking.id,
                              primary: result.primary,
                              alternative: result.alternative,
                              reason: result.reason,
                            ),
                      );
                    },
              child: Text(l10n.rejectAlternative),
            ),
          if (booking.canReschedule)
            OutlinedButton.icon(
              onPressed: disabled || !scheduleReady
                  ? null
                  : () async {
                      final result = await showDialog<_SlotRequest>(
                        context: context,
                        builder: (_) => _SlotRequestDialog(
                          title: l10n.rescheduleTitle,
                          initialPrimary:
                              booking.confirmedSlot ?? booking.primarySlot,
                          initialAlternative: booking.alternativeSlot,
                          availableSlots: availableSlots,
                        ),
                      );
                      if (result == null || !context.mounted) return;
                      await _run(
                        context,
                        ref,
                        () => ref
                            .read(toyotaServiceMutationProvider.notifier)
                            .requestReschedule(
                              booking.id,
                              primary: result.primary,
                              alternative: result.alternative,
                              reason: result.reason,
                            ),
                      );
                    },
              icon: const Icon(Icons.event_repeat_rounded),
              label: Text(l10n.submitReschedule),
            ),
          if (booking.canCancel)
            TextButton(
              onPressed: disabled
                  ? null
                  : () async {
                      final reason = await _reasonDialog(
                        context,
                        title: l10n.cancelBooking,
                      );
                      if (reason == null || !context.mounted) return;
                      await _run(
                        context,
                        ref,
                        () => ref
                            .read(toyotaServiceMutationProvider.notifier)
                            .cancelBooking(booking.id, reason: reason),
                      );
                    },
              child: Text(l10n.cancelBooking),
            ),
          if (disabled) const LinearProgressIndicator(),
          if (availability?.isLoading ?? false) const LinearProgressIndicator(),
          if (availability?.hasError ?? false)
            BookingNotice(
              message: l10n.loadFailed,
              kind: BookingNoticeKind.error,
            ),
        ],
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<ToyotaServiceBooking?> Function() action,
  ) async {
    final result = await action();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == null ? l10n.bookingMutationFailed : l10n.adminActionSuccess,
        ),
      ),
    );
  }
}
