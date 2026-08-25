import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'appraisal_photo_store.dart';

AppraisalPhotoStore createAppraisalPhotoStore() => _WebAppraisalPhotoStore();

/// Browser tidak memberi akses berkas, hanya URL blob yang hidup selama
/// halaman terbuka. Isinya dibaca sekali saat dipilih lalu disimpan di memori
/// supaya preview dan unggahan tetap bekerja walau blob-nya dicabut.
class _WebAppraisalPhotoStore implements AppraisalPhotoStore {
  final Map<String, Uint8List> _bytesByPath = {};
  final Map<String, Set<String>> _pathsByOwner = {};

  @override
  Future<String> save({
    required String owner,
    required String angle,
    required XFile photo,
    String? previousPath,
  }) async {
    if (previousPath != null) {
      _bytesByPath.remove(previousPath);
      _pathsByOwner[owner]?.remove(previousPath);
    }
    final path = photo.path;
    _bytesByPath[path] = await photo.readAsBytes();
    _pathsByOwner.putIfAbsent(owner, () => <String>{}).add(path);

    return path;
  }

  @override
  Future<bool> exists(String path) async => _bytesByPath.containsKey(path);

  @override
  Future<Uint8List> readBytes(String path) async {
    final bytes = _bytesByPath[path];
    if (bytes == null) {
      // Draft yang dipulihkan setelah halaman dimuat ulang membawa URL blob
      // yang sudah mati. Pemanggil memperlakukannya seperti foto hilang dan
      // meminta pelanggan memilih ulang.
      throw StateError('Foto web tidak lagi tersedia: $path');
    }

    return bytes;
  }

  @override
  Future<void> purgeUnscopedLegacyPhotos() async {
    // Browser tidak pernah menulis berkas, jadi tidak ada sisa versi lama.
  }

  @override
  Future<void> clear(String owner) async {
    for (final path in _pathsByOwner.remove(owner) ?? const <String>{}) {
      _bytesByPath.remove(path);
    }
  }
}
