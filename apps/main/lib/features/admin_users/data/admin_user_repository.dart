import 'package:dio/dio.dart';

import '../domain/admin_user_models.dart';

class AdminUserRepository {
  const AdminUserRepository(this._dio);

  final Dio _dio;

  Future<AdminUserPage> listUsers({
    String search = '',
    int page = 1,
  }) async {
    final response = await _dio.get<dynamic>(
      'v1/admin/users',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        'page': page,
        'per_page': 20,
      },
    );
    final envelope = response.data as Map<String, dynamic>;
    final data = envelope['data'] as List<dynamic>? ?? const [];
    final meta = envelope['meta'] as Map<String, dynamic>?;
    final pagination = meta?['pagination'] as Map<String, dynamic>? ?? const {};

    return AdminUserPage(
      users: data
          .whereType<Map<String, dynamic>>()
          .map(AdminUser.fromJson)
          .toList(growable: false),
      currentPage: (pagination['current_page'] as num?)?.toInt() ?? page,
      lastPage: (pagination['last_page'] as num?)?.toInt() ?? page,
    );
  }

  Future<AdminUser> grantAdmin(String userId) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/users/$userId/grant-admin',
    );
    final envelope = response.data as Map<String, dynamic>;
    return AdminUser.fromJson(envelope['data'] as Map<String, dynamic>);
  }
}
