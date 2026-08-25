import 'package:dio/dio.dart';

import '../domain/vehicle_benefit_models.dart';

class VehicleBenefitRepository {
  VehicleBenefitRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<VehicleBenefitCheckResult> check({
    required String vin,
    int? year,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/vehicle-benefits/check',
      data: {
        'vin': vin,
        if (year != null) 'year': year,
      },
    );
    final payload = response.data;
    if (payload is! Map || payload['data'] is! Map) {
      throw const FormatException('Respons pemeriksaan tidak dikenali.');
    }

    return VehicleBenefitCheckResult.fromJson(
      Map<String, dynamic>.from(payload['data'] as Map),
    );
  }
}
