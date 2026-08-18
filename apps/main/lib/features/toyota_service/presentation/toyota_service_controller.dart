import 'dart:convert';
import 'dart:math';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/toyota_service_repository.dart';
import '../domain/toyota_service_models.dart';

abstract class ToyotaServicePhotoPicker {
  Future<List<XFile>> pickImages({required int limit});
}

class DefaultToyotaServicePhotoPicker implements ToyotaServicePhotoPicker {
  @override
  Future<List<XFile>> pickImages({required int limit}) {
    return ImagePicker().pickMultiImage(
      imageQuality: 82,
      maxWidth: 1600,
      limit: limit,
    );
  }
}

final toyotaServicePhotoPickerProvider = Provider<ToyotaServicePhotoPicker>(
  (_) => DefaultToyotaServicePhotoPicker(),
);

final toyotaServiceRepositoryProvider =
    Provider<ToyotaServiceRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authProvider);
  final userId = auth is AuthAuthenticated ? auth.user.id : null;
  return ToyotaServiceRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    storage: storage,
    userId: userId,
  );
});

final toyotaServiceVehiclesProvider =
    FutureProvider<List<ToyotaServiceVehicle>>((ref) {
  return ref.watch(toyotaServiceRepositoryProvider).listVehicles();
});

final toyotaServiceOptionsProvider =
    FutureProvider<ToyotaServiceOptions>((ref) {
  return ref.watch(toyotaServiceRepositoryProvider).getOptions();
});

final toyotaServiceBookingsProvider =
    FutureProvider<List<ToyotaServiceBooking>>((ref) {
  return ref.watch(toyotaServiceRepositoryProvider).listBookings();
});

final toyotaServiceBookingDetailProvider =
    FutureProvider.family<ToyotaServiceBooking, String>((ref, bookingId) {
  return ref.watch(toyotaServiceRepositoryProvider).getBooking(bookingId);
});

class AdminToyotaServiceQuery {
  const AdminToyotaServiceQuery({
    this.status,
    this.search,
    this.serviceTypeId,
    this.serviceLocationId,
    this.fulfillmentType,
    this.date,
    this.advisorId,
    this.slaOverdue,
    this.sort = 'updated_desc',
  });

  final String? status;
  final String? search;
  final String? serviceTypeId;
  final String? serviceLocationId;
  final String? fulfillmentType;
  final String? date;
  final String? advisorId;
  final bool? slaOverdue;
  final String sort;

  AdminToyotaServiceQuery copyWith({
    String? status,
    String? search,
    String? fulfillmentType,
    String? serviceTypeId,
    String? serviceLocationId,
    String? advisorId,
    String? date,
    bool? slaOverdue,
    String? sort,
    bool clearStatus = false,
    bool clearSearch = false,
    bool clearFulfillment = false,
    bool clearServiceType = false,
    bool clearServiceLocation = false,
    bool clearAdvisor = false,
    bool clearDate = false,
    bool clearSla = false,
  }) =>
      AdminToyotaServiceQuery(
        status: clearStatus ? null : status ?? this.status,
        search: clearSearch ? null : search ?? this.search,
        fulfillmentType:
            clearFulfillment ? null : fulfillmentType ?? this.fulfillmentType,
        slaOverdue: clearSla ? null : slaOverdue ?? this.slaOverdue,
        serviceTypeId:
            clearServiceType ? null : serviceTypeId ?? this.serviceTypeId,
        serviceLocationId: clearServiceLocation
            ? null
            : serviceLocationId ?? this.serviceLocationId,
        date: clearDate ? null : date ?? this.date,
        advisorId: clearAdvisor ? null : advisorId ?? this.advisorId,
        sort: sort ?? this.sort,
      );

  @override
  bool operator ==(Object other) =>
      other is AdminToyotaServiceQuery &&
      status == other.status &&
      search == other.search &&
      serviceTypeId == other.serviceTypeId &&
      serviceLocationId == other.serviceLocationId &&
      fulfillmentType == other.fulfillmentType &&
      date == other.date &&
      advisorId == other.advisorId &&
      slaOverdue == other.slaOverdue &&
      sort == other.sort;

  @override
  int get hashCode => Object.hash(
        status,
        search,
        serviceTypeId,
        serviceLocationId,
        fulfillmentType,
        date,
        advisorId,
        slaOverdue,
        sort,
      );
}

