import 'package:dio/dio.dart';

import '../../admin_content/data/admin_content_payload.dart';
import '../domain/maintenance_estimate_models.dart';

/// Tabel budget jasa dan part per model dan kelipatan km yang menjadi dasar
/// simulasi biaya servis (revisi 6 Oktober 2026).
class ServicePackageAdminRepository {
  ServicePackageAdminRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _path = 'v1/admin/toyota-service/packages';

  Future<List<MaintenancePackage>> listAll() async {
    final response = await _dio.get<dynamic>(_path);
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) return const [];
    return (payload['data'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(MaintenancePackage.fromJson)
        .toList(growable: false);
  }

  Future<MaintenancePackage> create(ServicePackageInput input) async {
    final response = await _dio.post<dynamic>(_path, data: input.toJson());
    return MaintenancePackage.fromJson(dataMap(response.data));
  }

  Future<MaintenancePackage> update(
    String id,
    ServicePackageInput input,
  ) async {
    final response = await _dio.patch<dynamic>(
      '$_path/$id',
      data: input.toJson(),
    );
    return MaintenancePackage.fromJson(dataMap(response.data));
  }

  Future<void> delete(String id) async {
    await _dio.delete<dynamic>('$_path/$id');
  }
}
