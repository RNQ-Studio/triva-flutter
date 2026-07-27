import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../domain/toyota_service_models.dart';

class ToyotaServiceRepository {
  ToyotaServiceRepository({
    required Dio dio,
    required StorageService storage,
    String? userId,
  })  : _dio = dio,
        _storage = storage,
        _userId = userId;

  static const _draftKeyPrefix = 'toyota_service_draft_v1';

  final Dio _dio;
  final StorageService _storage;
  final String? _userId;
  String get _draftKey => '$_draftKeyPrefix:${_userId ?? 'anonymous'}';

  Future<ToyotaServiceDraft> loadDraft() async {
    final raw = await _storage.read(_draftKey);
    if (raw == null || raw.isEmpty) return const ToyotaServiceDraft();
    try {
      return ToyotaServiceDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      await clearDraft();
      return const ToyotaServiceDraft();
    }
  }

  Future<void> saveDraft(ToyotaServiceDraft draft) =>
      _storage.write(_draftKey, jsonEncode(draft.toJson()));

  Future<void> clearDraft() => _storage.delete(_draftKey);

  Future<List<ToyotaServiceVehicle>> listVehicles() async {
    final items = await _listAllMaps(
      'v1/vehicles',
      queryParameters: const {'per_page': 100},
    );
    return items.map(ToyotaServiceVehicle.fromJson).toList(growable: false);
  }

  Future<ToyotaServiceOptions> getOptions() async {
    final response = await _dio.get<dynamic>('v1/toyota-service/options');
    return ToyotaServiceOptions.fromJson(_mapData(response));
  }

  Future<ToyotaServiceAvailability> getAvailability({
    required String serviceTypeId,
    required ToyotaServiceFulfillment fulfillment,
    required DateTime fromDate,
    String? serviceLocationId,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/toyota-service/availability',
      queryParameters: {
        if (serviceLocationId != null) 'service_location_id': serviceLocationId,
        'service_type_id': serviceTypeId,
        'fulfillment_type': fulfillment.value,
        'from_date': _date(fromDate),
        'days': 14,
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return ToyotaServiceAvailability.fromJson(_mapData(response));
  }

  Future<String> uploadSupportingPhoto(
    List<int> bytes, {
    required String filename,
    void Function(int sent, int total)? onProgress,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/assets/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'type': 'toyota-service-photo',
        'is_protected': true,
      }),
      onSendProgress: onProgress,
    );
    return _mapData(response)['id'].toString();
  }

