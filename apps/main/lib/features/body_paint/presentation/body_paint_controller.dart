import 'dart:math';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../toyota_service/domain/toyota_service_models.dart';
import '../data/body_paint_repository.dart';
import '../domain/body_paint_models.dart';

final bodyPaintRepositoryProvider = Provider<BodyPaintRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = ref.watch(authProvider);
  return BodyPaintRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    storage: storage,
    userId: auth is AuthAuthenticated ? auth.user.id : null,
  );
});

final bodyPaintOptionsProvider = FutureProvider<BodyPaintOptions>((ref) {
  return ref.watch(bodyPaintRepositoryProvider).getOptions();
});

final bodyPaintVehiclesProvider =
    FutureProvider<List<ToyotaServiceVehicle>>((ref) {
  return ref.watch(bodyPaintRepositoryProvider).listVehicles();
});

final bodyPaintEstimatesProvider =
    FutureProvider<List<BodyPaintEstimate>>((ref) {
  return ref.watch(bodyPaintRepositoryProvider).listEstimates();
});

final bodyPaintEstimateProvider =
    FutureProvider.family<BodyPaintEstimate, String>((ref, estimateId) {
  return ref.watch(bodyPaintRepositoryProvider).getEstimate(estimateId);
});

final adminBodyPaintEstimatesProvider =
    FutureProvider<List<BodyPaintEstimate>>((ref) {
  return ref.watch(bodyPaintRepositoryProvider).listAdminEstimates();
});

final adminBodyPaintEstimateProvider =
    FutureProvider.family<BodyPaintEstimate, String>((ref, estimateId) {
  return ref.watch(bodyPaintRepositoryProvider).getAdminEstimate(estimateId);
});

final adminBodyPaintOptionsProvider =
    FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(bodyPaintRepositoryProvider).getAdminOptions();
});

class BodyPaintAvailabilityQuery {
  const BodyPaintAvailabilityQuery({
    required this.locationId,
    required this.serviceTypeId,
  });

  final String locationId;
  final String serviceTypeId;

  @override
  bool operator ==(Object other) =>
      other is BodyPaintAvailabilityQuery &&
      other.locationId == locationId &&
      other.serviceTypeId == serviceTypeId;

  @override
  int get hashCode => Object.hash(locationId, serviceTypeId);
}

final bodyPaintAvailabilityProvider = FutureProvider.family<
    ToyotaServiceAvailability, BodyPaintAvailabilityQuery>((ref, query) {
  return ref.watch(bodyPaintRepositoryProvider).getAvailability(
        locationId: query.locationId,
        serviceTypeId: query.serviceTypeId,
      );
});

class BodyPaintFlowState {
  const BodyPaintFlowState({
    required this.draft,
    this.isUploading = false,
    this.isSubmitting = false,
    this.error,
  });

  final BodyPaintDraft draft;
  final bool isUploading;
  final bool isSubmitting;
  final String? error;

  BodyPaintFlowState copyWith({
    BodyPaintDraft? draft,
    bool? isUploading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) =>
      BodyPaintFlowState(
        draft: draft ?? this.draft,
        isUploading: isUploading ?? this.isUploading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : error ?? this.error,
      );
}

class BodyPaintFlowController extends AsyncNotifier<BodyPaintFlowState> {
  BodyPaintRepository get _repository => ref.read(bodyPaintRepositoryProvider);

  @override
  Future<BodyPaintFlowState> build() async =>
      BodyPaintFlowState(draft: await _repository.loadDraft());

