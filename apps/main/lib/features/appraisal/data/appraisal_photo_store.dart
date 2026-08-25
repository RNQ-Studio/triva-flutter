import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'appraisal_photo_store_io.dart'
    if (dart.library.js_interop) 'appraisal_photo_store_web.dart' as impl;

/// Penyimpanan foto appraisal yang belum terkirim.
///
/// Aplikasi berjalan di Android maupun Flutter Web, dan keduanya menyimpan
/// foto pilihan pelanggan dengan cara yang sama sekali berbeda: perangkat
/// menyalin berkas ke direktori milik akun, sedangkan browser hanya memberi
/// URL blob yang tidak bisa dibaca `dart:io`. Notulensi 19 Agustus 2026
/// mencatat preview foto tidak muncul saat upload dari galeri di web -- itu
/// akibat jalur berkas dipakai apa adanya di browser.
abstract interface class AppraisalPhotoStore {
  /// Menyimpan foto untuk satu sudut dan mengembalikan lokasi bacanya.
  Future<String> save({
    required String owner,
    required String angle,
    required XFile photo,
    String? previousPath,
  });

  /// Apakah foto pada lokasi tersebut masih dapat dibaca.
  Future<bool> exists(String path);

  Future<Uint8List> readBytes(String path);

  /// Membuang seluruh foto milik satu akun setelah appraisal terkirim.
  Future<void> clear(String owner);

  /// Membersihkan foto versi lama yang tersimpan tanpa pemilik, supaya draft
  /// akun lain tidak pernah terbaca.
  Future<void> purgeUnscopedLegacyPhotos();
}

AppraisalPhotoStore createAppraisalPhotoStore() =>
    impl.createAppraisalPhotoStore();