  Future<ToyotaServiceBooking> submit(ToyotaServiceDraft draft) async {
    final photoAssetIds =
        draft.photos.map((item) => item.assetId).toList(growable: false);

    final response = await _dio.post<dynamic>(
      'v1/toyota-service/bookings',
      data: {
        'vehicle_id': draft.vehicle!.id,
        if (draft.serviceLocation != null)
          'service_location_id': draft.serviceLocation!.id,
        'service_type_id': draft.serviceType!.id,
        'fulfillment_type': draft.fulfillmentType!.value,
        'current_mileage': draft.currentMileage,
        'complaint': draft.complaint.trim(),
        'primary_slot': draft.primarySlot!.toJson(),
        'alternative_slot': draft.alternativeSlot!.toJson(),
        'contact_channel': draft.contactChannel,
        if (photoAssetIds.isNotEmpty) 'photo_asset_ids': photoAssetIds,
        if (draft.fulfillmentType == ToyotaServiceFulfillment.ths) ...{
          'ths_address': draft.thsAddress.trim(),
          'ths_city': draft.thsCity.trim(),
          'ths_latitude': draft.thsLatitude,
          'ths_longitude': draft.thsLongitude,
          if (draft.thsLocationNotes.trim().isNotEmpty)
            'ths_location_notes': draft.thsLocationNotes.trim(),
        },
        'service_consent': true,
      },
      options: Options(
        headers: {'Idempotency-Key': draft.idempotencyKey},
      ),
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<List<ToyotaServiceBooking>> listBookings({
    String? status,
    int perPage = 30,
  }) async {
    return _listAllBookings(
      'v1/toyota-service/bookings',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'per_page': perPage,
      },
    );
  }

  Future<ToyotaServiceBooking> getBooking(String bookingId) async {
    final response = await _dio.get<dynamic>(
      'v1/toyota-service/bookings/$bookingId',
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> acceptAlternative(String bookingId) async {
    final response = await _dio.post<dynamic>(
      'v1/toyota-service/bookings/$bookingId/accept-alternative',
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> rejectAlternative(
    String bookingId, {
    required ToyotaServiceSlot primarySlot,
    required ToyotaServiceSlot alternativeSlot,
    String? reason,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/toyota-service/bookings/$bookingId/reject-alternative',
      data: {
        'primary_slot': primarySlot.toJson(),
        'alternative_slot': alternativeSlot.toJson(),
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> requestReschedule(
    String bookingId, {
    required ToyotaServiceSlot primarySlot,
    required ToyotaServiceSlot alternativeSlot,
    required String reason,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/toyota-service/bookings/$bookingId/reschedule',
      data: {
        'primary_slot': primarySlot.toJson(),
        'alternative_slot': alternativeSlot.toJson(),
        'reason': reason.trim(),
      },
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> cancelBooking(
    String bookingId, {
    required String reason,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/toyota-service/bookings/$bookingId/cancel',
      data: {'reason': reason.trim()},
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<List<ToyotaServiceBooking>> listAdminBookings({
    String? status,
    String? search,
    String? serviceTypeId,
    String? serviceLocationId,
    String? fulfillmentType,
    String? date,
    String? advisorId,
    bool? slaOverdue,
    String sort = 'updated_desc',
    int perPage = 50,
  }) async {
    return _listAllBookings(
      'v1/admin/toyota-service/bookings',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (serviceTypeId != null && serviceTypeId.isNotEmpty)
          'service_type_id': serviceTypeId,
        if (serviceLocationId != null && serviceLocationId.isNotEmpty)
          'service_location_id': serviceLocationId,
        if (fulfillmentType != null && fulfillmentType.isNotEmpty)
          'fulfillment_type': fulfillmentType,
        if (date != null && date.isNotEmpty) 'date': date,
        if (advisorId != null && advisorId.isNotEmpty) 'advisor_id': advisorId,
        if (slaOverdue != null)
          'sla_status': slaOverdue ? 'overdue' : 'within_sla',
        'sort': sort,
        'per_page': perPage,
      },
    );
  }

  Future<ToyotaServiceAdminOptions> getAdminOptions() async {
    final response = await _dio.get<dynamic>('v1/admin/toyota-service/options');
    return ToyotaServiceAdminOptions.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> getAdminBooking(String bookingId) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/toyota-service/bookings/$bookingId',
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  Future<ToyotaServiceBooking> performAdminAction(
    String bookingId, {
    required String action,
    Map<String, dynamic> fields = const {},
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/toyota-service/bookings/$bookingId/actions',
      data: {'action': action, ...fields},
    );
    return ToyotaServiceBooking.fromJson(_mapData(response));
  }

  List<dynamic> _listData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as List<dynamic>? ?? const [];
  }

  Future<List<ToyotaServiceBooking>> _listAllBookings(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    final items = await _listAllMaps(
      path,
      queryParameters: queryParameters,
    );
    return List.unmodifiable(items.map(ToyotaServiceBooking.fromJson));
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
      final currentPage =
          (pagination?['current_page'] as num?)?.toInt() ?? page;
      final lastPage =
          (pagination?['last_page'] as num?)?.toInt() ?? currentPage;
      if (currentPage != page || currentPage < 1 || lastPage < currentPage) {
        throw const FormatException(
          'Invalid pagination metadata returned by booking API.',
        );
      }
      if (currentPage >= lastPage) break;
      page = currentPage + 1;
    }
    return List.unmodifiable(items);
  }

  Map<String, dynamic> _mapData(Response<dynamic> response) {
    final envelope = response.data as Map<String, dynamic>;
    return envelope['data'] as Map<String, dynamic>;
  }

  String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
