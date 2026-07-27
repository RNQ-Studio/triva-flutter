import 'dart:math';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../toyota_service/domain/toyota_service_models.dart';
import '../data/otoxpert_repository.dart';
import '../domain/otoxpert_models.dart';

final otoxpertRepositoryProvider = Provider<OtoxpertRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authProvider);
  return OtoxpertRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    storage: storage,
    userId: auth is AuthAuthenticated ? auth.user.id : null,
  );
});

final otoxpertOptionsProvider = FutureProvider<OtoxpertOptions>((ref) {
  return ref.watch(otoxpertRepositoryProvider).getOptions();
});

final otoxpertVehiclesProvider =
    FutureProvider<List<ToyotaServiceVehicle>>((ref) {
  return ref.watch(otoxpertRepositoryProvider).listVehicles();
});

final otoxpertWorkshopsProvider =
    FutureProvider.family<List<OtoxpertWorkshop>, String>((ref, vehicleId) {
  return ref.watch(otoxpertRepositoryProvider).listWorkshops(vehicleId);
});

final otoxpertServicesProvider =
    FutureProvider.family<List<OtoxpertService>, String>((ref, workshopId) {
  return ref.watch(otoxpertRepositoryProvider).listServices(workshopId);
});

final otoxpertAvailabilityProvider = FutureProvider.family<
    ToyotaServiceAvailability,
    ({String workshopId, String serviceId})>((ref, query) {
  return ref.watch(otoxpertRepositoryProvider).getAvailability(
        workshopId: query.workshopId,
        serviceId: query.serviceId,
      );
});

final otoxpertBookingsProvider = FutureProvider<List<OtoxpertBooking>>((ref) {
  return ref.watch(otoxpertRepositoryProvider).listBookings();
});

final otoxpertBookingProvider =
    FutureProvider.family<OtoxpertBooking, String>((ref, bookingId) {
  return ref.watch(otoxpertRepositoryProvider).getBooking(bookingId);
});

final adminOtoxpertBookingsProvider =
    FutureProvider<List<OtoxpertBooking>>((ref) {
  return ref.watch(otoxpertRepositoryProvider).listAdminBookings();
});

final adminOtoxpertBookingProvider =
    FutureProvider.family<OtoxpertBooking, String>((ref, bookingId) {
  return ref.watch(otoxpertRepositoryProvider).getAdminBooking(bookingId);
});

final adminOtoxpertOptionsProvider =
    FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(otoxpertRepositoryProvider).getAdminOptions();
});

class OtoxpertFlowState {
  const OtoxpertFlowState({
    required this.draft,
    this.isSubmitting = false,
    this.isUploading = false,
    this.error,
  });

  final OtoxpertDraft draft;
  final bool isSubmitting;
  final bool isUploading;
  final String? error;

  OtoxpertFlowState copyWith({
    OtoxpertDraft? draft,
    bool? isSubmitting,
    bool? isUploading,
    String? error,
    bool clearError = false,
  }) =>
      OtoxpertFlowState(
        draft: draft ?? this.draft,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isUploading: isUploading ?? this.isUploading,
        error: clearError ? null : error ?? this.error,
      );
}

class OtoxpertFlowController extends AsyncNotifier<OtoxpertFlowState> {
  OtoxpertRepository get _repository => ref.read(otoxpertRepositoryProvider);

  @override
  Future<OtoxpertFlowState> build() async =>
      OtoxpertFlowState(draft: await _repository.loadDraft());

