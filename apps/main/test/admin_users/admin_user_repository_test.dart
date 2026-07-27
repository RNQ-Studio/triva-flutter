import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/admin_users/data/admin_user_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late AdminUserRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = AdminUserRepository(dio);
  });

  test('list parses user access and pagination envelope', () async {
    when(
      () => dio.get<dynamic>(
        'v1/admin/users',
        queryParameters: {
          'search': 'existing',
          'page': 2,
          'per_page': 20,
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/admin/users'),
        data: {
          'data': [
            {
              'id': 42,
              'name': 'Existing User',
              'email': 'existing@example.com',
              'is_active': true,
              'is_admin': false,
              'roles': ['customer'],
            },
          ],
          'meta': {
            'pagination': {
              'current_page': 2,
              'last_page': 3,
            },
          },
        },
      ),
    );

    final result = await repository.listUsers(
      search: 'existing',
      page: 2,
    );

    expect(result.users.single.id, '42');
    expect(result.users.single.isAdmin, isFalse);
    expect(result.currentPage, 2);
    expect(result.lastPage, 3);
  });

  test('grant admin posts to the server-controlled role action', () async {
    when(
      () => dio.post<dynamic>('v1/admin/users/42/grant-admin'),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(
          path: 'v1/admin/users/42/grant-admin',
        ),
        data: {
          'data': {
            'id': 42,
            'name': 'Existing User',
            'email': 'existing@example.com',
            'is_active': true,
            'is_admin': true,
            'roles': ['admin'],
          },
        },
      ),
    );

    final result = await repository.grantAdmin('42');

    expect(result.isAdmin, isTrue);
    expect(result.roles, ['admin']);
    verify(
      () => dio.post<dynamic>('v1/admin/users/42/grant-admin'),
    ).called(1);
  });
}