class AdminToyotaServiceQueryController
    extends Notifier<AdminToyotaServiceQuery> {
  @override
  AdminToyotaServiceQuery build() => const AdminToyotaServiceQuery();

  void update(AdminToyotaServiceQuery value) => state = value;
}

final adminToyotaServiceQueryProvider = NotifierProvider<
    AdminToyotaServiceQueryController,
    AdminToyotaServiceQuery>(AdminToyotaServiceQueryController.new);

final adminToyotaServiceFilteredBookingsProvider =
    FutureProvider.family<List<ToyotaServiceBooking>, AdminToyotaServiceQuery>(
        (ref, query) {
  return ref.watch(toyotaServiceRepositoryProvider).listAdminBookings(
        status: query.status,
        search: query.search,
        serviceTypeId: query.serviceTypeId,
        serviceLocationId: query.serviceLocationId,
        fulfillmentType: query.fulfillmentType,
        date: query.date,
        advisorId: query.advisorId,
        slaOverdue: query.slaOverdue,
        sort: query.sort,
      );
});

final adminToyotaServiceBookingsProvider =
    FutureProvider<List<ToyotaServiceBooking>>((ref) {
  return ref.watch(toyotaServiceRepositoryProvider).listAdminBookings();
});

final adminToyotaServiceBookingDetailProvider =
    FutureProvider.family<ToyotaServiceBooking, String>((ref, bookingId) {
  return ref.watch(toyotaServiceRepositoryProvider).getAdminBooking(bookingId);
});

final adminToyotaServiceOptionsProvider =
    FutureProvider<ToyotaServiceAdminOptions>((ref) {
  return ref.watch(toyotaServiceRepositoryProvider).getAdminOptions();
});

class ToyotaServiceAvailabilityQuery {
  const ToyotaServiceAvailabilityQuery({
    required this.serviceTypeId,
    required this.fulfillment,
    required this.fromDate,
    this.serviceLocationId,
    this.city,
    this.latitude,
    this.longitude,
  });

  final String serviceTypeId;
  final ToyotaServiceFulfillment fulfillment;
  final DateTime fromDate;
  final String? serviceLocationId;
  final String? city;
  final double? latitude;
  final double? longitude;

  @override
  bool operator ==(Object other) =>
      other is ToyotaServiceAvailabilityQuery &&
      serviceTypeId == other.serviceTypeId &&
      fulfillment == other.fulfillment &&
      _dateOnly(fromDate) == _dateOnly(other.fromDate) &&
      serviceLocationId == other.serviceLocationId &&
      city == other.city &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => Object.hash(
        serviceTypeId,
        fulfillment,
        _dateOnly(fromDate),
        serviceLocationId,
        city,
        latitude,
        longitude,
      );

  static String _dateOnly(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
}

final toyotaServiceAvailabilityProvider = FutureProvider.family<
    ToyotaServiceAvailability, ToyotaServiceAvailabilityQuery>((ref, query) {
  return ref.watch(toyotaServiceRepositoryProvider).getAvailability(
        serviceTypeId: query.serviceTypeId,
        fulfillment: query.fulfillment,
        fromDate: query.fromDate,
        serviceLocationId: query.serviceLocationId,
        city: query.city,
        latitude: query.latitude,
        longitude: query.longitude,
      );
});

class ToyotaServiceFlowState {
  const ToyotaServiceFlowState({
    required this.draft,
    this.isSubmitting = false,
    this.error,
    this.submitted,
  });

  final ToyotaServiceDraft draft;
  final bool isSubmitting;
  final String? error;
  final ToyotaServiceBooking? submitted;

