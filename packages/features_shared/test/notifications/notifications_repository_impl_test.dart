import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = NotificationsRepositoryImpl(dio);
  });

  test('collects notifications from every nested pagination page', () async {
    final requestedPages = <int>[];
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final query =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
      final page = query['page'] as int;
      requestedPages.add(page);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/notifications'),
        data: {
          'data': [_notification(page)],
          'meta': {
            'pagination': {
              'current_page': page,
              'last_page': 2,
            },
          },
        },
      );
    });

    final items = await repository.getNotifications();

    expect(items.map((item) => item.id), ['notification-1', 'notification-2']);
    expect(requestedPages, [1, 2]);
  });

  test('malformed notification pagination cannot loop forever', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/notifications'),
        data: {
          'data': [_notification(1)],
          'meta': {
            'pagination': {
              'current_page': 1,
              'last_page': 2,
            },
          },
        },
      ),
    );

    await expectLater(
      repository.getNotifications(),
      throwsA(isA<FormatException>()),
    );
    verify(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(2);
  });
}

Map<String, dynamic> _notification(int page) => {
      'id': 'notification-$page',
      'title': 'Notification $page',
      'body': 'Body',
      'type': 'system',
      'created_at': '2026-07-27T10:00:00Z',
    };
