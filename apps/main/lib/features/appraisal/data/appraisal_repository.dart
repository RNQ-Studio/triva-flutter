import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/appraisal_models.dart';

class AppraisalRepository {
  AppraisalRepository({
    required Dio dio,
    required StorageService storage,
    String? userId,
  })  : _dio = dio,
        _storage = storage,
        _userId = userId;

  static const _legacyDraftKey = 'appraisal_draft_v1';

  final Dio _dio;
  final StorageService _storage;
  final String? _userId;

  String get _draftKey => 'appraisal_draft_v1:${_userId ?? 'anonymous'}';

  Future<AppraisalDraft> loadDraft() async {
    // The legacy key had no account owner. Never migrate it into the active
    // account because doing so could expose another customer's draft.
    await _storage.delete(_legacyDraftKey);
    final raw = await _storage.read(_draftKey);
    if (raw == null || raw.isEmpty) return const AppraisalDraft();
    try {
      return AppraisalDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await clearDraft();
      return const AppraisalDraft();
    }
  }

  Future<void> saveDraft(AppraisalDraft draft) =>
      _storage.write(_draftKey, jsonEncode(draft.toJson()));

  Future<void> clearDraft() => _storage.delete(_draftKey);

  Future<List<VehicleMakeOption>> listVehicleMakes() async {
    final response = await _dio.get<dynamic>('v1/vehicle-makes');
    final envelope = response.data as Map<String, dynamic>;
    final items = envelope['data'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VehicleMakeOption.fromJson)
        .toList(growable: false);
  }

  Future<List<VehicleModelOption>> listVehicleModels(int makeId) async {
    final response = await _dio.get<dynamic>(
      'v1/vehicle-makes/$makeId/models',
    );
    final envelope = response.data as Map<String, dynamic>;
    final items = envelope['data'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VehicleModelOption.fromJson)
        .toList(growable: false);
  }

  Future<List<VehicleVariantOption>> listVehicleVariants({
    required int modelId,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/vehicle-models/$modelId/variants',
    );
    final envelope = response.data as Map<String, dynamic>;
    final items = envelope['data'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VehicleVariantOption.fromJson)
        .toList(growable: false);
  }

  Future<VehicleData> createVehicle(
    VehicleData vehicle, {
    String? idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/vehicles',
      data: vehicle.toJson(),
      options: idempotencyKey == null
          ? null
          : Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return VehicleData.fromJson(_data(response));
  }

  Future<VehicleData> updateVehicle(
    String vehicleId,
    VehicleData vehicle,
  ) async {
    final response = await _dio.put<dynamic>(
      'v1/vehicles/$vehicleId',
      data: vehicle.toJson(),
    );
    return VehicleData.fromJson(_data(response));
  }

  Future<AppraisalData> createAppraisal(
    String vehicleId, {
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals',
      data: {'vehicle_id': vehicleId},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return AppraisalData.fromJson(_data(response));
  }

  Future<AppraisalData> updateCondition(
    String appraisalId,
    Map<String, dynamic> condition,
  ) async {
    final response = await _dio.put<dynamic>(
      'v1/appraisals/$appraisalId/vehicle-condition',
      data: condition,
    );
    return AppraisalData.fromJson(_data(response));
  }

  /// Mengunggah dari byte, bukan dari jalur berkas, karena di browser foto
  /// pilihan pelanggan tidak pernah berupa berkas yang bisa dibuka.
  Future<String> uploadPhoto(
    Uint8List bytes, {
    required String filename,
    void Function(double progress)? onProgress,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/assets/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'type': 'appraisal-photo',
        'is_protected': true,
      }),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return _data(response)['id'].toString();
  }

  Future<AppraisalData> attachPhotos(
    String appraisalId,
    Map<String, String> assetIds,
  ) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals/$appraisalId/photos',
      data: {
        'photos': assetIds.entries
            .map((entry) => {
                  'angle': entry.key,
                  'asset_id': entry.value,
                })
            .toList(growable: false),
      },
    );
    return AppraisalData.fromJson(_data(response));
  }

  Future<AppraisalData> submit(
    String appraisalId, {
    required String idempotencyKey,
    required bool marketingConsent,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals/$appraisalId/submit',
      data: {
        'service_consent': true,
        'marketing_consent': marketingConsent,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return AppraisalData.fromJson(_data(response));
  }

  Future<List<AppraisalData>> listAppraisals() async {
    final response = await _dio.get<dynamic>('v1/appraisals');
    final envelope = response.data as Map<String, dynamic>;
    final items = envelope['data'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AppraisalData.fromJson)
        .toList(growable: false);
  }

  Future<AppraisalData> getAppraisal(String appraisalId) async {
    final response = await _dio.get<dynamic>('v1/appraisals/$appraisalId');
    return AppraisalData.fromJson(_data(response));
  }

  /// Menerima `XFile` langsung, bukan jalur berkas, supaya penggantian foto
  /// yang ditolak juga bekerja di browser.
  Future<AppraisalData> replaceRejectedPhoto({
    required String appraisalId,
    required String angle,
    required XFile photo,
    void Function(double progress)? onProgress,
  }) async {
    final extension = photo.name.contains('.')
        ? photo.name.substring(photo.name.lastIndexOf('.')).toLowerCase()
        : '.jpg';
    final assetId = await uploadPhoto(
      await photo.readAsBytes(),
      filename: '$angle$extension',
      onProgress: onProgress,
    );
    return attachPhotos(appraisalId, {angle: assetId});
  }

  Future<AppraisalData> resubmit(String appraisalId) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals/$appraisalId/resubmit',
    );
    return AppraisalData.fromJson(_data(response));
  }

  Future<AppraisalData> decide(
    String appraisalId,
    String decision, {
    int? expectedPrice,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals/$appraisalId/decision',
      data: {
        'decision': decision,
        if (expectedPrice != null) 'expected_price': expectedPrice,
      },
    );
    return AppraisalData.fromJson(_data(response));
  }

  Future<AppraisalUpgradeOffer> upgradeOptions(String appraisalId) async {
    final response = await _dio.get<dynamic>(
      'v1/appraisals/$appraisalId/upgrade-options',
    );
    return AppraisalUpgradeOffer.fromJson(_data(response));
  }

  Future<AppraisalData> scheduleInspection(
    String appraisalId,
    DateTime scheduledAt, {
    String? notes,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/appraisals/$appraisalId/schedule-inspection',
      data: {
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return AppraisalData.fromJson(_data(response));
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }
}
