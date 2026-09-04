import 'package:dio/dio.dart';

import '../domain/home_banner_models.dart';

class HomeBannerRepository {
  HomeBannerRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<HomeBanner>> listRunning() async {
    final response = await _dio.get<dynamic>('v1/banners');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) return const [];

    return (payload['data'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(HomeBanner.fromJson)
        .where((banner) => banner.imageUrl.isNotEmpty)
        .toList(growable: false);
  }
}