  Future<void> selectVehicle(ToyotaServiceVehicle vehicle) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(vehicle: vehicle, clearRemote: true),
    );
  }

  Future<void> selectLocation(ToyotaServiceLocation location) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(location: location, clearRemote: true),
    );
  }

  Future<void> addDamage() async {
    final current = state.value;
    if (current == null || current.draft.damages.length >= 9) return;
    final damage = BodyPaintDraftDamage(key: _uuidV4());
    await _save(
      current.draft.copyWith(
        damages: [...current.draft.damages, damage],
        clearRemote: true,
      ),
    );
  }

  Future<void> updateDamage(
    String key, {
    String? panelCode,
    String? damageType,
    String? severity,
    String? note,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        damages: [
          for (final damage in current.draft.damages)
            if (damage.key == key)
              damage.copyWith(
                panelCode: panelCode,
                damageType: damageType,
                severity: severity,
                note: note,
              )
            else
              damage,
        ],
        clearRemote: true,
      ),
    );
  }

  Future<void> removeDamage(String key) async {
    final current = state.value;
    if (current == null) return;
    await _save(
      current.draft.copyWith(
        damages: current.draft.damages
            .where((damage) => damage.key != key)
            .toList(growable: false),
        clearRemote: true,
      ),
    );
  }

  Future<void> setDetails(
      {required String notes, required bool consent}) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.draft.copyWith(notes: notes, consent: consent));
  }

  Future<void> pickDamagePhoto(String key) async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (photo == null) return;
    await _upload(
      () async {
        final assetId = await _repository.uploadPhoto(
          await photo.readAsBytes(),
          filename: photo.name,
        );
        final current = state.value;
        if (current == null) return;
        await _save(
          current.draft.copyWith(
            damages: [
              for (final damage in current.draft.damages)
                if (damage.key == key)
                  damage.copyWith(
                    closePhotoAssetId: assetId,
                    closePhotoName: photo.name,
                  )
                else
                  damage,
            ],
            clearRemote: true,
          ),
        );
      },
    );
  }

  Future<void> pickContextPhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (photo == null) return;
    await _upload(
      () async {
        final assetId = await _repository.uploadPhoto(
          await photo.readAsBytes(),
          filename: photo.name,
        );
        final current = state.value;
        if (current == null) return;
        await _save(
          current.draft.copyWith(
            contextPhotoAssetId: assetId,
            contextPhotoName: photo.name,
            clearRemote: true,
          ),
        );
      },
    );
  }

  Future<BodyPaintEstimate?> submit() async {
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
      var estimate = draft.estimateId == null
          ? await _repository.createDraft(draft)
          : await _repository.getEstimate(draft.estimateId!);
      draft = draft.copyWith(estimateId: estimate.id);
      await _repository.saveDraft(draft);

      estimate = await _repository.updateDamages(estimate.id, draft.damages);
      final remoteByContract = {
        for (final damage in estimate.damages)
          '${damage.panelCode}|${damage.damageType}': damage.id,
      };
      draft = draft.copyWith(
        damages: [
          for (final damage in draft.damages)
            damage.copyWith(
              remoteId:
                  remoteByContract['${damage.panelCode}|${damage.damageType}'],
            ),
        ],
      );
      await _repository.saveDraft(draft);

      await _repository.attachPhotos(estimate.id, draft);
      estimate = await _repository.submit(estimate.id);
      await _repository.clearDraft();
      state = const AsyncData(BodyPaintFlowState(draft: BodyPaintDraft()));
      _invalidateCustomer();
      return estimate;
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
    state = const AsyncData(BodyPaintFlowState(draft: BodyPaintDraft()));
  }

  Future<void> _upload(Future<void> Function() action) async {
    final current = state.value;
    if (current == null || current.isUploading) return;
    state = AsyncData(current.copyWith(isUploading: true, clearError: true));
    try {
      await action();
      final updated = state.value;
      if (updated != null) {
        state = AsyncData(updated.copyWith(isUploading: false));
      }
    } catch (error) {
      final updated = state.value;
      if (updated != null) {
        state = AsyncData(
          updated.copyWith(
            isUploading: false,
            error: _friendlyError(error),
          ),
        );
      }
    }
  }

  Future<void> _save(BodyPaintDraft draft) async {
    final current = state.value;
    if (current == null) return;
    await _repository.saveDraft(draft);
    state = AsyncData(current.copyWith(draft: draft, clearError: true));
  }

  void _invalidateCustomer() {
    ref.invalidate(bodyPaintEstimatesProvider);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final bodyPaintFlowProvider =
    AsyncNotifierProvider<BodyPaintFlowController, BodyPaintFlowState>(
  BodyPaintFlowController.new,
);

class BodyPaintMutationController extends AsyncNotifier<BodyPaintEstimate?> {
  BodyPaintRepository get _repository => ref.read(bodyPaintRepositoryProvider);

  @override
  Future<BodyPaintEstimate?> build() async => null;

  Future<BodyPaintEstimate?> decide(
    String estimateId,
    String decision, {
    String? reason,
  }) =>
      _run(
        estimateId,
        () => _repository.decide(estimateId, decision, reason: reason),
      );

  Future<BodyPaintEstimate?> replacePhoto(
    String estimateId, {
    required String photoType,
    String? damageId,
  }) async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (photo == null) return null;
    return _run(
      estimateId,
      () async {
        final assetId = await _repository.uploadPhoto(
          await photo.readAsBytes(),
          filename: photo.name,
        );
        return _repository.attachPhoto(
          estimateId,
          assetId: assetId,
          photoType: photoType,
          damageId: damageId,
        );
      },
    );
  }

  Future<BodyPaintEstimate?> resubmit(String estimateId) =>
      _run(estimateId, () => _repository.resubmit(estimateId));

  Future<String?> requestBooking(
    BodyPaintEstimate estimate, {
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    required String complaint,
    required int mileage,
    required String contactChannel,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.requestBooking(
        estimate,
        primary: primary,
        alternative: alternative,
        complaint: complaint,
        mileage: mileage,
        contactChannel: contactChannel,
        idempotencyKey: _uuidV4(),
      );
      final booking = result['booking'] as Map<String, dynamic>?;
      ref.invalidate(bodyPaintEstimateProvider(estimate.id));
      ref.invalidate(bodyPaintEstimatesProvider);
      state = AsyncData(
        result['estimate'] is Map<String, dynamic>
            ? BodyPaintEstimate.fromJson(
                result['estimate'] as Map<String, dynamic>,
              )
            : estimate,
      );
      return booking?['id']?.toString();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<BodyPaintEstimate?> _run(
    String estimateId,
    Future<BodyPaintEstimate> Function() action,
  ) async {
    state = const AsyncLoading();
    try {
      final estimate = await action();
      state = AsyncData(estimate);
      ref.invalidate(bodyPaintEstimateProvider(estimateId));
      ref.invalidate(bodyPaintEstimatesProvider);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
      return estimate;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final bodyPaintMutationProvider =
    AsyncNotifierProvider<BodyPaintMutationController, BodyPaintEstimate?>(
  BodyPaintMutationController.new,
);

class AdminBodyPaintMutationController
    extends AsyncNotifier<BodyPaintEstimate?> {
  @override
  Future<BodyPaintEstimate?> build() async => null;

  Future<BodyPaintEstimate?> perform(
    String estimateId,
    String action,
    Map<String, dynamic> fields,
  ) async {
    state = const AsyncLoading();
    try {
      final estimate = await ref
          .read(bodyPaintRepositoryProvider)
          .performAdminAction(estimateId, action, fields);
      state = AsyncData(estimate);
      ref.invalidate(adminBodyPaintEstimateProvider(estimateId));
      ref.invalidate(adminBodyPaintEstimatesProvider);
      return estimate;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final adminBodyPaintMutationProvider =
    AsyncNotifierProvider<AdminBodyPaintMutationController, BodyPaintEstimate?>(
  AdminBodyPaintMutationController.new,
);

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

String _friendlyError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }
  }
  return 'Permintaan belum berhasil. Periksa koneksi lalu coba lagi.';
}
