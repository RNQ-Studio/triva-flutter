import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/visit_analytics/data/admin_visit_statistics_repository.dart';
import 'package:triva_app/features/visit_analytics/data/visit_launch_reporter.dart';
import 'package:triva_app/features/visit_analytics/domain/visit_analytics_models.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
  });

  test('statistics repository parses every WIB period and source', () async {
    when(() => dio.get<dynamic>('v1/admin/analytics/visits')).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/admin/analytics/visits'),
        data: {'data': _statisticsData()},
      ),
    );

    final result = await AdminVisitStatisticsRepository(dio).fetch();

    expect(result.timezone, 'Asia/Jakarta');
    expect(result.trackingStartedAt, DateTime.parse('2026-08-19T01:00:00Z'));
    expect(result.forPeriod(VisitPeriod.daily).total, 10);
    expect(
      result.forPeriod(VisitPeriod.monthly).countFor(VisitSource.landingPage),
      18,
    );
    expect(result.forPeriod(VisitPeriod.overall).total, 100);
  });

  test('statistics repository rejects an incomplete period contract', () {
    final payload = _statisticsData();
    (payload['periods'] as Map<String, dynamic>).remove('monthly');
    when(() => dio.get<dynamic>('v1/admin/analytics/visits')).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/admin/analytics/visits'),
        data: {'data': payload},
      ),
    );

    expect(
      () => AdminVisitStatisticsRepository(dio).fetch(),
      throwsA(isA<FormatException>()),
    );
  });

  test('launch reporter retries with one id and stops after success', () async {
    var attempts = 0;
    final payloads = <Map<String, dynamic>>[];
    when(
      () => dio.post<dynamic>(
        'v1/analytics/visits',
        data: any<Map<String, dynamic>>(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      payloads.add(
        Map<String, dynamic>.from(
          invocation.namedArguments[#data] as Map<String, dynamic>,
        ),
      );
      attempts++;
      if (attempts == 1) {
        throw DioException(
          requestOptions: RequestOptions(path: 'v1/analytics/visits'),
          type: DioExceptionType.connectionError,
        );
      }
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/analytics/visits'),
        statusCode: 202,
      );
    });
    final reporter = VisitLaunchReporter(
      dio,
      visitIdFactory: () => '11111111-2222-4333-8444-555555555555',
    );

    await expectLater(
      reporter.report(
        source: VisitSource.android,
        appVersion: '1.0.11',
        appBuild: '12',
      ),
      throwsA(isA<DioException>()),
    );
    await reporter.report(
      source: VisitSource.android,
      appVersion: '1.0.11',
      appBuild: '12',
    );
    await reporter.report(
      source: VisitSource.android,
      appVersion: '1.0.11',
      appBuild: '12',
    );

    expect(payloads, hasLength(2));
    expect(payloads[0]['visit_id'], payloads[1]['visit_id']);
    expect(payloads[1], {
      'visit_id': '11111111-2222-4333-8444-555555555555',
      'source': 'android',
      'app_version': '1.0.11',
      'app_build': '12',
    });
  });

  test('generated visit IDs are RFC 4122 version 4 UUIDs', () {
    final first = createVisitId();
    final second = createVisitId();

    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(second, isNot(first));
  });
}

Map<String, dynamic> _statisticsData() => {
      'timezone': 'Asia/Jakarta',
      'tracking_started_at': '2026-08-19T01:00:00Z',
      'generated_at': '2026-08-19T03:00:00Z',
      'periods': {
        'daily': _period(total: 10, android: 4, web: 3, landing: 3),
        'weekly': _period(total: 30, android: 12, web: 8, landing: 10),
        'monthly': _period(total: 60, android: 24, web: 18, landing: 18),
        'overall': _period(total: 100, android: 40, web: 30, landing: 30),
      },
    };

Map<String, dynamic> _period({
  required int total,
  required int android,
  required int web,
  required int landing,
}) =>
    {
      'starts_at': '2026-08-19T00:00:00+07:00',
      'ends_at': '2026-08-19T23:59:59+07:00',
      'total': total,
      'by_source': {
        'android': android,
        'web': web,
        'landing_page': landing,
      },
    };
