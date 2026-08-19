import 'package:dio/dio.dart';

import '../domain/visit_analytics_models.dart';

class AdminVisitStatisticsRepository {
  const AdminVisitStatisticsRepository(this._dio);

  final Dio _dio;

  Future<VisitAnalyticsSnapshot> fetch() async {
    final response = await _dio.get<dynamic>('v1/admin/analytics/visits');
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Visit statistics envelope is invalid');
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Visit statistics data is invalid');
    }

    return VisitAnalyticsSnapshot.fromJson(data);
  }
}
