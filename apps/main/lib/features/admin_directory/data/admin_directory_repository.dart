import 'package:dio/dio.dart';

import '../domain/admin_directory_models.dart';

/// Halaman hasil daftar admin beserta posisinya pada paginasi backend.
class AdminPage<T> {
  const AdminPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;

  bool get canLoadMore => currentPage < lastPage;
}

class AdminDirectoryRepository {
  const AdminDirectoryRepository(this._dio);

  final Dio _dio;

  Future<AdminPage<AdminUserRecord>> listUsers({
    String search = '',
    String? gender,
    bool? hasDemographics,
    int page = 1,
  }) {
    return _list(
      'v1/admin/users',
      AdminUserRecord.fromJson,
      page: page,
      queryParameters: {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (hasDemographics != null)
          'has_demographics': hasDemographics ? 1 : 0,
      },
    );
  }

  Future<AdminUserRecord> getUser(String userId) async {
    final response = await _dio.get<dynamic>('v1/admin/users/$userId');
    return AdminUserRecord.fromJson(_data(response));
  }

  Future<AdminPage<AdminAppraisalRecord>> listAppraisals({
    String search = '',
    String? status,
    int page = 1,
  }) {
    return _list(
      'v1/admin/appraisals',
      AdminAppraisalRecord.fromJson,
      page: page,
      queryParameters: {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
  }

  Future<AdminAppraisalRecord> getAppraisal(String appraisalId) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/appraisals/$appraisalId',
    );
    return AdminAppraisalRecord.fromJson(_data(response));
  }

  Future<List<AdminStatusOption>> appraisalStatuses() =>
      _statuses('v1/admin/appraisals/options');

  Future<AdminPage<AdminCreditSimulationRecord>> listCreditSimulations({
    String search = '',
    String? status,
    int page = 1,
  }) {
    return _list(
      'v1/admin/credit/simulations',
      AdminCreditSimulationRecord.fromJson,
      page: page,
      queryParameters: {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
  }

  Future<AdminCreditSimulationRecord> getCreditSimulation(String id) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/credit/simulations/$id',
    );
    return AdminCreditSimulationRecord.fromJson(_data(response));
  }

  Future<List<AdminStatusOption>> creditSimulationStatuses() =>
      _statuses('v1/admin/credit/simulations/options');

  Future<List<AdminStatusOption>> _statuses(String path) async {
    final response = await _dio.get<dynamic>(path);
    final statuses = _data(response)['statuses'];
    return (statuses as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AdminStatusOption.fromJson)
        .toList(growable: false);
  }

  Future<AdminPage<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    required int page,
    required Map<String, dynamic> queryParameters,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: {...queryParameters, 'page': page, 'per_page': 20},
    );
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Admin list envelope is invalid');
    }
    final data = envelope['data'] as List<dynamic>? ?? const [];
    final meta = envelope['meta'] as Map<String, dynamic>?;
    final pagination = meta?['pagination'] as Map<String, dynamic>? ?? const {};

    return AdminPage<T>(
      items: data
          .whereType<Map<String, dynamic>>()
          .map(parse)
          .toList(growable: false),
      currentPage: (pagination['current_page'] as num?)?.toInt() ?? page,
      lastPage: (pagination['last_page'] as num?)?.toInt() ?? page,
    );
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Admin envelope is invalid');
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Admin data is invalid');
    }
    return data;
  }
}
