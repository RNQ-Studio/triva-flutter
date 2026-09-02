import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => AppConfig.instance = _TestConfig());
  setUp(() => MaintenanceSignal.instance.resetForTest());
  tearDown(() => MaintenanceSignal.instance.resetForTest());

  group('MaintenanceStatus.fromConfig', () {
    test('reads the maintenance payload from app config', () {
      final status = MaintenanceStatus.fromConfig({
        'maintenance_mode': true,
        'maintenance_title': 'Sedang Perawatan',
        'maintenance_message': 'Kembali sebentar lagi.',
        'maintenance_until': '2026-09-02T17:00:00+07:00',
      });

      expect(status.isActive, isTrue);
      expect(status.title, 'Sedang Perawatan');
      expect(status.message, 'Kembali sebentar lagi.');
      expect(status.until?.toUtc(), DateTime.utc(2026, 9, 2, 10));
    });

    test('accepts the legacy string form of the flag', () {
      expect(
        MaintenanceStatus.fromConfig({'maintenance_mode': 'true'}).isActive,
        isTrue,
      );
      expect(
        MaintenanceStatus.fromConfig({'maintenance_mode': '1'}).isActive,
        isTrue,
      );
      expect(
        MaintenanceStatus.fromConfig({'maintenance_mode': 'false'}).isActive,
        isFalse,
      );
    });

    test('treats missing and blank fields as absent', () {
      final status = MaintenanceStatus.fromConfig({
        'maintenance_mode': false,
        'maintenance_message': '   ',
      });

      expect(status.isActive, isFalse);
      expect(status.message, isNull);
      expect(status.title, isNull);
      expect(status.until, isNull);
    });

    test('ignores an unparseable until instead of throwing', () {
      final status = MaintenanceStatus.fromConfig({
        'maintenance_mode': true,
        'maintenance_until': 'kapan-kapan',
      });

      expect(status.isActive, isTrue);
      expect(status.until, isNull);
    });
  });

  group('MaintenanceSignal', () {
    test('reporting activates and clearing deactivates', () {
      final signal = MaintenanceSignal.instance;
      expect(signal.status.value.isActive, isFalse);

      signal.report(const MaintenanceStatus(isActive: true, message: 'Mati.'));
      expect(signal.status.value.isActive, isTrue);
      expect(signal.status.value.message, 'Mati.');

      signal.clear();
      expect(signal.status.value.isActive, isFalse);
    });

    test('an inactive report never activates the screen', () {
      final signal = MaintenanceSignal.instance;

      signal.report(const MaintenanceStatus.inactive());

      expect(signal.status.value.isActive, isFalse);
    });

    /// Envelope 503 hanya membawa pesan. Kalau ia menimpa status penuh dari
    /// app/config, judul dan perkiraan waktu hilang dari layar.
    test('a message-only report keeps richer detail already known', () {
      final signal = MaintenanceSignal.instance;
      final until = DateTime.utc(2026, 9, 2, 10);
      signal.report(
        MaintenanceStatus(
          isActive: true,
          title: 'Sedang Perawatan',
          message: 'Pesan awal.',
          until: until,
        ),
      );

      signal.report(
        const MaintenanceStatus(isActive: true, message: 'Pesan dari 503.'),
      );

      expect(signal.status.value.title, 'Sedang Perawatan');
      expect(signal.status.value.until, until);
      expect(signal.status.value.message, 'Pesan dari 503.');
    });

    test('apply mirrors the backend both ways', () {
      final signal = MaintenanceSignal.instance;

      signal.apply(const MaintenanceStatus(isActive: true, message: 'Mati.'));
      expect(signal.status.value.isActive, isTrue);

      signal.apply(const MaintenanceStatus.inactive());
      expect(signal.status.value.isActive, isFalse);
    });
  });

  group('DioClient maintenance interception', () {
    test('503 MAINTENANCE_MODE raises MaintenanceException and signals',
        () async {
      final server = await _maintenanceServer();
      final dio = Dio(BaseOptions(baseUrl: _serverUrl(server)));
      dio.interceptors.add(_interceptorUnderTest());

      try {
        await expectLater(
          dio.get<dynamic>('v1/quotes'),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              isA<MaintenanceException>().having(
                (e) => e.message,
                'message',
                'TRIVA sedang dalam perawatan.',
              ),
            ),
          ),
        );

        expect(MaintenanceSignal.instance.status.value.isActive, isTrue);
        expect(
          MaintenanceSignal.instance.status.value.message,
          'TRIVA sedang dalam perawatan.',
        );
      } finally {
        await server.close(force: true);
      }
    });

    /// 503 tanpa kode maintenance adalah server bermasalah, bukan sakelar.
    test('a plain 503 stays a ServerException and does not signal', () async {
      final server = await _plainErrorServer();
      final dio = Dio(BaseOptions(baseUrl: _serverUrl(server)));
      dio.interceptors.add(_interceptorUnderTest());

      try {
        await expectLater(
          dio.get<dynamic>('v1/quotes'),
          throwsA(
            isA<DioException>()
                .having((e) => e.error, 'error', isA<ServerException>()),
          ),
        );

        expect(MaintenanceSignal.instance.status.value.isActive, isFalse);
      } finally {
        await server.close(force: true);
      }
    });
  });
}

class _TestConfig implements AppConfig {
  @override
  String get baseUrl => 'http://localhost/';

  @override
  Environment get environment => Environment.dev;
}

/// `DioClient` menyusun interceptor error-nya secara privat, jadi test ini
/// memakai klien anonim yang memakai rantai interceptor yang sama.
Interceptor _interceptorUnderTest() =>
    DioClient.anonymous().dio.interceptors.last;

Future<HttpServer> _maintenanceServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response.statusCode = HttpStatus.serviceUnavailable;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({
        'success': false,
        'message': 'TRIVA sedang dalam perawatan.',
        'code': 'MAINTENANCE_MODE',
      }),
    );
    await request.response.close();
  });
  return server;
}

Future<HttpServer> _plainErrorServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response.statusCode = HttpStatus.serviceUnavailable;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'success': false, 'message': 'Server error.'}),
    );
    await request.response.close();
  });
  return server;
}

String _serverUrl(HttpServer server) =>
    'http://${server.address.address}:${server.port}/';
