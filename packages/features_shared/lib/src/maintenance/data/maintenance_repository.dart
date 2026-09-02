import 'package:core/core.dart';

/// Membaca status maintenance dari endpoint publik `v1/app/config`.
///
/// Endpoint ini sengaja dikecualikan backend dari sakelar maintenance, jadi
/// ia tetap menjawab 200 justru ketika seluruh sistem lain menolak melayani.
class MaintenanceRepository {
  MaintenanceRepository({DioClient? client})
      : _client = client ?? DioClient.anonymous();

  final DioClient _client;

  /// Mengembalikan `null` bila status tidak dapat dipastikan.
  ///
  /// Jaringan mati bukan berarti sistem sedang maintenance, dan menebak
  /// "maintenance" pada setiap kegagalan koneksi akan mengunci user di layar
  /// yang salah. Pemanggil memperlakukan `null` sebagai "biarkan apa adanya".
  Future<MaintenanceStatus?> fetch() async {
    try {
      final response = await _client.dio.get<dynamic>('v1/app/config');
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        return MaintenanceStatus.fromConfig(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      return null;
    } on Object {
      return null;
    }
  }
}
