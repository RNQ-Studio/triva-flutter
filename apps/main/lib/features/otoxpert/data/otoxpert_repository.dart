import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../../toyota_service/domain/toyota_service_models.dart';
import '../domain/otoxpert_models.dart';

class OtoxpertRepository {
  OtoxpertRepository({
    required Dio dio,
    required StorageService storage,
    String? userId,
  })  : _dio = dio,
        _storage = storage,
        _userId = userId;

  final Dio _dio;
  final StorageService _storage;
  final String? _userId;

  String get _draftKey => 'otoxpert_booking_draft_v1:${_userId ?? 'anonymous'}';

  Future<OtoxpertDraft> loadDraft() async {
    final raw = await _storage.read(_draftKey);
    if (raw == null || raw.isEmpty) return const OtoxpertDraft();
    try {
      return OtoxpertDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      await clearDraft();
      return const OtoxpertDraft();
    }
  }

  Future<void> saveDraft(OtoxpertDraft draft) =>
      _storage.write(_draftKey, jsonEncode(draft.toJson()));

  Future<void> clearDraft() => _storage.delete(_draftKey);

  Future<List<ToyotaServiceVehicle>> listVehicles() async {
    final items = await _listAllMaps(
      'v1/vehicles',
      queryParameters: const {'per_page': 100},
    );
    return items.map(ToyotaServiceVehicle.fromJson).toList(growable: false);
  }

  Future<OtoxpertOptions> getOptions() async {
    final response = await _dio.get<dynamic>('v1/otoxpert/options');
    return OtoxpertOptions.fromJson(_mapData(response));
  }

  Future<List<OtoxpertWorkshop>> listWorkshops(String vehicleId) async {
    final response = await _dio.get<dynamic>(
      'v1/otoxpert/workshops',
      queryParameters: {'vehicle_id': vehicleId},
    );
    return _listData(response)
        .whereType<Map<String, dynamic>>()
        .map(OtoxpertWorkshop.fromJson)
        .toList(growable: false);
  }

  Future<List<OtoxpertService>> listServices(String workshopId) async {
    final response = await _dio.get<dynamic>(
      'v1/otoxpert/workshops/$workshopId/services',
    );
    return _listData(response)
        .whereType<Map<String, dynamic>>()
        .map(OtoxpertService.fromJson)
        .toList(growable: false);
  }

  Future<ToyotaServiceAvailability> getAvailability({
    required String workshopId,
    required String serviceId,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/otoxpert/availability',
      queryParameters: {
        'workshop_id': workshopId,
        'service_id': serviceId,
        'days': 14,
      },
    );
    return ToyotaServiceAvailability.fromJson(_mapData(response));
  }

  Future<String> uploadPhoto(
    List<int> bytes, {
    required String filename,
    void Function(int sent, int total)? onProgress,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/assets/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'type': 'otoxpert-booking-photo',
        'is_protected': true,
      }),
      onSendProgress: onProgress,
    );
    return _mapData(response)['id'].toString();
  }

  Future<OtoxpertBooking> submit(
    OtoxpertDraft draft,
    String consentVersion,
  ) async {
    final response = await _dio.post<dynamic>(
      'v1/otoxpert/bookings',
      data: {
        'vehicle_id': draft.vehicle!.id,
        'workshop_id': draft.workshop!.id,
        'service_id': draft.service!.id,
        'current_mileage': draft.currentMileage,
        if (draft.lastServiceDate != null)
          'last_service_date': draft.lastServiceDate,
        'complaint': draft.complaint.trim(),
        'symptom_codes': draft.symptomCodes,
        'primary_slot': draft.primarySlot!.toJson(),
        'alternative_slot': draft.alternativeSlot!.toJson(),
        'pickup_delivery_requested': draft.pickupDeliveryRequested,
        'contact_channel': draft.contactChannel,
        'photo_asset_ids':
            draft.photos.map((item) => item.assetId).toList(growable: false),
        'partner_consent': true,
        'partner_consent_version': consentVersion,
        'campaign_source': 'triva_app',
      },
      options: Options(headers: {'Idempotency-Key': draft.idempotencyKey}),
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<List<OtoxpertBooking>> listBookings({String? status}) async =>
      _listAllBookings(
        'v1/otoxpert/bookings',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          'per_page': 30,
        },
      );

  Future<OtoxpertBooking> getBooking(String bookingId) async {
    final response = await _dio.get<dynamic>(
      'v1/otoxpert/bookings/$bookingId',
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<OtoxpertBooking> acceptAlternative(String bookingId) async {
    final response = await _dio.post<dynamic>(
      'v1/otoxpert/bookings/$bookingId/accept-alternative',
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<OtoxpertBooking> sendSchedule(
    String bookingId, {
    required String action,
    required ToyotaServiceSlot primary,
    required ToyotaServiceSlot alternative,
    required String reason,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/otoxpert/bookings/$bookingId/$action',
      data: {
        'primary_slot': primary.toJson(),
        'alternative_slot': alternative.toJson(),
        'reason': reason.trim(),
      },
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<OtoxpertBooking> cancel(String bookingId, String reason) async {
    final response = await _dio.post<dynamic>(
      'v1/otoxpert/bookings/$bookingId/cancel',
      data: {'reason': reason.trim()},
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<List<OtoxpertBooking>> listAdminBookings({
    String? status,
    String? search,
  }) async =>
      _listAllBookings(
        'v1/admin/otoxpert/bookings',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'per_page': 50,
        },
      );

  Future<OtoxpertBooking> getAdminBooking(String bookingId) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/otoxpert/bookings/$bookingId',
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<Map<String, dynamic>> getAdminOptions() async {
    final response = await _dio.get<dynamic>('v1/admin/otoxpert/options');
    return _mapData(response);
  }

  Future<OtoxpertBooking> performAdminAction(
    String bookingId,
    String action,
    Map<String, dynamic> fields,
  ) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/otoxpert/bookings/$bookingId/actions',
      data: {'action': action, ...fields},
    );
    return OtoxpertBooking.fromJson(_mapData(response));
  }

  Future<List<OtoxpertBooking>> _listAllBookings(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    final maps = await _listAllMaps(path, queryParameters: queryParameters);
    return maps.map(OtoxpertBooking.fromJson).toList(growable: false);
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
        throw const FormatException('Invalid OtoXpert pagination metadata.');
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
