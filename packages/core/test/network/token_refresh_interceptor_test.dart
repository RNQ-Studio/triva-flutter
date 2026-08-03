import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authoritative refresh rejection clears tokens and expires session',
      () async {
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

  test('refresh 5xx preserves tokens and does not expire session', () async {
    final server = await _refreshFailureServer(HttpStatus.serviceUnavailable);
    final storage = _MemoryStorage({
      AppConstants.keyAuthToken: 'expired-access',
      AppConstants.keyRefreshToken: 'still-valid-refresh',
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
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'refresh status',
            HttpStatus.serviceUnavailable,
          ),
        ),
      );

      expect(await storage.read(AppConstants.keyAuthToken), 'expired-access');
      expect(
        await storage.read(AppConstants.keyRefreshToken),
        'still-valid-refresh',
      );
      expect(expiryCount, 0);
    } finally {
      await server.close(force: true);
    }
  });

  test('refresh timeout preserves tokens and does not expire session',
      () async {
    final refreshStarted = Completer<void>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      if (request.uri.path == '/v1/auth/refresh') {
        refreshStarted.complete();
        return;
      }
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
    });
    final storage = _MemoryStorage({
      AppConstants.keyAuthToken: 'expired-access',
      AppConstants.keyRefreshToken: 'still-valid-refresh',
    });
    var expiryCount = 0;
    final dio = Dio(
      BaseOptions(
        baseUrl: _serverUrl(server),
        receiveTimeout: const Duration(milliseconds: 50),
      ),
    );
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
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'refresh error type',
            DioExceptionType.receiveTimeout,
          ),
        ),
      );
      await refreshStarted.future;

      expect(await storage.read(AppConstants.keyAuthToken), 'expired-access');
      expect(
        await storage.read(AppConstants.keyRefreshToken),
        'still-valid-refresh',
      );
      expect(expiryCount, 0);
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

  test('logout during refresh cannot resurrect cleared tokens', () async {
    final refreshStarted = Completer<void>();
    final releaseRefresh = Completer<void>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/v1/auth/refresh') {
        refreshStarted.complete();
        await releaseRefresh.future;
        request.response.write(
          jsonEncode({
            'data': {
              'access_token': 'must-not-be-restored',
              'refresh_token': 'must-not-be-restored',
            },
          }),
        );
      } else {
        request.response.statusCode = HttpStatus.unauthorized;
      }
      await request.response.close();
    });
    final storage = _MemoryStorage({
      AppConstants.keyAuthToken: 'expired-access',
      AppConstants.keyRefreshToken: 'valid-refresh',
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
      final request = dio.get<dynamic>('protected');
      await refreshStarted.future;
      await storage.delete(AppConstants.keyAuthToken);
      await storage.delete(AppConstants.keyRefreshToken);
      releaseRefresh.complete();

      await expectLater(request, throwsA(isA<DioException>()));
      expect(await storage.read(AppConstants.keyAuthToken), isNull);
      expect(await storage.read(AppConstants.keyRefreshToken), isNull);
      expect(expiryCount, 0);
    } finally {
      await server.close(force: true);
    }
  });
}

Future<HttpServer> _refreshFailureServer(int refreshStatus) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response.headers.contentType = ContentType.json;
    if (request.uri.path == '/v1/auth/refresh') {
      request.response.statusCode = refreshStatus;
      request.response
          .write(jsonEncode({'message': 'Temporarily unavailable'}));
    } else {
      request.response.statusCode = HttpStatus.unauthorized;
      request.response.write(jsonEncode({'message': 'Unauthenticated.'}));
    }
    await request.response.close();
  });
  return server;
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
