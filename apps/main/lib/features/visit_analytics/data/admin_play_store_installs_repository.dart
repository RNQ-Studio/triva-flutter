import 'package:dio/dio.dart';

import '../domain/play_store_installs_models.dart';

class AdminPlayStoreInstallsRepository {
  const AdminPlayStoreInstallsRepository(this._dio);

  final Dio _dio;

  Future<PlayStoreInstallsSnapshot> fetch() async {
    final response =
        await _dio.get<dynamic>('v1/admin/analytics/play-store-installs');
    final envelope = response.data;
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Play Store installs envelope is invalid');
    }
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Play Store installs data is invalid');
    }

    return PlayStoreInstallsSnapshot.fromJson(data);
  }
}
