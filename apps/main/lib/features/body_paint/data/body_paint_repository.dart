import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../../toyota_service/domain/toyota_service_models.dart';
import '../domain/body_paint_models.dart';

class BodyPaintRepository {
  BodyPaintRepository({
    required Dio dio,
    required StorageService storage,
    String? userId,
  })  : _dio = dio,
        _storage = storage,
        _userId = userId;

  final Dio _dio;
  final StorageService _storage;
  final String? _userId;

  String get _draftKey =>
      'body_paint_estimate_draft_v1:${_userId ?? 'anonymous'}';

  Future<BodyPaintDraft> loadDraft() async {
    final raw = await _storage.read(_draftKey);
    if (raw == null || raw.isEmpty) return const BodyPaintDraft();
    try {
      return BodyPaintDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      await clearDraft();
      return const BodyPaintDraft();
    }
  }

  Future<void> saveDraft(BodyPaintDraft draft) =>
      _storage.write(_draftKey, jsonEncode(draft.toJson()));

  Future<void> clearDraft() => _storage.delete(_draftKey);

  Future<List<ToyotaServiceVehicle>> listVehicles() async {
    final maps = await _listAllMaps(
      'v1/vehicles',
      queryParameters: const {'per_page': 100},
    );
    return maps.map(ToyotaServiceVehicle.fromJson).toList(growable: false);
  }

  Future<BodyPaintOptions> getOptions() async {
    final response = await _dio.get<dynamic>('v1/body-paint/options');
    return BodyPaintOptions.fromJson(_mapData(response));
  }

  Future<String> uploadPhoto(
    List<int> bytes, {
    required String filename,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/assets/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'type': 'body-paint-estimate-photo',
        'is_protected': true,
      }),
    );
    return _mapData(response)['id'].toString();
  }

  Future<BodyPaintEstimate> createDraft(BodyPaintDraft draft) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates',
      data: {
        'vehicle_id': draft.vehicle!.id,
        'service_location_id': draft.location!.id,
        if (draft.notes.trim().isNotEmpty) 'customer_notes': draft.notes.trim(),
        'campaign_source': 'triva_app',
      },
      options: Options(headers: {'Idempotency-Key': draft.idempotencyKey}),
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> updateDamages(
    String estimateId,
    List<BodyPaintDraftDamage> damages,
  ) async {
    final response = await _dio.put<dynamic>(
      'v1/body-paint/estimates/$estimateId/damages',
      data: {
        'damages': [
          for (final damage in damages)
            {
              'panel_code': damage.panelCode,
              'damage_type': damage.damageType,
              'severity': damage.severity,
              if (damage.note.trim().isNotEmpty) 'note': damage.note.trim(),
            },
        ],
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> attachPhotos(
    String estimateId,
    BodyPaintDraft draft,
  ) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/$estimateId/photos',
      data: {
        'photos': [
          for (final damage in draft.damages)
            {
              'asset_id': damage.closePhotoAssetId,
              'damage_id': damage.remoteId,
              'photo_type': 'close',
            },
          {
            'asset_id': draft.contextPhotoAssetId,
            'damage_id': null,
            'photo_type': 'context',
          },
        ],
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> attachPhoto(
    String estimateId, {
    required String assetId,
    required String photoType,
    String? damageId,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/$estimateId/photos',
      data: {
        'photos': [
          {
            'asset_id': assetId,
            'damage_id': damageId,
            'photo_type': photoType,
          },
        ],
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> submit(String estimateId) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/$estimateId/submit',
      data: const {
        'service_consent': true,
        'estimate_disclaimer_accepted': true,
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> resubmit(String estimateId) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/$estimateId/resubmit',
      data: const {
        'service_consent': true,
        'estimate_disclaimer_accepted': true,
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<List<BodyPaintEstimate>> listEstimates({String? status}) async {
    final maps = await _listAllMaps(
      'v1/body-paint/estimates',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'per_page': 30,
      },
    );
    return maps.map(BodyPaintEstimate.fromJson).toList(growable: false);
  }

  Future<BodyPaintEstimate> getEstimate(String estimateId) async {
    final response = await _dio.get<dynamic>(
      'v1/body-paint/estimates/$estimateId',
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<BodyPaintEstimate> decide(
    String estimateId,
    String decision, {
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/$estimateId/decision',
      data: {
        'decision': decision,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<ToyotaServiceAvailability> getAvailability({
    required String locationId,
    required String serviceTypeId,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/toyota-service/availability',
      queryParameters: {
        'service_location_id': locationId,
        'service_type_id': serviceTypeId,
        'fulfillment_type': 'workshop',
        'days': 14,
      },
    );
    return ToyotaServiceAvailability.fromJson(_mapData(response));
  }

  Future<Map<String, dynamic>> requestBooking(
    BodyPaintEstimate estimate, {
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    required String complaint,
    required int mileage,
    required String contactChannel,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/body-paint/estimates/${estimate.id}/request-booking',
      data: {
        'service_location_id': estimate.location!.id,
        'current_mileage': mileage,
        'complaint': complaint.trim(),
        'primary_slot': primary.toJson(),
        'alternative_slot': alternative.toJson(),
        'contact_channel': contactChannel,
        'service_consent': true,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return _mapData(response);
  }

  Future<List<BodyPaintEstimate>> listAdminEstimates({
    String? status,
    String? search,
  }) async {
    final maps = await _listAllMaps(
      'v1/admin/body-paint/estimates',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'per_page': 50,
      },
    );
    return maps.map(BodyPaintEstimate.fromJson).toList(growable: false);
  }

  Future<BodyPaintEstimate> getAdminEstimate(String estimateId) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/body-paint/estimates/$estimateId',
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<Map<String, dynamic>> getAdminOptions() async {
    final response = await _dio.get<dynamic>('v1/admin/body-paint/options');
    return _mapData(response);
  }

  Future<BodyPaintEstimate> performAdminAction(
    String estimateId,
    String action,
    Map<String, dynamic> fields,
  ) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/body-paint/estimates/$estimateId/actions',
      data: {'action': action, ...fields},
    );
    return BodyPaintEstimate.fromJson(_mapData(response));
  }

  Future<List<Map<String, dynamic>>> _listAllMaps(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    final items = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {...queryParameters, 'page': page},
      );
      items.addAll(_listData(response).whereType<Map<String, dynamic>>());
      final envelope = response.data as Map<String, dynamic>;
      final meta = envelope['meta'] as Map<String, dynamic>?;
      final pagination = meta?['pagination'] as Map<String, dynamic>? ?? meta;
      final current = (pagination?['current_page'] as num?)?.toInt() ?? page;
      final last = (pagination?['last_page'] as num?)?.toInt() ?? current;
      if (current >= last) break;
      if (current != page || current < 1 || last < current) {
        throw const FormatException(
          'Invalid Body & Paint pagination metadata.',
        );
      }
      page = current + 1;
    }
    return List.unmodifiable(items);
  }

  List<dynamic> _listData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as List<dynamic>? ?? const [];
  }

  Map<String, dynamic> _mapData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }
}
