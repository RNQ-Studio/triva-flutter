import 'package:dio/dio.dart';

import '../../admin_content/data/admin_content_payload.dart';
import '../domain/partner_logo_models.dart';

class PartnerLogoRepository {
  PartnerLogoRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Logo aktif untuk beranda, sudah terurut oleh server.
  Future<List<PartnerLogo>> listActive() async {
    final response = await _dio.get<dynamic>('v1/partner-logos');
    return _parseList(response.data)
        .where((logo) => logo.logoUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<PartnerLogo>> listAll() async {
    final response = await _dio.get<dynamic>('v1/admin/partner-logos');
    return _parseList(response.data);
  }

  Future<PartnerLogo> create(
    PartnerLogoInput input, {
    required List<int> logoBytes,
    required String logoName,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/partner-logos',
      data: _form(input, logoBytes: logoBytes, logoName: logoName),
    );
    return PartnerLogo.fromJson(dataMap(response.data));
  }

  Future<PartnerLogo> update(
    String id,
    PartnerLogoInput input, {
    List<int>? logoBytes,
    String? logoName,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/partner-logos/$id',
      data: _form(input, logoBytes: logoBytes, logoName: logoName),
    );
    return PartnerLogo.fromJson(dataMap(response.data));
  }

  Future<void> delete(String id) async {
    await _dio.delete<dynamic>('v1/admin/partner-logos/$id');
  }

  FormData _form(
    PartnerLogoInput input, {
    List<int>? logoBytes,
    String? logoName,
  }) {
    return FormData.fromMap({
      'name': input.name.trim(),
      // String kosong dijadikan null oleh server sehingga tautan dapat
      // dihapus kembali.
      'link_url': input.linkUrl.trim(),
      'sort_order': input.sortOrder,
      'is_active': input.isActive ? '1' : '0',
      if (logoBytes != null)
        'logo': MultipartFile.fromBytes(
          logoBytes,
          filename: logoName ?? 'logo.png',
        ),
    });
  }

  List<PartnerLogo> _parseList(Object? payload) {
    if (payload is! Map || payload['data'] is! List) return const [];
    return (payload['data'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(PartnerLogo.fromJson)
        .toList(growable: false);
  }
}
