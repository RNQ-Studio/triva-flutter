import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data/appraisal_repository.dart';
import '../domain/appraisal_models.dart';

final appraisalRepositoryProvider = Provider<AppraisalRepository>((ref) {
  final auth = ref.watch(authProvider);
  final storage = ref.watch(storageServiceProvider);
  return AppraisalRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    storage: storage,
    userId: auth is AuthAuthenticated ? auth.user.id : null,
  );
});

final appraisalsProvider = FutureProvider<List<AppraisalData>>((ref) {
  return ref.watch(appraisalRepositoryProvider).listAppraisals();
});

final vehicleMakesProvider = FutureProvider<List<VehicleMakeOption>>((ref) {
  return ref.watch(appraisalRepositoryProvider).listVehicleMakes();
});

final vehicleModelsProvider =
    FutureProvider.family<List<VehicleModelOption>, int>((ref, makeId) {
  return ref.watch(appraisalRepositoryProvider).listVehicleModels(makeId);
});

final vehicleVariantsProvider =
    FutureProvider.family<List<VehicleVariantOption>, int>((ref, modelId) {
  return ref
      .watch(appraisalRepositoryProvider)
      .listVehicleVariants(modelId: modelId);
}, retry: (_, __) => null);

final appraisalDetailProvider =
    FutureProvider.family<AppraisalData, String>((ref, appraisalId) {
  return ref.watch(appraisalRepositoryProvider).getAppraisal(appraisalId);
});

class AppraisalFlowState {
  const AppraisalFlowState({
    required this.draft,
    this.isSubmitting = false,
    this.uploadProgress = 0,
    this.stage,
    this.error,
    this.submitted,
  });

  final AppraisalDraft draft;
  final bool isSubmitting;
  final double uploadProgress;
  final String? stage;
  final String? error;
  final AppraisalData? submitted;

  AppraisalFlowState copyWith({
    AppraisalDraft? draft,
    bool? isSubmitting,
    double? uploadProgress,
    String? stage,
    String? error,
    AppraisalData? submitted,
    bool clearError = false,
    bool clearSubmitted = false,
  }) =>
      AppraisalFlowState(
        draft: draft ?? this.draft,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        stage: stage ?? this.stage,
        error: clearError ? null : error ?? this.error,
        submitted: clearSubmitted ? null : submitted ?? this.submitted,
      );
}

class AppraisalFlowController extends AsyncNotifier<AppraisalFlowState> {
  AppraisalRepository get _repository => ref.read(appraisalRepositoryProvider);

  @override
  Future<AppraisalFlowState> build() async {
    final repository = ref.watch(appraisalRepositoryProvider);
    await _removeUnscopedLegacyPhotos();
    return AppraisalFlowState(draft: await repository.loadDraft());
  }

  Future<void> saveIdentity({
    required int makeId,
    required int modelId,
    required String make,
    required String model,
    required int? variantId,
    required String variant,
    required int year,
    String? variantTransmission,
    String? variantFuelType,
  }) =>
      _updateDraft(
        (draft) {
          final normalizedMake = make.trim();
          final normalizedModel = model.trim();
          final normalizedVariant = variant.trim();
          final payloadChanged = draft.makeId != makeId ||
              draft.modelId != modelId ||
              draft.variantId != variantId ||
              draft.make != normalizedMake ||
              draft.model != normalizedModel ||
              draft.variant != normalizedVariant ||
              draft.year != year ||
              draft.transmission !=
                  (variantTransmission ?? draft.transmission) ||
              draft.fuelType != (variantFuelType ?? draft.fuelType);
          final rotateCreationKeys = draft.vehicleId == null && payloadChanged;
          return draft.copyWith(
            makeId: makeId,
            modelId: modelId,
            make: normalizedMake,
            model: normalizedModel,
            variantId: variantId,
            clearVariantId: variantId == null,
            variant: normalizedVariant,
            year: year,
            transmission: variantTransmission,
            fuelType: variantFuelType,
            clearVehicleCreationIdempotencyKey: rotateCreationKeys,
            clearAppraisalCreationIdempotencyKey: rotateCreationKeys,
          );
        },
      );

  Future<void> saveDetails({
    required String transmission,
    required String fuelType,
    required int mileage,
    required String color,
    required String licensePlate,
    required int provinceId,
    required int cityId,
    required String city,
  }) =>
      _updateDraft(
        (draft) {
          final normalizedColor = color.trim();
          final normalizedLicensePlate = licensePlate.trim().toUpperCase();
          final normalizedCity = city.trim();
          final payloadChanged = draft.transmission != transmission ||
              draft.fuelType != fuelType ||
              draft.mileage != mileage ||
              draft.color != normalizedColor ||
              draft.licensePlate != normalizedLicensePlate ||
              draft.provinceId != provinceId ||
              draft.cityId != cityId ||
              draft.city != normalizedCity;
          final rotateCreationKeys = draft.vehicleId == null && payloadChanged;
          return draft.copyWith(
            transmission: transmission,
            fuelType: fuelType,
            mileage: mileage,
            color: normalizedColor,
            licensePlate: normalizedLicensePlate,
            provinceId: provinceId,
            cityId: cityId,
            city: normalizedCity,
            clearVehicleCreationIdempotencyKey: rotateCreationKeys,
            clearAppraisalCreationIdempotencyKey: rotateCreationKeys,
          );
        },
      );

