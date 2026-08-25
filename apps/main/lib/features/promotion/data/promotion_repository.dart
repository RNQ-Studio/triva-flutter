import 'package:dio/dio.dart';

import '../domain/promotion_models.dart';

class PromotionRepository {
  PromotionRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<Promotion>> listRunning() async {
    final response = await _dio.get<dynamic>('v1/promotions');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) return const [];

    return (payload['data'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Promotion.fromJson)
        .toList(growable: false);
  }
}
