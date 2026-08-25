part of 'toyota_service_intake_screens.dart';

class ToyotaServiceAddressScreen extends ConsumerStatefulWidget {
  const ToyotaServiceAddressScreen({super.key});

  @override
  ConsumerState<ToyotaServiceAddressScreen> createState() =>
      _ToyotaServiceAddressScreenState();
}

class _ToyotaServiceAddressScreenState
    extends ConsumerState<ToyotaServiceAddressScreen> {
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _notesController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(toyotaServiceFlowProvider).value?.draft ??
        const ToyotaServiceDraft();
    final optionsAsync = ref.watch(toyotaServiceOptionsProvider);
    final options = optionsAsync.value;
    if (!_initialized) {
      _initialized = true;
      _addressController.text = draft.thsAddress;
      _cityController.text = draft.thsCity;
      _notesController.text = draft.thsLocationNotes;
    }
    final matchedCoverage = options?.thsCoverage
        .where(
          (coverage) =>
              coverage.city.toLowerCase() ==
                  _cityController.text.trim().toLowerCase() &&
              coverage.serviceLocationId == draft.serviceLocation?.id,
        )
        .firstOrNull;
    final covered = matchedCoverage?.isActive == true &&
        matchedCoverage?.bounds != null &&
        draft.thsLatitude != null &&
        draft.thsLongitude != null &&
        matchedCoverage!.contains(
          draft.thsLatitude!,
          draft.thsLongitude!,
        );
    final complete = _addressController.text.trim().length >= 10 &&
        _cityController.text.trim().isNotEmpty &&
        draft.thsLatitude != null &&
        draft.thsLongitude != null &&
        covered &&
        !optionsAsync.isLoading &&
        !optionsAsync.hasError;
    return ToyotaServiceFlowScaffold(
      step: 2,
      fallbackLocation: toyotaServiceSchedulePath,
      title: l10n.thsAddressTitle,
      description: l10n.thsAddressDescription,
      primaryLabel: l10n.reviewBooking,
      onPrimary: complete
          ? () async {
              await _save(draft);
              if (!context.mounted) return;
              context.push(toyotaServiceReviewPath);
            }
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.fullStreetAddress],
            decoration: InputDecoration(labelText: l10n.fullAddress),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.addressCity],
            decoration: InputDecoration(labelText: l10n.city),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.locationNotes),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.medium),
          ThsLocationPicker(
            latitude: draft.thsLatitude,
            longitude: draft.thsLongitude,
            onChanged: (point) async {
              await ref.read(toyotaServiceFlowProvider.notifier).saveThsAddress(
                    address: _addressController.text,
                    city: _cityController.text,
                    latitude: point.latitude,
                    longitude: point.longitude,
                    notes: _notesController.text,
                  );
              if (mounted) setState(() {});
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('ths-manual-pin'),
              onPressed: () => _showPinSheet(draft),
              icon: const Icon(Icons.pin_drop_outlined),
              label: Text(l10n.manualPinTitle),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          if (optionsAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (optionsAsync.hasError)
            BookingNotice(
              message: l10n.loadFailed,
              kind: BookingNoticeKind.error,
            )
          else
            BookingNotice(
              message: covered
                  ? matchedCoverage.requiresOperationalVerification
                      ? l10n.thsOperationalVerification
                      : l10n.thsCoverageAvailable
                  : l10n.thsCoverageUnavailable,
              kind: covered && !matchedCoverage.requiresOperationalVerification
                  ? BookingNoticeKind.success
                  : covered
                      ? BookingNoticeKind.information
                      : BookingNoticeKind.error,
            ),
          const SizedBox(height: AppSpacing.medium),
          BookingNotice(message: l10n.thsAddressPinRequired),
        ],
      ),
    );
  }

  Future<void> _showPinSheet(ToyotaServiceDraft draft) async {
    final latitude = TextEditingController(
      text: draft.thsLatitude?.toString() ?? '',
    );
    final longitude = TextEditingController(
      text: draft.thsLongitude?.toString() ?? '',
    );
    final result = await showModalBottomSheet<(double, double)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.large,
          AppSpacing.large,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.manualPinTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(AppLocalizations.of(context)!.manualPinDescription),
            const SizedBox(height: AppSpacing.large),
            TextField(
              controller: latitude,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.latitude,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              controller: longitude,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.longitude,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton(
              onPressed: () {
                final lat = double.tryParse(latitude.text);
                final lng = double.tryParse(longitude.text);
                if (lat == null ||
                    lng == null ||
                    lat < -90 ||
                    lat > 90 ||
                    lng < -180 ||
                    lng > 180) {
                  return;
                }
                Navigator.of(context).pop((lat, lng));
              },
              child: Text(AppLocalizations.of(context)!.savePin),
            ),
          ],
        ),
      ),
    );
    latitude.dispose();
    longitude.dispose();
    if (result == null || !mounted) return;
    await ref.read(toyotaServiceFlowProvider.notifier).saveThsAddress(
          address: _addressController.text,
          city: _cityController.text,
          latitude: result.$1,
          longitude: result.$2,
          notes: _notesController.text,
        );
    setState(() {});
  }

  Future<void> _save(ToyotaServiceDraft draft) async {
    if (draft.thsLatitude == null || draft.thsLongitude == null) return;
    await ref.read(toyotaServiceFlowProvider.notifier).saveThsAddress(
          address: _addressController.text,
          city: _cityController.text,
          latitude: draft.thsLatitude!,
          longitude: draft.thsLongitude!,
          notes: _notesController.text,
        );
  }
}

