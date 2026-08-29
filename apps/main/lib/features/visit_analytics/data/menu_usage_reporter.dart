import 'package:dio/dio.dart';

import '../domain/menu_usage_models.dart';
import '../domain/visit_analytics_models.dart';

/// Melaporkan menu yang dipilih pelanggan ke backend.
///
/// Pelaporan bersifat best-effort: kegagalannya tidak boleh menghentikan
/// navigasi, jadi pemanggilnya tidak perlu menunggu maupun menangkap error.
class MenuUsageReporter {
  MenuUsageReporter(
    this._dio, {
    required VisitSource? source,
    required Future<({String version, String build})> Function() appInfo,
  })  : _source = source,
        _appInfo = appInfo;

  final Dio _dio;
  final VisitSource? _source;
  final Future<({String version, String build})> Function() _appInfo;
  ({String version, String build})? _cachedAppInfo;

  Future<void> track(MenuKey menu) async {
    final source = _source;
    if (source == null) return;

    try {
      final info = _cachedAppInfo ??= await _appInfo();
      await _dio.post<dynamic>(
        'v1/analytics/menu-usage',
        data: {
          'menu_key': menu.apiValue,
          'source': source.apiValue,
          if (info.version.isNotEmpty) 'app_version': info.version,
          if (info.build.isNotEmpty) 'app_build': info.build,
        },
      );
    } on Object {
      // Telemetri menu tidak boleh mengganggu pemakaian aplikasi.
    }
  }
}