  Future<void> selectVehicle(ToyotaServiceVehicle vehicle) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      OtoxpertDraft(
        vehicle: vehicle,
        currentMileage: vehicle.mileage,
        contactChannel: current.draft.contactChannel,
      ),
    );
  }

  Future<void> selectWorkshop(OtoxpertWorkshop workshop) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        workshop: workshop,
        clearService: true,
        clearSchedule: true,
      ),
    );
  }

  Future<void> selectService(OtoxpertService service) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(service: service, clearSchedule: true),
    );
  }

  Future<void> saveDetails({
    required int mileage,
    required String complaint,
    required List<String> symptoms,
    required String? lastServiceDate,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        currentMileage: mileage,
        complaint: complaint.trim(),
        symptomCodes: symptoms,
        lastServiceDate: lastServiceDate,
      ),
    );
  }

  Future<void> saveSchedule({
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        primarySlot: primary,
        alternativeSlot: alternative,
      ),
    );
  }

  Future<void> saveReview({
    required bool pickupDeliveryRequested,
    required String contactChannel,
    required bool partnerConsent,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        pickupDeliveryRequested: pickupDeliveryRequested,
        contactChannel: contactChannel,
        partnerConsent: partnerConsent,
      ),
    );
  }

  Future<void> addPhotos(int limit) async {
    var current = state.value;
    if (current == null || current.isUploading) return;
    final remaining = limit - current.draft.photos.length;
    if (remaining <= 0) return;
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 82,
      maxWidth: 1600,
      limit: remaining,
    );
    if (picked.isEmpty) return;
    state = AsyncData(
      current.copyWith(isUploading: true, clearError: true),
    );
    try {
      for (final photo in picked.take(remaining)) {
        final assetId = await _repository.uploadPhoto(
          await photo.readAsBytes(),
          filename: photo.name,
        );
        current = state.value;
        if (current == null) return;
        final draft = current.draft.copyWith(
          photos: [
            ...current.draft.photos,
            ToyotaServiceDraftPhoto(assetId: assetId, name: photo.name),
          ],
        );
        await _repository.saveDraft(draft);
        state = AsyncData(current.copyWith(draft: draft, isUploading: true));
      }
      current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(isUploading: false));
      }
    } catch (error) {
      current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            isUploading: false,
            error: _friendlyError(error),
          ),
        );
      }
    }
  }

  Future<void> removePhoto(String assetId) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        photos: current.draft.photos
            .where((item) => item.assetId != assetId)
            .toList(growable: false),
      ),
    );
  }

  Future<OtoxpertBooking?> submit(OtoxpertOptions options) async {
    var current = state.value;
    if (current == null || current.isSubmitting || !current.draft.canSubmit) {
      return null;
    }
    var draft = current.draft;
    if (draft.idempotencyKey == null) {
      draft = draft.copyWith(idempotencyKey: _uuidV4());
      await _repository.saveDraft(draft);
    }
    state = AsyncData(
      current.copyWith(
        draft: draft,
        isSubmitting: true,
        clearError: true,
      ),
    );
    try {
      final booking = await _repository.submit(
        draft,
        options.partnerConsentVersion,
      );
      await _repository.clearDraft();
      state = const AsyncData(OtoxpertFlowState(draft: OtoxpertDraft()));
      ref.invalidate(otoxpertBookingsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      return booking;
    } catch (error) {
      current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            isSubmitting: false,
            error: _friendlyError(error),
          ),
        );
      }
      return null;
    }
  }

  Future<void> reset() async {
    await _repository.clearDraft();
    state = const AsyncData(OtoxpertFlowState(draft: OtoxpertDraft()));
  }

  Future<void> _save(OtoxpertDraft draft) async {
    final current = state.value;
    if (current == null) return;
    draft = draft.copyWith(clearIdempotencyKey: true);
    await _repository.saveDraft(draft);
    state = AsyncData(
      current.copyWith(draft: draft, clearError: true),
    );
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}

final otoxpertFlowProvider =
    AsyncNotifierProvider<OtoxpertFlowController, OtoxpertFlowState>(
  OtoxpertFlowController.new,
);

class OtoxpertMutationController extends AsyncNotifier<OtoxpertBooking?> {
  @override
  Future<OtoxpertBooking?> build() async => null;

  OtoxpertRepository get _repository => ref.read(otoxpertRepositoryProvider);

  Future<OtoxpertBooking?> acceptAlternative(String bookingId) =>
      _run(bookingId, () => _repository.acceptAlternative(bookingId));

  Future<OtoxpertBooking?> sendSchedule(
    String bookingId, {
    required String action,
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    required String reason,
  }) =>
      _run(
        bookingId,
        () => _repository.sendSchedule(
          bookingId,
          action: action,
          primary: primary,
          alternative: alternative,
          reason: reason,
        ),
      );

  Future<OtoxpertBooking?> cancel(String bookingId, String reason) =>
      _run(bookingId, () => _repository.cancel(bookingId, reason));

  Future<OtoxpertBooking?> _run(
    String bookingId,
    Future<OtoxpertBooking> Function() action,
  ) async {
    state = const AsyncLoading();
    try {
      final booking = await action();
      state = AsyncData(booking);
      ref.invalidate(otoxpertBookingProvider(bookingId));
      ref.invalidate(otoxpertBookingsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      return booking;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final otoxpertMutationProvider =
    AsyncNotifierProvider<OtoxpertMutationController, OtoxpertBooking?>(
  OtoxpertMutationController.new,
);

class AdminOtoxpertMutationController extends AsyncNotifier<OtoxpertBooking?> {
  @override
  Future<OtoxpertBooking?> build() async => null;

  Future<OtoxpertBooking?> perform(
    String bookingId,
    String action,
    Map<String, dynamic> fields,
  ) async {
    state = const AsyncLoading();
    try {
      final booking = await ref
          .read(otoxpertRepositoryProvider)
          .performAdminAction(bookingId, action, fields);
      state = AsyncData(booking);
      ref.invalidate(adminOtoxpertBookingProvider(bookingId));
      ref.invalidate(adminOtoxpertBookingsProvider);
      return booking;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final adminOtoxpertMutationProvider =
    AsyncNotifierProvider<AdminOtoxpertMutationController, OtoxpertBooking?>(
  AdminOtoxpertMutationController.new,
);

String _friendlyError(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is Map<String, dynamic>) {
        final messages = errors.values
            .whereType<List<dynamic>>()
            .expand((items) => items)
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .join('\n');
        if (messages.isNotEmpty) return messages;
      }
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
  }
  return 'general';
}