  ToyotaServiceFlowState copyWith({
    ToyotaServiceDraft? draft,
    bool? isSubmitting,
    String? error,
    ToyotaServiceBooking? submitted,
    bool clearError = false,
    bool clearSubmitted = false,
  }) =>
      ToyotaServiceFlowState(
        draft: draft ?? this.draft,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : error ?? this.error,
        submitted: clearSubmitted ? null : submitted ?? this.submitted,
      );
}

class ToyotaServiceFlowController
    extends AsyncNotifier<ToyotaServiceFlowState> {
  ToyotaServiceRepository get _repository =>
      ref.read(toyotaServiceRepositoryProvider);

  @override
  Future<ToyotaServiceFlowState> build() async {
    return ToyotaServiceFlowState(draft: await _repository.loadDraft());
  }

  Future<void> selectVehicle(ToyotaServiceVehicle vehicle) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      ToyotaServiceDraft(
        vehicle: vehicle,
        currentMileage: vehicle.mileage,
        contactChannel: current.draft.contactChannel,
      ),
    );
  }

  Future<void> selectFulfillment({
    required ToyotaServiceFulfillment fulfillment,
    ToyotaServiceLocation? location,
  }) async {
    final current = state.value;
    if (current == null) return;
    final serviceStillSupported =
        current.draft.serviceType?.supports(fulfillment) ?? true;
    await _setDraft(
      current.draft.copyWith(
        fulfillmentType: fulfillment,
        serviceLocation: location,
        clearService: !serviceStillSupported,
        clearSchedule: true,
      ),
    );
  }

  Future<void> selectService(ToyotaServiceType serviceType) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        serviceType: serviceType,
        clearSchedule: true,
      ),
    );
  }

  Future<void> saveDetails({
    required int currentMileage,
    required String complaint,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        currentMileage: currentMileage,
        complaint: complaint.trim(),
      ),
    );
  }

  Future<void> savePhoto(
    XFile photo, {
    void Function(int sent, int total)? onProgress,
  }) async {
    var current = state.value;
    if (current == null) return;
    if (current.draft.photos.length >= 5) {
      throw StateError('Maximum supporting photos reached.');
    }
    final bytes = await photo.readAsBytes();
    final assetId = await _repository.uploadSupportingPhoto(
      bytes,
      filename: photo.name,
      onProgress: onProgress,
    );
    current = state.value;
    if (current == null) return;
    if (current.draft.photos.length >= 5) {
      throw StateError('Maximum supporting photos reached.');
    }
    await _setDraft(
      current.draft.copyWith(
        photos: [
          ...current.draft.photos,
          ToyotaServiceDraftPhoto(assetId: assetId, name: photo.name),
        ],
      ),
    );
  }

  Future<void> removePhoto(String assetId) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        photos: current.draft.photos
            .where((item) => item.assetId != assetId)
            .toList(growable: false),
      ),
    );
  }

  Future<void> saveSchedule({
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        primarySlot: primary,
        alternativeSlot: alternative,
      ),
    );
  }

  Future<void> saveThsAddress({
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        thsAddress: address.trim(),
        thsCity: city.trim(),
        thsLatitude: latitude,
        thsLongitude: longitude,
        thsLocationNotes: notes.trim(),
      ),
    );
  }

  Future<void> saveReview({
    required String contactChannel,
    required bool serviceConsent,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(
      current.draft.copyWith(
        contactChannel: contactChannel,
        serviceConsent: serviceConsent,
      ),
    );
  }

  Future<ToyotaServiceBooking?> submit() async {
    var current = state.value;
    if (current == null || current.isSubmitting) return null;
    if (!current.draft.canSubmit) {
      state = AsyncData(current.copyWith(error: 'incomplete'));
      return null;
    }

    var draft = current.draft;
    try {
      final options = await _repository.getOptions();
      if (!options.supportsOperationalDraft(draft)) {
        state = AsyncData(current.copyWith(error: 'selection_changed'));
        return null;
      }
    } catch (error) {
      state = AsyncData(current.copyWith(error: _friendlyError(error)));
      return null;
    }
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
      final submitted = await _repository.submit(draft);
      await _repository.clearDraft();
      state = AsyncData(
        ToyotaServiceFlowState(
          draft: const ToyotaServiceDraft(),
          submitted: submitted,
        ),
      );
      ref.invalidate(toyotaServiceBookingsProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      return submitted;
    } catch (error) {
      current = state.value;
      if (current != null) {
        final persistedDraft = await _repository.loadDraft();
        state = AsyncData(
          current.copyWith(
            draft: persistedDraft,
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
    state = const AsyncData(
      ToyotaServiceFlowState(draft: ToyotaServiceDraft()),
    );
  }

  Future<void> _setDraft(ToyotaServiceDraft draft) async {
    final current = state.value;
    if (current == null) return;
    if (!_samePayload(current.draft, draft)) {
      draft = draft.copyWith(clearIdempotencyKey: true);
    }
    await _repository.saveDraft(draft);
    state = AsyncData(
      current.copyWith(
        draft: draft,
        clearError: true,
        clearSubmitted: true,
      ),
    );
  }

  bool _samePayload(ToyotaServiceDraft left, ToyotaServiceDraft right) {
    final leftJson = Map<String, dynamic>.from(left.toJson())
      ..remove('idempotency_key');
    final rightJson = Map<String, dynamic>.from(right.toJson())
      ..remove('idempotency_key');
    return jsonEncode(leftJson) == jsonEncode(rightJson);
  }

  String _friendlyError(Object error) {
    final cause =
        error is DioException && error.error != null ? error.error! : error;
    if (cause is NetworkException) return 'network';
    if (cause is UnauthorizedException) return 'auth';
    if (cause is ServerException) {
      if (cause.statusCode == 429 ||
          cause.code == 'TOYOTA_SERVICE_RATE_LIMITED') {
        return 'rate_limited';
      }
      if (cause.code == 'TOYOTA_SERVICE_DUPLICATE_ACTIVE' ||
          cause.code == 'TOYOTA_SERVICE_IDEMPOTENCY_CONFLICT') {
        return 'duplicate';
      }
      if (cause.statusCode == 409) return cause.message;
      if (cause.validationErrors.isNotEmpty) {
        return cause.validationErrors.values
            .expand((messages) => messages)
            .join('\n');
      }
    }
    return 'general';
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}

final toyotaServiceFlowProvider =
    AsyncNotifierProvider<ToyotaServiceFlowController, ToyotaServiceFlowState>(
        ToyotaServiceFlowController.new);

class ToyotaServiceMutationController
    extends AsyncNotifier<ToyotaServiceBooking?> {
  @override
  Future<ToyotaServiceBooking?> build() async => null;

  ToyotaServiceRepository get _repository =>
      ref.read(toyotaServiceRepositoryProvider);

  Future<ToyotaServiceBooking?> acceptAlternative(String bookingId) => _run(
        bookingId,
        () => _repository.acceptAlternative(bookingId),
      );

  Future<ToyotaServiceBooking?> rejectAlternative(
    String bookingId, {
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    String? reason,
  }) =>
      _run(
        bookingId,
        () => _repository.rejectAlternative(
          bookingId,
          primarySlot: primary,
          alternativeSlot: alternative,
          reason: reason,
        ),
      );

  Future<ToyotaServiceBooking?> requestReschedule(
    String bookingId, {
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    required String reason,
  }) =>
      _run(
        bookingId,
        () => _repository.requestReschedule(
          bookingId,
          primarySlot: primary,
          alternativeSlot: alternative,
          reason: reason,
        ),
      );

  Future<ToyotaServiceBooking?> cancelBooking(
    String bookingId, {
    required String reason,
  }) =>
      _run(
        bookingId,
        () => _repository.cancelBooking(bookingId, reason: reason),
      );

  Future<ToyotaServiceBooking?> adminAction(
    String bookingId, {
    required String action,
    Map<String, dynamic> fields = const {},
  }) =>
      _run(
        bookingId,
        () => _repository.performAdminAction(
          bookingId,
          action: action,
          fields: fields,
        ),
        admin: true,
      );

  Future<ToyotaServiceBooking?> _run(
    String bookingId,
    Future<ToyotaServiceBooking> Function() operation, {
    bool admin = false,
  }) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final booking = await operation();
      state = AsyncData(booking);
      _refreshBookingState(bookingId, admin: admin);
      return booking;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      // A conflict can still mean the server reconciled an expired proposal
      // before rejecting the requested action. Always reload source-of-truth
      // state so stale CTAs are not left visible after any failed mutation.
      _refreshBookingState(bookingId, admin: admin);
      return null;
    }
  }

  void _refreshBookingState(String bookingId, {required bool admin}) {
    ref.invalidate(toyotaServiceBookingsProvider);
    ref.invalidate(toyotaServiceBookingDetailProvider(bookingId));
    if (admin) {
      ref.invalidate(adminToyotaServiceBookingsProvider);
      ref.invalidate(adminToyotaServiceFilteredBookingsProvider);
      ref.invalidate(adminToyotaServiceBookingDetailProvider(bookingId));
    }
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final toyotaServiceMutationProvider = AsyncNotifierProvider<
    ToyotaServiceMutationController,
    ToyotaServiceBooking?>(ToyotaServiceMutationController.new);
