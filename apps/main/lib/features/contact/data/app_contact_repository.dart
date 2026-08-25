import 'package:dio/dio.dart';

import '../domain/branch_contacts.dart';

class AppContactRepository {
  AppContactRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Konfigurasi publik memuat nomor WhatsApp cabang. Kegagalan memuatnya
  /// tidak boleh memutus alur booking, jadi nilai bawaan yang dipakai.
  Future<BranchContacts> branchContacts() async {
    try {
      final response = await _dio.get<dynamic>('v1/app/config');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return BranchContacts.fromConfig(
          Map<String, dynamic>.from(data['data'] as Map),
        );
      }
    } on Object {
      // Nomor bawaan sudah benar per notulensi 19 Agustus 2026.
    }

    return BranchContacts.fallback;
  }
}