  Future<void> saveCondition({
    required String taxStatus,
    required String floodHistory,
    required String majorAccidentHistory,
    required String serviceHistory,
    required String ownership,
    required int conditionPercentage,
    required String conditionGrade,
    required String engineCondition,
    required String tyreCondition,
  }) =>
      _updateDraft(
        (draft) => draft.copyWith(
          taxStatus: taxStatus,
          floodHistory: floodHistory,
          majorAccidentHistory: majorAccidentHistory,
          serviceHistory: serviceHistory,
          ownership: ownership,
          conditionPercentage: conditionPercentage,
          conditionGrade: conditionGrade,
          engineCondition: engineCondition,
          tyreCondition: tyreCondition,
        ),
      );

  Future<void> saveMarketingConsent(bool value) =>
      _updateDraft((draft) => draft.copyWith(marketingConsent: value));

  Future<void> savePhoto(String angle, XFile photo) async {
    final current = state.value;
    if (current == null) return;

    final directory = await _scopedPhotoDirectory();
    await directory.create(recursive: true);
    final extension = photo.name.contains('.')
        ? photo.name.substring(photo.name.lastIndexOf('.')).toLowerCase()
        : '.jpg';
    final target = File(
      '${directory.path}${Platform.pathSeparator}$angle$extension',
    );
    final previousPath = current.draft.photoPaths[angle];
    if (previousPath != null && previousPath != target.path) {
      final previous = File(previousPath);
      if (await previous.exists()) await previous.delete();
    }
    await File(photo.path).copy(target.path);

    final paths = Map<String, String>.from(current.draft.photoPaths)
      ..[angle] = target.path;
    final assetIds = Map<String, String>.from(current.draft.assetIds)
      ..remove(angle);
    await _setDraft(
      current.draft.copyWith(photoPaths: paths, assetIds: assetIds),
    );
  }

