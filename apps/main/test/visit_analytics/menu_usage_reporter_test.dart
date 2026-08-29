import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/visit_analytics/data/menu_usage_reporter.dart';
import 'package:triva_app/features/visit_analytics/domain/menu_usage_models.dart';
import 'package:triva_app/features/visit_analytics/domain/visit_analytics_models.dart';

class _RecordingInterceptor extends Interceptor {
  final requests = <RequestOptions>[];
  Object? error;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    requests.add(options);
    if (error != null) {
      handler.reject(
        DioException(requestOptions: options, error: error),
      );
      return;
    }
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 202,
        data: const {'success': true},
      ),
    );
  }
}

void main() {
  late Dio dio;
  late _RecordingInterceptor interceptor;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    interceptor = _RecordingInterceptor();
    dio.interceptors.add(interceptor);
  });

  MenuUsageReporter reporter({VisitSource? source = VisitSource.android}) {
    return MenuUsageReporter(
      dio,
      source: source,
      appInfo: () async => (version: '1.2.0', build: '17'),
    );
  }

  test('reports the tapped menu with its channel and app version', () async {
    await reporter().track(MenuKey.appraisal);

    expect(interceptor.requests, hasLength(1));
    final request = interceptor.requests.single;
    expect(request.path, 'v1/analytics/menu-usage');
    expect(request.data, {
      'menu_key': 'appraisal',
      'source': 'android',
      'app_version': '1.2.0',
      'app_build': '17',
    });
  });

  test('every tap is reported so frequency stays comparable', () async {
    final tracker = reporter();
    await tracker.track(MenuKey.credit);
    await tracker.track(MenuKey.credit);

    expect(interceptor.requests, hasLength(2));
  });

  test('reports nothing when the channel is not tracked', () async {
    await reporter(source: null).track(MenuKey.appraisal);

    expect(interceptor.requests, isEmpty);
  });

  test('a failed report never surfaces to the caller', () async {
    interceptor.error = StateError('server down');

    await expectLater(reporter().track(MenuKey.bodyPaint), completes);
    expect(interceptor.requests, hasLength(1));
  });
}
