import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../domain/acc_credit_formula.dart';
import '../domain/credit_models.dart';

class CreditRepository {
  CreditRepository({
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
      'credit_simulation_draft_v1:${_userId ?? 'anonymous'}';

  Future<CreditSimulationDraft> loadDraft() async {
    final raw = await _storage.read(_draftKey);
    if (raw == null || raw.isEmpty) return const CreditSimulationDraft();
    try {
      return CreditSimulationDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      await clearDraft();
      return const CreditSimulationDraft();
    }
  }

  Future<void> saveDraft(CreditSimulationDraft draft) =>
      _storage.write(_draftKey, jsonEncode(draft.toJson()));

  Future<void> clearDraft() => _storage.delete(_draftKey);

  Future<List<CreditProgram>> listPrograms() async {
    final maps = await _listAllMaps(
      'v1/credit/programs',
      queryParameters: const {'per_page': 100},
    );
    return maps.map(CreditProgram.fromJson).toList(growable: false);
  }

  /// Rate card simulasi cepat ACC (revisi 4 September 2026).
  Future<AccRateCard> rateCard() async {
    final response = await _dio.get<dynamic>('v1/credit/quick/rate-card');
    return AccRateCard.fromJson(_mapData(response));
  }

  /// Menyimpan simulasi cepat di server; admin cabang ikut diberi notifikasi.
  Future<CreditSimulation> quickSimulate({
    required String programId,
    required int otrPrice,
    required int dpPercent,
    required int tenorYears,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/credit/quick',
      data: {
        'program_id': programId,
        'otr_price': otrPrice,
        'dp_percent': dpPercent,
        'tenor_years': tenorYears,
        'campaign_source': 'triva_quick_credit',
      },
    );
    return CreditSimulation.fromJson(_mapData(response));
  }

  Future<CreditCalculation> calculate(CreditSimulationDraft draft) async {
    final response = await _dio.post<dynamic>(
      'v1/credit/simulations/calculate',
      data: _payload(draft),
    );
    return CreditCalculation.fromJson(_mapData(response));
  }

  Future<CreditSimulation> save(CreditSimulationDraft draft) async {
    final idempotencyKey = draft.idempotencyKey;
    if (idempotencyKey == null || idempotencyKey.isEmpty) {
      throw StateError('An idempotency key is required to save a simulation.');
    }
    final response = await _dio.post<dynamic>(
      'v1/credit/simulations',
      data: {
        ..._payload(draft),
        if (draft.comparisonGroupId != null)
          'comparison_group_id': draft.comparisonGroupId,
        'campaign_source': draft.campaignSource,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return CreditSimulation.fromJson(_mapData(response));
  }

  Future<List<CreditSimulation>> listSimulations() async {
    final maps = await _listAllMaps(
      'v1/credit/simulations',
      queryParameters: const {'per_page': 30},
    );
    return maps.map(CreditSimulation.fromJson).toList(growable: false);
  }

  Future<CreditSimulation> getSimulation(String id) async {
    final response = await _dio.get<dynamic>('v1/credit/simulations/$id');
    return CreditSimulation.fromJson(_mapData(response));
  }

  Future<CreditSimulation> requestFollowUp(
    String id, {
    required String contactChannel,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/credit/simulations/$id/request-follow-up',
      data: {
        'follow_up_consent': true,
        'consent_version': 'credit-follow-up-v1',
        'contact_channel': contactChannel,
        'campaign_source': 'triva_credit_result',
      },
    );
    return CreditSimulation.fromJson(_mapData(response));
  }

  Map<String, dynamic> _payload(CreditSimulationDraft draft) => {
        'program_id': draft.programId,
        'otr_price': draft.otrPrice,
        'cash_down_payment': draft.cashDownPayment,
        'manual_trade_in_value': draft.manualTradeInValue,
        if (draft.tradeInAppraisalId != null)
          'trade_in_appraisal_id': draft.tradeInAppraisalId,
        'use_trade_in_as_dp': draft.useTradeInAsDp,
        'old_vehicle_payoff': draft.oldVehiclePayoff,
        'tenor_months': draft.tenorMonths,
        'accept_expired_appraisal': draft.acceptExpiredAppraisal,
      };

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
      for (final item in _listData(response)) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid credit API list item.');
        }
        items.add(item);
      }
      final envelope = _envelope(response);
      final meta = envelope['meta'] as Map<String, dynamic>?;
      final pagination = meta?['pagination'] as Map<String, dynamic>? ?? meta;
      final current = (pagination?['current_page'] as num?)?.toInt() ?? page;
      final last = (pagination?['last_page'] as num?)?.toInt() ?? current;
      if (current != page || current < 1 || last < current) {
        throw const FormatException('Invalid credit pagination metadata.');
      }
      if (current >= last) break;
      page = current + 1;
    }
    return List.unmodifiable(items);
  }

  List<dynamic> _listData(Response<dynamic> response) {
    final data = _envelope(response)['data'];
    if (data is List<dynamic>) return data;
    throw const FormatException('Invalid credit API list payload.');
  }

  Map<String, dynamic> _mapData(Response<dynamic> response) {
    final data = _envelope(response)['data'];
    if (data is Map<String, dynamic>) return data;
    throw const FormatException('Invalid credit API object payload.');
  }

  Map<String, dynamic> _envelope(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw const FormatException('Invalid credit API response envelope.');
    }
    return body;
  }
}
