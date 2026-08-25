import 'package:dio/dio.dart';

import '../domain/maintenance_estimate_models.dart';

class MaintenanceEstimateRepository {
  MaintenanceEstimateRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<MaintenanceEstimate> estimate({
    String? vehicleModel,
    int? mileage,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/toyota-service/maintenance-estimate',
      queryParameters: {
        if (vehicleModel != null && vehicleModel.trim().isNotEmpty)
          'vehicle_model': vehicleModel.trim(),
        if (mileage != null) 'mileage': mileage,
      },
    );
    final payload = response.data;
    if (payload is! Map || payload['data'] is! Map) {
      throw const FormatException('Respons simulasi tidak dikenali.');
    }

    return MaintenanceEstimate.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }
}
