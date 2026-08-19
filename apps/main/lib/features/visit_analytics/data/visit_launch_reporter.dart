import 'dart:math';

import 'package:dio/dio.dart';

import '../domain/visit_analytics_models.dart';

class VisitLaunchReporter {
  VisitLaunchReporter(
    this._dio, {
    String Function()? visitIdFactory,
  }) : _visitIdFactory = visitIdFactory ?? createVisitId;

  final Dio _dio;
  final String Function() _visitIdFactory;
  String? _visitId;
  bool _completed = false;

  /// Records at most one successful visit for this reporter instance.
  ///
  /// A failed retry keeps the same visit ID so the backend can de-duplicate a
  /// request whose response was lost after the write completed.
  Future<void> report({
    required VisitSource source,
    required String appVersion,
    required String appBuild,
  }) async {
    if (_completed) return;
    final visitId = _visitId ??= _visitIdFactory();
    await _dio.post<dynamic>(
      'v1/analytics/visits',
      data: {
        'visit_id': visitId,
        'source': source.apiValue,
        if (appVersion.isNotEmpty) 'app_version': appVersion,
        if (appBuild.isNotEmpty) 'app_build': appBuild,
      },
    );
    _completed = true;
  }
}

String createVisitId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0'));
  final value = hex.join();
  return '${value.substring(0, 8)}-'
      '${value.substring(8, 12)}-'
      '${value.substring(12, 16)}-'
      '${value.substring(16, 20)}-'
      '${value.substring(20)}';
}
