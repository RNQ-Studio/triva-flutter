import 'package:dio/dio.dart';

import '../../admin_content/data/admin_content_payload.dart';
import '../domain/info_popup_models.dart';

class InfoPopupRepository {
  InfoPopupRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Popup yang sedang tayang untuk beranda, sudah terurut oleh server.
  Future<List<InfoPopup>> listRunning() async {
    final response = await _dio.get<dynamic>('v1/info-popups');
    return _parseList(response.data)
        .where((popup) => popup.imageUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<InfoPopup>> listAll() async {
    final response = await _dio.get<dynamic>('v1/admin/info-popups');
    return _parseList(response.data);
  }

  Future<InfoPopup> create(
    InfoPopupInput input, {
    required List<int> imageBytes,
    required String imageName,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/info-popups',
      data: _form(input, imageBytes: imageBytes, imageName: imageName),
    );
    return InfoPopup.fromJson(dataMap(response.data));
  }

  /// Gambar hanya dikirim bila admin memilih gambar baru; server mengganti
  /// dan membuang berkas lama.
  Future<InfoPopup> update(
    String id,
    InfoPopupInput input, {
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final response = await _dio.post<dynamic>(
      'v1/admin/info-popups/$id',
      data: _form(input, imageBytes: imageBytes, imageName: imageName),
    );
    return InfoPopup.fromJson(dataMap(response.data));
  }

  Future<void> delete(String id) async {
    await _dio.delete<dynamic>('v1/admin/info-popups/$id');
  }

  FormData _form(
    InfoPopupInput input, {
    List<int>? imageBytes,
    String? imageName,
  }) {
    // String kosong sengaja dikirim: server mengubahnya menjadi null, jadi
    // tombol dan tanggal tayang dapat dikosongkan kembali saat ubah data.
    return FormData.fromMap({
      'title': input.title.trim(),
      'button_label': input.buttonLabel.trim(),
      'button_url': input.buttonUrl.trim(),
      'sort_order': input.sortOrder,
      'interval_hours': input.intervalHours,
      'is_active': input.isActive ? '1' : '0',
      'starts_on': apiDate(input.startsOn),
      'ends_on': apiDate(input.endsOn),
      if (imageBytes != null)
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageName ?? 'popup.jpg',
        ),
    });
  }

  List<InfoPopup> _parseList(Object? payload) {
    if (payload is! Map || payload['data'] is! List) return const [];
    return (payload['data'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(InfoPopup.fromJson)
        .toList(growable: false);
  }
}
