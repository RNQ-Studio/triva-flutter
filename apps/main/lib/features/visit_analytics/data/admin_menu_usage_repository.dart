import 'package:dio/dio.dart';

import '../domain/menu_usage_models.dart';

class AdminMenuUsageRepository {
  const AdminMenuUsageRepository(this._dio);

  final Dio _dio;

  Future<MenuUsageSnapshot> fetch() async {
    final response = await _dio.get<dynamic>('v1/admin/analytics/menu-usage');
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Menu usage envelope is invalid');
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Menu usage data is invalid');
    }

    return MenuUsageSnapshot.fromJson(data);
  }
}