  Future<AppraisalData?> submit() async {
    var current = state.value;
    if (current == null || current.isSubmitting) return null;
    var draft = current.draft;
    final missingLocalPhotos = <String>[];
    for (final angle in appraisalPhotoAngles) {
      if (draft.assetIds.containsKey(angle)) continue;
      final path = draft.photoPaths[angle];
      if (path == null || !await File(path).exists()) {
        missingLocalPhotos.add(angle);
      }
    }
    if (missingLocalPhotos.isNotEmpty) {
      final paths = Map<String, String>.from(draft.photoPaths);
      for (final angle in missingLocalPhotos) {
        paths.remove(angle);
      }
      draft = draft.copyWith(photoPaths: paths);
      await _repository.saveDraft(draft);
      current = current.copyWith(draft: draft);
    }
    if (!draft.hasIdentity ||
        !draft.hasDetails ||
        !draft.hasCondition ||
        !draft.hasAllPhotos) {
      state = AsyncData(
        current.copyWith(error: 'incomplete'),
      );
      return null;
    }

    state = AsyncData(
      current.copyWith(
        isSubmitting: true,
        uploadProgress: 0,
        stage: 'prepare_vehicle',
        clearError: true,
      ),
    );

    try {
      if (draft.appraisalId != null) {
        final remote = await _repository.getAppraisal(draft.appraisalId!);
        if (remote.status != 'draft') {
          await _clearLocalDraft();
          state = AsyncData(
            AppraisalFlowState(
              draft: const AppraisalDraft(),
              submitted: remote,
              uploadProgress: 1,
              stage: 'success',
            ),
          );
          ref.invalidate(appraisalsProvider);
          return remote;
        }
      }

      if (draft.vehicleId == null) {
        final creationKey = draft.vehicleCreationIdempotencyKey ?? _uuidV4();
        draft = draft.copyWith(
          vehicleCreationIdempotencyKey: creationKey,
        );
        // Persist the operation identity before the first network attempt. If
        // the response is lost after the backend commits, retrying or resuming
        // after restart reuses this key and receives the original vehicle.
        await _persistDuringSubmit(draft, 'prepare_vehicle');
        final vehicle = await _repository.createVehicle(
          draft.toVehicle(),
          idempotencyKey: creationKey,
        );
        draft = draft.copyWith(vehicleId: vehicle.id);
        await _persistDuringSubmit(draft, 'create_request');
      } else {
        await _repository.updateVehicle(
          draft.vehicleId!,
          draft.toVehicle(),
        );
      }

      if (draft.appraisalId == null) {
        final creationKey = draft.appraisalCreationIdempotencyKey ?? _uuidV4();
        draft = draft.copyWith(
          appraisalCreationIdempotencyKey: creationKey,
        );
        await _persistDuringSubmit(draft, 'create_request');
        final appraisal = await _repository.createAppraisal(
          draft.vehicleId!,
          idempotencyKey: creationKey,
        );
        draft = draft.copyWith(appraisalId: appraisal.id);
        await _persistDuringSubmit(draft, 'save_condition');
      }

      await _repository.updateCondition(
        draft.appraisalId!,
        draft.conditionJson,
      );

      final assetIds = Map<String, String>.from(draft.assetIds);
      for (var index = 0; index < appraisalPhotoAngles.length; index++) {
        final angle = appraisalPhotoAngles[index];
        if (assetIds.containsKey(angle)) continue;
        final path = draft.photoPaths[angle]!;
        final assetId = await _repository.uploadPhoto(
          path,
          onProgress: (value) {
            final progress = (index + value) / appraisalPhotoAngles.length;
            final latest = state.value;
            if (latest != null) {
              state = AsyncData(
                latest.copyWith(
                  uploadProgress: progress,
                  stage: 'upload:${index + 1}',
                ),
              );
            }
          },
        );
        assetIds[angle] = assetId;
        draft = draft.copyWith(assetIds: assetIds);
        await _repository.saveDraft(draft);
      }

      await _repository.attachPhotos(draft.appraisalId!, assetIds);
      final idempotencyKey = draft.idempotencyKey ?? _uuidV4();
      draft = draft.copyWith(idempotencyKey: idempotencyKey);
      await _persistDuringSubmit(draft, 'submit');
      final submitted = await _repository.submit(
        draft.appraisalId!,
        idempotencyKey: idempotencyKey,
        marketingConsent: draft.marketingConsent,
      );
      await _clearLocalDraft();
      state = AsyncData(
        AppraisalFlowState(
          draft: const AppraisalDraft(),
          submitted: submitted,
          uploadProgress: 1,
          stage: 'success',
        ),
      );
      ref.invalidate(appraisalsProvider);
      return submitted;
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
    await _clearLocalDraft();
    state = const AsyncData(
      AppraisalFlowState(draft: AppraisalDraft()),
    );
  }

  Future<void> _updateDraft(
    AppraisalDraft Function(AppraisalDraft draft) update,
  ) async {
    final current = state.value;
    if (current == null) return;
    await _setDraft(update(current.draft));
  }

  Future<void> _setDraft(AppraisalDraft draft) async {
    await _repository.saveDraft(draft);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: draft,
        clearError: true,
        clearSubmitted: true,
      ),
    );
  }

  Future<void> _persistDuringSubmit(
    AppraisalDraft draft,
    String stage,
  ) async {
    await _repository.saveDraft(draft);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(draft: draft, stage: stage));
    }
  }

  String _friendlyError(Object error) {
    final cause =
        error is DioException && error.error != null ? error.error! : error;
    return switch (cause) {
      NetworkException() => 'network',
      UnauthorizedException() => 'auth',
      _ => 'general',
    };
  }

  Future<void> _removeUnscopedLegacyPhotos() async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final directory = Directory(
        '${root.path}${Platform.pathSeparator}triva_appraisal_draft',
      );
      if (!await directory.exists()) return;
      await for (final entity in directory.list(followLinks: false)) {
        // New account-scoped photos live in subdirectories. Only remove old
        // files placed directly in the shared legacy directory.
        if (entity is File) await entity.delete();
      }
    } on Object {
      // A stale file must not make the flow unusable; scoped writes below still
      // prevent it from being selected by another account.
    }
  }

  Future<Directory> _scopedPhotoDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final auth = ref.read(authProvider);
    final owner = auth is AuthAuthenticated ? auth.user.id : 'anonymous';
    final safeOwner = owner.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return Directory(
      '${root.path}${Platform.pathSeparator}triva_appraisal_draft'
      '${Platform.pathSeparator}$safeOwner',
    );
  }

  Future<void> _clearLocalDraft() async {
    await _repository.clearDraft();
    try {
      final directory = await _scopedPhotoDirectory();
      if (await directory.exists()) await directory.delete(recursive: true);
    } on Object {
      // The storage record is authoritative. Orphan cleanup can retry without
      // turning a successful submit into a visible failure.
    }
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

final appraisalFlowProvider =
    AsyncNotifierProvider<AppraisalFlowController, AppraisalFlowState>(
        AppraisalFlowController.new);
