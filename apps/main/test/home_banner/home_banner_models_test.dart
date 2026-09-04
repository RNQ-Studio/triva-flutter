import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/home_banner/data/home_banner_repository.dart';
import 'package:triva_app/features/home_banner/domain/home_banner_models.dart';

void main() {
  test('parses banner payload and skips entries without an image', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'data': [
                {
                  'id': 'b1',
                  'title': 'Promo',
                  'image_url': 'https://cdn.test/b1.jpg',
                  'link_url': 'https://auto2000.co.id',
                  'sort_order': 1,
                },
                {'id': 'b2', 'title': 'Tanpa gambar', 'image_url': ''},
              ],
            },
          ),
        ),
      ),
    );

    final banners = await HomeBannerRepository(dio: dio).listRunning();

    expect(banners, hasLength(1));
    expect(banners.single.id, 'b1');
    expect(banners.single.hasLink, isTrue);
    expect(banners.single.sortOrder, 1);
  });

  test('banner without link is not tappable', () {
    const banner = HomeBanner(id: 'b', title: 't', imageUrl: 'x', linkUrl: ' ');
    expect(banner.hasLink, isFalse);
  });
}
