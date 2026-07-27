part of 'toyota_service_booking_screens.dart';

class AdminToyotaServiceBookingScreen extends ConsumerWidget {
  const AdminToyotaServiceBookingScreen({
    required this.bookingId,
    super.key,
  });

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || !auth.user.canViewServiceBooking) {
      return const AdminPanelScreen();
    }
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(adminToyotaServiceBookingDetailProvider(bookingId));
    final adminOptions = ref.watch(adminToyotaServiceOptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailTitle)),
      body: async.when(
        data: (booking) => Column(
          children: [
            Expanded(child: _BookingDetailBody(booking: booking, admin: true)),
            if (auth.user.canManageServiceBookings &&
                booking.availableAdminActions.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          ref.watch(toyotaServiceMutationProvider).isLoading
                              ? null
                              : () => _chooseAdminAction(
                                    context,
                                    ref,
                                    booking,
                                    adminOptions.value,
                                  ),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: Text(l10n.adminPanel),
                    ),
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => BookingErrorState(
          offline: isNetworkFailure(error),
          onRetry: () => ref
              .invalidate(adminToyotaServiceBookingDetailProvider(bookingId)),
        ),
      ),
    );
  }

  Future<void> _chooseAdminAction(
    BuildContext context,
    WidgetRef ref,
    ToyotaServiceBooking booking,
    ToyotaServiceAdminOptions? adminOptions,
  ) async {
    final action = await showModalBottomSheet<ToyotaServiceAdminAction>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in booking.availableAdminActions)
              ListTile(
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    var availableSlots = switch (action.action) {
      'confirm' ||
      'confirm_reschedule' =>
        validAdminConfirmationSlots(booking, action.action),
      _ => <ToyotaServiceSlot>[],
    };
    if (action.action == 'propose_alternative' &&
        booking.serviceType != null &&
        booking.serviceLocation != null) {
      try {
        availableSlots =
            (await ref.read(toyotaServiceRepositoryProvider).getAvailability(
                      serviceTypeId: booking.serviceType!.id,
                      fulfillment: booking.fulfillmentType,
                      fromDate: DateTime.now(),
                      serviceLocationId: booking.serviceLocation!.id,
                      city: booking.thsCity,
                      latitude: booking.thsLatitude,
                      longitude: booking.thsLongitude,
                    ))
                .slots;
      } on Object {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.loadFailed)),
          );
        }
        return;
      }
    }
    if ({
          'confirm',
          'confirm_reschedule',
          'propose_alternative',
        }.contains(action.action) &&
        availableSlots.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.adminNoValidSlots),
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;
    final fields = await _adminPayloadDialog(
      context,
      action: action,
      booking: booking,
      adminOptions: adminOptions,
      availableSlots: availableSlots,
    );
    if (fields == null || !context.mounted) return;
    final result =
        await ref.read(toyotaServiceMutationProvider.notifier).adminAction(
              booking.id,
              action: action.action,
              fields: fields,
            );
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final mutationError = ref.read(toyotaServiceMutationProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == null
              ? _adminMutationError(l10n, mutationError)
              : l10n.adminActionSuccess,
        ),
      ),
    );
  }
}

String _adminMutationError(AppLocalizations l10n, Object? error) {
  final cause =
      error is DioException && error.error != null ? error.error : error;
  if (cause is ServerException) {
    if (cause.validationErrors.isNotEmpty) {
      return cause.validationErrors.values
          .expand((messages) => messages)
          .join('\n');
    }
    if (cause.message.trim().isNotEmpty) return cause.message;
  }
  return l10n.bookingMutationFailed;
}

