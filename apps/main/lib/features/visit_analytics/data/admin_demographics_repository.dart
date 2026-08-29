import 'package:dio/dio.dart';

import '../domain/demographics_models.dart';

class AdminDemographicsRepository {
  const AdminDemographicsRepository(this._dio);

  final Dio _dio;

  Future<DemographicsSnapshot> fetch() async {
    final response = await _dio.get<dynamic>(
      'v1/admin/analytics/demographics',
    );
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Demographics envelope is invalid');
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Demographics data is invalid');
    }

    return DemographicsSnapshot.fromJson(data);
  }
}
