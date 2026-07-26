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
  final storage = ref.watch(storageServiceProvider);
  return AppraisalRepository(
    dio: DioClient(storage).dio,
    storage: storage,
  );
});

final appraisalsProvider = FutureProvider<List<AppraisalData>>((ref) {
  return ref.watch(appraisalRepositoryProvider).listAppraisals();
});

final vehicleMakesProvider = FutureProvider<List<VehicleMakeOption>>((ref) {
  return ref.watch(appraisalRepositoryProvider).listVehicleMakes();
});

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
    return AppraisalFlowState(draft: await _repository.loadDraft());
  }

  Future<void> saveIdentity({
    required int makeId,
    required String make,
    required String model,
    required String variant,
    required int year,
  }) =>
      _updateDraft(
        (draft) => draft.copyWith(
          makeId: makeId,
          make: make.trim(),
          model: model.trim(),
          variant: variant.trim(),
          year: year,
        ),
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
        (draft) => draft.copyWith(
          transmission: transmission,
          fuelType: fuelType,
          mileage: mileage,
          color: color.trim(),
          licensePlate: licensePlate.trim().toUpperCase(),
          provinceId: provinceId,
          cityId: cityId,
          city: city.trim(),
        ),
      );

  Future<void> saveCondition({
    required String taxStatus,
    required String floodHistory,
    required String majorAccidentHistory,
    required String serviceHistory,
    required String ownership,
  }) =>
      _updateDraft(
        (draft) => draft.copyWith(
          taxStatus: taxStatus,
          floodHistory: floodHistory,
          majorAccidentHistory: majorAccidentHistory,
          serviceHistory: serviceHistory,
          ownership: ownership,
        ),
      );

  Future<void> saveMarketingConsent(bool value) =>
      _updateDraft((draft) => draft.copyWith(marketingConsent: value));

  Future<void> savePhoto(String angle, XFile photo) async {
    final current = state.value;
    if (current == null) return;

    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}triva_appraisal_draft',
    );
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
          await _repository.clearDraft();
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
        final vehicle = await _repository.createVehicle(draft.toVehicle());
        draft = draft.copyWith(vehicleId: vehicle.id);
        await _persistDuringSubmit(draft, 'create_request');
      } else {
        await _repository.updateVehicle(
          draft.vehicleId!,
          draft.toVehicle(),
        );
      }

      if (draft.appraisalId == null) {
        final appraisal = await _repository.createAppraisal(draft.vehicleId!);
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
      await _repository.clearDraft();
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
    await _repository.clearDraft();
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