Future<Map<String, dynamic>?> _adminPayloadDialog(
  BuildContext context, {
  required ToyotaServiceAdminAction action,
  required ToyotaServiceBooking booking,
  required ToyotaServiceAdminOptions? adminOptions,
  required List<ToyotaServiceSlot> availableSlots,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final advisor = TextEditingController();
  final date = TextEditingController(
    text: booking.proposedSlot?.date ??
        booking.primarySlot?.date ??
        DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')
            .first,
  );
  final time = TextEditingController(
    text: booking.proposedSlot?.timeWindow ??
        booking.primarySlot?.timeWindow ??
        '09:00-11:00',
  );
  final pic = TextEditingController(
    text: booking.proposedPicName ?? booking.picName ?? '',
  );
  final instructions = TextEditingController(
    text: booking.proposedArrivalInstructions ??
        booking.arrivalInstructions ??
        '',
  );
  final externalBookingNumber = TextEditingController(
    text: booking.proposedExternalBookingNumber ??
        booking.externalBookingNumber ??
        '',
  );
  final internalNote = TextEditingController();
  final proposalReason = TextEditingController();
  final reasonCode = TextEditingController();
  final reason = TextEditingController();
  final expires = TextEditingController();
  final benefitType = TextEditingController(text: 't_care');
  final benefitStatus = TextEditingController(text: 'pending_verification');
  final source = TextEditingController(text: 'staff_manual');
  final benefitNotes = TextEditingController();
  final needsAdvisor = action.action == 'assign';
  String? selectedAdvisorId;
  String? selectedReasonCode;
  String? selectedBenefitType = adminOptions?.benefitTypes.firstOrNull?.value;
  String? selectedBenefitStatus =
      adminOptions?.benefitStatuses.firstOrNull?.value;
  String? selectedVerificationSource =
      adminOptions?.verificationSources.firstOrNull?.value;
  final needsSlot = {
    'confirm',
    'confirm_reschedule',
    'propose_alternative',
  }.contains(action.action);
  ToyotaServiceSlot? selectedSlot =
      availableSlots.contains(booking.confirmedSlot)
          ? booking.confirmedSlot
          : availableSlots.contains(booking.primarySlot)
              ? booking.primarySlot
              : availableSlots.firstOrNull;
  final needsProposal = action.action == 'propose_alternative';
  final acceptsOperationalMetadata = {
    'confirm',
    'confirm_reschedule',
    'propose_alternative',
  }.contains(action.action);
  final acceptsInternalNote =
      acceptsOperationalMetadata || action.action == 'complete';
  if (selectedSlot != null) {
    date.text = selectedSlot.date;
    time.text = selectedSlot.timeWindow;
    if (needsProposal) {
      expires.text = defaultProposalExpiry(
            selectedSlot,
            existingConfirmedSlot: booking.confirmedSlot,
          )?.toUtc().toIso8601String() ??
          '';
    }
  }
  final needsReason = {
    'reject',
    'cancel',
    'mark_no_show',
    'reject_reschedule',
  }.contains(action.action);
  final needsBenefit = action.action == 'verify_benefit';
  String? validationError;
  final payload = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(action.label),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (needsAdvisor)
                DropdownButtonFormField<String>(
                  initialValue: selectedAdvisorId,
                  decoration: InputDecoration(labelText: l10n.serviceAdvisor),
                  items: (adminOptions?.advisors ?? const [])
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text('${item.name} • ${item.email}'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() {
                    selectedAdvisorId = value;
                    advisor.text = value ?? '';
                  }),
                ),
              if (needsSlot) ...[
                DropdownButtonFormField<ToyotaServiceSlot>(
                  initialValue: selectedSlot,
                  decoration:
                      InputDecoration(labelText: l10n.scheduleInspection),
                  items: availableSlots
                      .map(
                        (slot) => DropdownMenuItem(
                          value: slot,
                          child: Text(formatBookingSlot(context, slot)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() {
                    selectedSlot = value;
                    date.text = value?.date ?? '';
                    time.text = value?.timeWindow ?? '';
                    if (needsProposal && value != null) {
                      expires.text = defaultProposalExpiry(
                            value,
                            existingConfirmedSlot: booking.confirmedSlot,
                          )?.toUtc().toIso8601String() ??
                          '';
                    }
                    validationError = null;
                  }),
                ),
                TextField(
                  controller: pic,
                  decoration: InputDecoration(labelText: l10n.picNameLabel),
                ),
                TextField(
                  controller: instructions,
                  maxLines: 2,
                  decoration:
                      InputDecoration(labelText: l10n.arrivalInstructionsLabel),
                ),
                if (needsProposal) ...[
                  TextField(
                    controller: proposalReason,
                    maxLines: 2,
                    decoration:
                        InputDecoration(labelText: l10n.alternativeReasonLabel),
                  ),
                  TextField(
                    controller: expires,
                    readOnly: true,
                    onTap: () async {
                      final chosenDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        initialDate:
                            DateTime.now().add(const Duration(days: 1)),
                      );
                      if (chosenDate == null || !context.mounted) return;
                      final chosenTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (chosenTime == null) return;
                      expires.text = DateTime(
                        chosenDate.year,
                        chosenDate.month,
                        chosenDate.day,
                        chosenTime.hour,
                        chosenTime.minute,
                      ).toUtc().toIso8601String();
                    },
                    decoration: InputDecoration(
                      labelText: l10n.responseDeadlineIsoLabel,
                    ),
                  ),
                ],
                if (acceptsOperationalMetadata)
                  TextField(
                    controller: externalBookingNumber,
                    decoration:
                        InputDecoration(labelText: l10n.externalBookingNumber),
                  ),
              ],
              if (needsReason) ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedReasonCode,
                  decoration: InputDecoration(labelText: l10n.reasonCodeLabel),
                  items: (adminOptions?.reasonCodes ?? const [])
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.value,
                          child: Text(item.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() {
                    selectedReasonCode = value;
                    reasonCode.text = value ?? '';
                  }),
                ),
                TextField(
                  controller: reason,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.adminActionReason,
                  ),
                ),
              ],
              if (needsBenefit) ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedBenefitType,
                  decoration: InputDecoration(labelText: l10n.benefitTypeLabel),
                  items: (adminOptions?.benefitTypes ?? const [])
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.value,
                          child: Text(item.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() {
                    selectedBenefitType = value;
                    benefitType.text = value ?? '';
                  }),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedBenefitStatus,
                  decoration:
                      InputDecoration(labelText: l10n.benefitStatusLabel),
                  items: (adminOptions?.benefitStatuses ?? const [])
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.value,
                          child: Text(item.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() {
                    selectedBenefitStatus = value;
                    benefitStatus.text = value ?? '';
                  }),
                ),
                if (selectedBenefitStatus != 'pending_verification')
                  DropdownButtonFormField<String>(
                    initialValue: selectedVerificationSource,
                    decoration: InputDecoration(
                        labelText: l10n.verificationSourceLabel),
                    items: (adminOptions?.verificationSources ?? const [])
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.value,
                            child: Text(item.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => setDialogState(() {
                      selectedVerificationSource = value;
                      source.text = value ?? '';
                    }),
                  ),
                TextField(
                  controller: benefitNotes,
                  decoration:
                      InputDecoration(labelText: l10n.benefitNotesLabel),
                ),
              ],
              if (acceptsInternalNote)
                TextField(
                  controller: internalNote,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l10n.internalNote),
                ),
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.small),
                  child: Text(
                    validationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (!needsAdvisor && !needsSlot && !needsReason && !needsBenefit)
                Text(l10n.confirmActionPrompt),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (needsAdvisor && advisor.text.trim().isEmpty) return;
              if (needsSlot &&
                  (date.text.trim().isEmpty ||
                      time.text.trim().isEmpty ||
                      pic.text.trim().isEmpty ||
                      instructions.text.trim().isEmpty)) {
                return;
              }
              if (needsReason &&
                  (reasonCode.text.trim().isEmpty ||
                      reason.text.trim().length < 5)) {
                return;
              }
              if (needsProposal && proposalReason.text.trim().length < 5) {
                return;
              }
              if (needsProposal) {
                final expiry =
                    DateTime.tryParse(expires.text.trim())?.toLocal();
                if (selectedSlot == null ||
                    expiry == null ||
                    !isValidProposalExpiry(
                      expiry,
                      selectedSlot!,
                      existingConfirmedSlot: booking.confirmedSlot,
                    )) {
                  setDialogState(
                    () => validationError = l10n.proposalExpiryInvalid,
                  );
                  return;
                }
              }
              if (needsBenefit &&
                  (benefitType.text.trim().isEmpty ||
                      benefitStatus.text.trim().isEmpty ||
                      (benefitStatus.text.trim() != 'pending_verification' &&
                          source.text.trim().isEmpty))) {
                return;
              }
              final slot = {
                'date': date.text.trim(),
                'time_window': time.text.trim(),
              };
              Navigator.pop(dialogContext, {
                if (needsAdvisor) 'advisor_id': advisor.text.trim(),
                if (action.action == 'confirm' ||
                    action.action == 'confirm_reschedule')
                  'confirmed_slot': slot,
                if (needsSlot) 'pic_name': pic.text.trim(),
                if (needsSlot) 'arrival_instructions': instructions.text.trim(),
                if (acceptsOperationalMetadata &&
                    externalBookingNumber.text.trim().isNotEmpty)
                  'external_booking_number': externalBookingNumber.text.trim(),
                if (acceptsInternalNote && internalNote.text.trim().isNotEmpty)
                  'note': internalNote.text.trim(),
                if (needsProposal) ...{
                  'proposed_slot': slot,
                  'proposal_reason': proposalReason.text.trim(),
                  'proposal_expires_at': expires.text.trim(),
                },
                if (needsReason) ...{
                  'reason_code': reasonCode.text.trim(),
                  'reason': reason.text.trim(),
                },
                if (needsBenefit) ...{
                  'benefit_type': benefitType.text.trim(),
                  'benefit_status': benefitStatus.text.trim(),
                  if (benefitStatus.text.trim() != 'pending_verification')
                    'verification_source': source.text.trim(),
                  if (benefitNotes.text.trim().isNotEmpty)
                    'benefit_notes': benefitNotes.text.trim(),
                },
              });
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    ),
  );
  for (final controller in [
    advisor,
    date,
    time,
    pic,
    instructions,
    externalBookingNumber,
    internalNote,
    proposalReason,
    reasonCode,
    reason,
    expires,
    benefitType,
    benefitStatus,
    source,
    benefitNotes,
  ]) {
    controller.dispose();
  }
  return payload;
}
