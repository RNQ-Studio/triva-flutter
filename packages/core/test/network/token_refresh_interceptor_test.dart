import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresh failure clears tokens and announces session expiry', () async {
    final server = await _unauthorizedServer();
    final storage = _MemoryStorage({
      AppConstants.keyAuthToken: 'expired-access',
      AppConstants.keyRefreshToken: 'expired-refresh',
    });
    var expiryCount = 0;
    final dio = Dio(BaseOptions(baseUrl: _serverUrl(server)));
    dio.interceptors.add(
      TokenRefreshInterceptor(
        dio: dio,
        storage: storage,
        onLogout: () async => expiryCount++,
      ),
    );

    try {
      await expectLater(
        dio.get<dynamic>('protected'),
        throwsA(isA<DioException>()),
      );

      expect(await storage.read(AppConstants.keyAuthToken), isNull);
      expect(await storage.read(AppConstants.keyRefreshToken), isNull);
      expect(expiryCount, 1);
    } finally {
      await server.close(force: true);
    }
  });

  test('successful refresh stores rotated tokens and retries once', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/v1/auth/refresh') {
        request.response.write(
          jsonEncode({
            'data': {
              'access_token': 'rotated-access',
              'refresh_token': 'rotated-refresh',
            },
          }),
        );
      } else if (request.headers.value(HttpHeaders.authorizationHeader) ==
          'Bearer rotated-access') {
        request.response.write(jsonEncode({'data': 'ok'}));
      } else {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.write(jsonEncode({'message': 'Unauthenticated.'}));
      }
      await request.response.close();
    });
    final storage = _MemoryStorage({
      AppConstants.keyAuthToken: 'expired-access',
      AppConstants.keyRefreshToken: 'valid-refresh',
    });
    final dio = Dio(BaseOptions(baseUrl: _serverUrl(server)));
    dio.interceptors.add(
      TokenRefreshInterceptor(dio: dio, storage: storage),
    );

    try {
      final response = await dio.get<dynamic>('protected');

      expect(response.statusCode, HttpStatus.ok);
      expect(await storage.read(AppConstants.keyAuthToken), 'rotated-access');
      expect(
        await storage.read(AppConstants.keyRefreshToken),
        'rotated-refresh',
      );
    } finally {
      await server.close(force: true);
    }
  });
}

Future<HttpServer> _unauthorizedServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response.statusCode = HttpStatus.unauthorized;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'message': 'Unauthenticated.'}));
    await request.response.close();
  });
  return server;
}

String _serverUrl(HttpServer server) =>
    'http://${server.address.address}:${server.port}/';

class _MemoryStorage implements StorageService {
  _MemoryStorage(this.values);

  final Map<String, String> values;

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