class ToyotaServiceReviewScreen extends ConsumerStatefulWidget {
  const ToyotaServiceReviewScreen({super.key});

  @override
  ConsumerState<ToyotaServiceReviewScreen> createState() =>
      _ToyotaServiceReviewScreenState();
}

class _ToyotaServiceReviewScreenState
    extends ConsumerState<ToyotaServiceReviewScreen> {
  String? _contactChannel;
  bool? _consent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(toyotaServiceOptionsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(toyotaServiceFlowProvider);
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final phoneMissing = user?.phone?.trim().isEmpty ?? true;
    final draft = flow.value?.draft ?? const ToyotaServiceDraft();
    final optionsAsync = ref.watch(toyotaServiceOptionsProvider);
    final options = optionsAsync.value;
    final operationalDraft = options?.supportsOperationalDraft(draft) == true;
    _contactChannel ??= draft.contactChannel;
    _consent ??= draft.serviceConsent;
    final channels = options?.contactChannels.isNotEmpty == true
        ? options!.contactChannels
        : const ['whatsapp', 'phone', 'email'];
    return ToyotaServiceFlowScaffold(
      step: 3,
      fallbackLocation: draft.fulfillmentType == ToyotaServiceFulfillment.ths
          ? toyotaServiceAddressPath
          : toyotaServiceSchedulePath,
      title: l10n.reviewServiceRequestTitle,
      description: l10n.reviewServiceRequestDescription,
      primaryLabel: l10n.submitServiceRequest,
      primaryBusy: flow.value?.isSubmitting ?? false,
      onPrimary: (_consent ?? false) &&
              draft.canSubmit &&
              !phoneMissing &&
              operationalDraft &&
              !optionsAsync.isLoading &&
              !optionsAsync.hasError
          ? () async {
              await ref.read(toyotaServiceFlowProvider.notifier).saveReview(
                    contactChannel: _contactChannel!,
                    serviceConsent: true,
                  );
              final booking =
                  await ref.read(toyotaServiceFlowProvider.notifier).submit();
              if (!context.mounted || booking == null) return;
              context.go(toyotaServiceSubmittedPath(booking.id));
              await _handOffToWhatsApp(booking, l10n);
            }
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (optionsAsync.isLoading)
            const LinearProgressIndicator()
          else if (optionsAsync.hasError)
            BookingNotice(
              message: l10n.loadFailed,
              kind: BookingNoticeKind.error,
            )
          else if (!operationalDraft) ...[
            BookingNotice(
              message: l10n.serviceSelectionChanged,
              kind: BookingNoticeKind.error,
            ),
            const SizedBox(height: AppSpacing.small),
            OutlinedButton.icon(
              onPressed: () => context.go(toyotaServiceFulfillmentPath),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.chooseServiceLocationAgain),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (phoneMissing) ...[
            BookingNotice(
              message: l10n.profilePhoneRequired,
              kind: BookingNoticeKind.error,
            ),
            const SizedBox(height: AppSpacing.small),
            OutlinedButton.icon(
              onPressed: () async {
                await context.push(AppRoutes.editProfile);
                await ref.read(authProvider.notifier).checkCurrentUser();
              },
              icon: const Icon(Icons.person_outline_rounded),
              label: Text(l10n.profile),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          BookingSection(
            child: Column(
              children: [
                _ReviewRow(
                  icon: Icons.directions_car_outlined,
                  label: l10n.reviewVehicle,
                  value: draft.vehicle?.displayName ?? '',
                ),
                _ReviewRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.location,
                  value: draft.fulfillmentType == ToyotaServiceFulfillment.ths
                      ? draft.thsAddress
                      : draft.serviceLocation?.name ?? '',
                ),
                _ReviewRow(
                  icon: Icons.build_outlined,
                  label: l10n.service,
                  value: draft.serviceType?.name ?? '',
                ),
                _ReviewRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.complaint,
                  value: draft.complaint,
                ),
                _ReviewRow(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.primarySchedule,
                  value: draft.primarySlot == null
                      ? ''
                      : formatBookingSlot(context, draft.primarySlot!),
                ),
                _ReviewRow(
                  icon: Icons.event_repeat_outlined,
                  label: l10n.alternativeSchedule,
                  value: draft.alternativeSlot == null
                      ? ''
                      : formatBookingSlot(context, draft.alternativeSlot!),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            initialValue: _contactChannel,
            decoration: InputDecoration(labelText: l10n.contactChannel),
            items: channels
                .map(
                  (channel) => DropdownMenuItem(
                    value: channel,
                    child: Text(_channelLabel(channel)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) async {
              if (value == null) return;
              setState(() => _contactChannel = value);
              await ref.read(toyotaServiceFlowProvider.notifier).saveReview(
                    contactChannel: value,
                    serviceConsent: _consent ?? false,
                  );
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          BookingNotice(message: l10n.requestToConfirmNotice),
          const SizedBox(height: AppSpacing.medium),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _consent,
            onChanged: (value) async {
              setState(() => _consent = value ?? false);
              await ref.read(toyotaServiceFlowProvider.notifier).saveReview(
                    contactChannel: _contactChannel!,
                    serviceConsent: _consent!,
                  );
            },
            title: Text(l10n.serviceBookingConsent),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (flow.value?.error != null) ...[
            const SizedBox(height: AppSpacing.medium),
            BookingNotice(
              message: _submitError(l10n, flow.value!.error!),
              kind: BookingNoticeKind.error,
            ),
          ],
        ],
      ),
    );
  }

  String _channelLabel(String channel) {
    return switch (channel) {
      'whatsapp' => 'WhatsApp',
      'phone' => AppLocalizations.of(context)!.phoneNumber,
      'email' => AppLocalizations.of(context)!.email,
      _ => channel,
    };
  }

  String _submitError(AppLocalizations l10n, String error) {
    return switch (error) {
      'network' => l10n.bookingOfflineError,
      'rate_limited' => l10n.bookingRateLimitError,
      'duplicate' => l10n.bookingDuplicateError,
      'incomplete' => l10n.bookingIncompleteError,
      'selection_changed' => l10n.serviceSelectionChanged,
      'auth' => l10n.submissionAuthError,
      'general' => l10n.bookingSubmissionError,
      _ => error,
    };
  }

  /// Meneruskan ringkasan booking ke WhatsApp Auto2000 Kertajaya begitu
  /// permintaan terkirim, sesuai permintaan notulensi 19 Agustus 2026.
  Future<void> _handOffToWhatsApp(
    ToyotaServiceBooking booking,
    AppLocalizations l10n,
  ) async {
    final vehicle = booking.vehicle;
    final slot = booking.primarySlot;
    final opened = await openBranchWhatsApp(
      ref,
      channel: BranchChannel.toyotaService,
      message: branchWhatsAppMessage(
        title: l10n.whatsappHandoffToyotaTitle,
        details: {
          l10n.whatsappHandoffReference: booking.referenceNo,
          l10n.whatsappHandoffVehicle: vehicle == null
              ? null
              : '${vehicle.make} ${vehicle.model} ${vehicle.year}',
          l10n.whatsappHandoffPlate: vehicle?.licensePlate,
          l10n.whatsappHandoffLocation: booking.serviceLocation?.name,
          l10n.whatsappHandoffSchedule:
              slot == null ? null : '${slot.date} ${slot.timeWindow}',
          l10n.whatsappHandoffComplaint: booking.complaint,
        },
      ),
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappHandoffFailed)),
      );
    }
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: AppSpacing.medium),
              SizedBox(
                width: 104,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}

class ToyotaServiceSubmittedScreen extends ConsumerWidget {
  const ToyotaServiceSubmittedScreen({
    required this.bookingId,
    super.key,
  });

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final submitted = ref.watch(toyotaServiceFlowProvider).value?.submitted;
    final detail = submitted?.id == bookingId
        ? AsyncData(submitted!)
        : ref.watch(toyotaServiceBookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.backToHome,
        ),
        title: const TrivaLogo(width: 112),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BookingAsyncView<ToyotaServiceBooking>(
          value: detail,
          onRetry: () =>
              ref.invalidate(toyotaServiceBookingDetailProvider(bookingId)),
          data: (booking) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: AppIconSize.hero,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      l10n.serviceRequestSubmittedTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      l10n.serviceRequestSubmittedDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    BookingReferenceCard(booking: booking),
                    const SizedBox(height: AppSpacing.medium),
                    BookingNotice(
                      message: l10n.awaitingStaffConfirmation,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    BookingTimeline(items: booking.timeline),
                    const SizedBox(height: AppSpacing.medium),
                    FilledButton(
                      onPressed: () =>
                          context.go(toyotaServiceBookingPath(booking.id)),
                      child: Text(l10n.viewBookingDetail),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.backToHome),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
