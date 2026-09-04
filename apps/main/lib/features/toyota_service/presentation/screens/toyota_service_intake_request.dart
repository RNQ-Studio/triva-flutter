part of 'toyota_service_intake_screens.dart';

class ToyotaServiceDetailsScreen extends ConsumerStatefulWidget {
  const ToyotaServiceDetailsScreen({super.key});

  @override
  ConsumerState<ToyotaServiceDetailsScreen> createState() =>
      _ToyotaServiceDetailsScreenState();
}

class _ToyotaServiceDetailsScreenState
    extends ConsumerState<ToyotaServiceDetailsScreen> {
  late final TextEditingController _mileageController;
  late final TextEditingController _complaintController;
  bool _initialized = false;
  final _pendingPhotos = <String, XFile>{};
  final _uploadingPhotos = <String>{};
  final _photoProgress = <String, double>{};
  final _photoErrors = <String, String>{};
  var _photoSequence = 0;
  String? _pickerError;

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController();
    _complaintController = TextEditingController();
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = ref.watch(toyotaServiceFlowProvider);
    final draft = flow.value?.draft ?? const ToyotaServiceDraft();
    final options = ref.watch(toyotaServiceOptionsProvider).value;
    final maxPhotos = options?.photoMaxFiles ?? 5;
    final totalPhotos = draft.photos.length + _pendingPhotos.length;
    if (!_initialized && flow.hasValue) {
      _initialized = true;
      _mileageController.text = draft.currentMileage?.toString() ?? '';
      _complaintController.text = draft.complaint;
    }
    final photosAllowed = draft.serviceType?.isBodyPaint ?? false;
    final mileage = int.tryParse(_mileageController.text);
    final valid = mileage != null &&
        mileage >= 0 &&
        mileage <= 5000000 &&
        _complaintController.text.trim().length >= 5 &&
        _complaintController.text.trim().length <= 3000 &&
        _pendingPhotos.isEmpty;
    return ToyotaServiceFlowScaffold(
      step: 1,
      fallbackLocation: toyotaServiceTypePath,
      title: l10n.serviceDetailsTitle,
      description: l10n.serviceDetailsDescription,
      primaryLabel: l10n.chooseSchedule,
      onPrimary: valid
          ? () async {
              await _save();
              if (!context.mounted) return;
              context.push(toyotaServiceSchedulePath);
            }
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (draft.vehicle != null && draft.serviceType != null) ...[
            BookingNotice(
              message:
                  '${draft.vehicle!.displayName} · ${draft.serviceType!.name}',
            ),
            const SizedBox(height: AppSpacing.large),
          ],
          TextField(
            controller: _mileageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.currentMileage,
              suffixText: 'km',
            ),
            onChanged: (_) {
              setState(() {});
              _save();
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _complaintController,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: l10n.complaint,
              hintText: l10n.complaintHint,
              alignLabelWithHint: true,
            ),
            onChanged: (_) {
              setState(() {});
              _save();
            },
          ),
          // Revisi 4 September 2026: foto pendukung hanya diminta untuk
          // Body & Paint; jenis servis lain cukup dengan keluhan tertulis.
          if (photosAllowed) ...[
            const SizedBox(height: AppSpacing.medium),
            Text(
              '${l10n.supportingPhotoOptional} ($totalPhotos/$maxPhotos)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            for (final photo in draft.photos) ...[
              BookingSection(
                child: ListTile(
                  key: ValueKey('supporting-photo-${photo.assetId}'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(photo.name),
                  subtitle: Text(l10n.supportingPhotoPrivacy),
                  trailing: IconButton(
                    onPressed: () => ref
                        .read(toyotaServiceFlowProvider.notifier)
                        .removePhoto(photo.assetId),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: l10n.removeSupportingPhoto,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
            ],
            for (final entry in _pendingPhotos.entries) ...[
              BookingSection(
                child: ListTile(
                  key: ValueKey('pending-supporting-photo-${entry.key}'),
                  contentPadding: EdgeInsets.zero,
                  leading: _uploadingPhotos.contains(entry.key)
                      ? CircularProgressIndicator(
                          value: _photoProgress[entry.key],
                        )
                      : const Icon(Icons.sync_problem_rounded),
                  title: Text(entry.value.name),
                  subtitle: _photoErrors[entry.key] == null
                      ? Text(l10n.uploadSending)
                      : Text(
                          _photoErrors[entry.key]!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                  trailing: _uploadingPhotos.contains(entry.key)
                      ? null
                      : Wrap(
                          children: [
                            IconButton(
                              onPressed: () => _uploadPhoto(
                                entry.key,
                                entry.value,
                                options,
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              tooltip: l10n.retry,
                            ),
                            IconButton(
                              onPressed: () => setState(() {
                                _pendingPhotos.remove(entry.key);
                                _photoErrors.remove(entry.key);
                                _photoProgress.remove(entry.key);
                              }),
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: l10n.removeSupportingPhoto,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
            ],
            if (totalPhotos < maxPhotos)
              OutlinedButton.icon(
                onPressed: () => _pickPhotos(
                  options,
                  maxPhotos - totalPhotos,
                ),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(l10n.addSupportingPhoto),
              ),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (_pickerError != null) ...[
            BookingNotice(
              message: _pickerError!,
              kind: BookingNoticeKind.error,
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          BookingNotice(message: l10n.supportingPhotoPrivacy),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final mileage = int.tryParse(_mileageController.text);
    if (mileage == null) return;
    await ref.read(toyotaServiceFlowProvider.notifier).saveDetails(
          currentMileage: mileage,
          complaint: _complaintController.text,
        );
  }

  Future<void> _pickPhotos(
    ToyotaServiceOptions? options,
    int remaining,
  ) async {
    try {
      setState(() => _pickerError = null);
      final photos =
          await ref.read(toyotaServicePhotoPickerProvider).pickImages(
                limit: remaining,
              );
      if (photos.isEmpty) return;
      final entries = <MapEntry<String, XFile>>[];
      for (final photo in photos.take(remaining)) {
        final key = '${_photoSequence++}-${photo.name}';
        entries.add(MapEntry(key, photo));
      }
      setState(() {
        for (final entry in entries) {
          _pendingPhotos[entry.key] = entry.value;
        }
      });
      for (final entry in entries) {
        await _uploadPhoto(entry.key, entry.value, options);
      }
    } on PlatformException {
      if (!mounted) return;
      setState(
        () => _pickerError = AppLocalizations.of(context)!.photoPermissionError,
      );
    } on Object {
      if (!mounted) return;
      setState(
        () => _pickerError = AppLocalizations.of(context)!.photoUploadFailed,
      );
    }
  }

  Future<void> _uploadPhoto(
    String key,
    XFile photo,
    ToyotaServiceOptions? options,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final extension = photo.name.split('.').last.toLowerCase();
    final allowedExtensions = options?.photoExtensions ??
        const {'jpg', 'jpeg', 'png', 'heic', 'heif'};
    if (!allowedExtensions.contains(extension)) {
      setState(() => _photoErrors[key] = l10n.photoInvalidType);
      return;
    }
    final maxBytes = (options?.photoMaxSizeMb ?? 10) * 1024 * 1024;
    if (await photo.length() > maxBytes) {
      if (mounted) {
        setState(() => _photoErrors[key] = l10n.photoTooLarge);
      }
      return;
    }
    setState(() {
      _uploadingPhotos.add(key);
      _photoErrors.remove(key);
      _photoProgress[key] = 0;
    });
    try {
      await ref.read(toyotaServiceFlowProvider.notifier).savePhoto(
        photo,
        onProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _photoProgress[key] = sent / total);
        },
      );
      if (!mounted) return;
      setState(() {
        _pendingPhotos.remove(key);
        _photoErrors.remove(key);
        _photoProgress.remove(key);
      });
    } on PlatformException {
      if (!mounted) return;
      setState(
        () => _photoErrors[key] = l10n.photoPermissionError,
      );
    } on Object {
      if (!mounted) return;
      setState(
        () => _photoErrors[key] = l10n.photoUploadFailed,
      );
    } finally {
      if (mounted) setState(() => _uploadingPhotos.remove(key));
    }
  }
}

class ToyotaServiceScheduleScreen extends ConsumerWidget {
  const ToyotaServiceScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(toyotaServiceFlowProvider).value?.draft ??
        const ToyotaServiceDraft();
    if (draft.serviceType == null || draft.fulfillmentType == null) {
      return BookingErrorState(
        offline: false,
        onRetry: () => context.go(toyotaServiceTypePath),
      );
    }
    final query = ToyotaServiceAvailabilityQuery(
      serviceTypeId: draft.serviceType!.id,
      fulfillment: draft.fulfillmentType!,
      serviceLocationId: draft.serviceLocation?.id,
      fromDate: DateTime.now().add(
        Duration(
          days: draft.serviceType!.leadDaysFor(draft.fulfillmentType!),
        ),
      ),
    );
    final availability = ref.watch(toyotaServiceAvailabilityProvider(query));
    return ToyotaServiceFlowScaffold(
      step: 2,
      fallbackLocation: toyotaServiceDetailsPath,
      title: l10n.schedulePreferenceTitle,
      description: l10n.schedulePreferenceDescription,
      primaryLabel: l10n.reviewBooking,
      onPrimary: draft.hasSchedule
          ? () => context.push(
                draft.fulfillmentType == ToyotaServiceFulfillment.ths
                    ? toyotaServiceAddressPath
                    : toyotaServiceReviewPath,
              )
          : null,
      body: SizedBox(
        height: 520,
        child: BookingAsyncView<ToyotaServiceAvailability>(
          value: availability,
          isEmpty: (value) => value.slots.length < 2,
          emptyTitle: l10n.availabilityEmpty,
          emptyDescription: l10n.availabilityEmptyDescription,
          onRetry: () =>
              ref.invalidate(toyotaServiceAvailabilityProvider(query)),
          data: (value) => ListView(
            children: [
              Text(
                l10n.primaryPreference,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              for (final slot in value.slots.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: BookingSection(
                    selected: draft.primarySlot == slot,
                    onTap: () {
                      final alternative = draft.alternativeSlot == slot
                          ? null
                          : draft.alternativeSlot;
                      ref.read(toyotaServiceFlowProvider.notifier).saveSchedule(
                            primary: slot,
                            alternative: alternative ??
                                value.slots.firstWhere(
                                  (candidate) => candidate != slot,
                                  orElse: () => slot,
                                ),
                          );
                    },
                    child: _SlotRow(slot: slot),
                  ),
                ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                l10n.alternativePreference,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              for (final slot in value.slots
                  .where((item) => item != draft.primarySlot)
                  .take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: BookingSection(
                    selected: draft.alternativeSlot == slot,
                    onTap: draft.primarySlot == null
                        ? null
                        : () => ref
                            .read(toyotaServiceFlowProvider.notifier)
                            .saveSchedule(
                              primary: draft.primarySlot!,
                              alternative: slot,
                            ),
                    child: _SlotRow(slot: slot),
                  ),
                ),
              const SizedBox(height: AppSpacing.medium),
              BookingNotice(message: l10n.preferenceNotSlot),
              const SizedBox(height: AppSpacing.medium),
              BookingNotice(
                message: l10n.bookingLeadTimeNotice(
                  draft.serviceType!.leadDaysFor(draft.fulfillmentType!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});

  final ToyotaServiceSlot slot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_outlined),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Text(
            formatBookingSlot(context, slot),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
