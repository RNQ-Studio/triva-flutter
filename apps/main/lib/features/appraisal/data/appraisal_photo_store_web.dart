import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'appraisal_photo_store.dart';
import 'appraisal_photo_web_cache.dart';

/// Satu instance dipakai seluruh aplikasi web supaya preview -- yang hanya
/// menerima jalur foto, bukan store-nya -- membaca byte yang sama.
final webAppraisalPhotoStore = WebAppraisalPhotoStore();

AppraisalPhotoStore createAppraisalPhotoStore() => webAppraisalPhotoStore;

/// Browser tidak memberi akses berkas, hanya URL blob yang mati begitu halaman
/// dimuat ulang. Byte-nya dibaca sekali saat foto dipilih, lalu disimpan di
/// memori untuk kecepatan dan di IndexedDB supaya bertahan melewati reload --
/// termasuk reload yang dipicu browser mobile setiap kali aplikasi kamera
/// dibuka.
class WebAppraisalPhotoStore implements AppraisalPhotoStore {
  WebAppraisalPhotoStore({AppraisalPhotoWebCache? cache})
      : _cache = cache ?? AppraisalPhotoWebCache();

  static const _prefix = 'appraisal-photo:';

  final AppraisalPhotoWebCache _cache;
  final Map<String, Uint8List> _bytesByPath = {};

  @override
  Future<String> save({
    required String owner,
    required String angle,
    required XFile photo,
    String? previousPath,
  }) async {
    final bytes = await photo.readAsBytes();
    // Jalur dibuat unik per pengambilan. Jalur yang dipakai ulang membuat cache
    // gambar Flutter menyajikan foto lama saat pelanggan mengganti foto sudut
    // yang sama.
    final path = '${_ownerPrefix(owner)}$angle'
        '-${DateTime.now().microsecondsSinceEpoch}${_extensionOf(photo)}';
    _bytesByPath[path] = bytes;
    await _cacheWrite(path, bytes);
    await _forget(
      await _stalePathsFor(
        owner,
        angle,
        keep: path,
        previous: previousPath,
      ),
    );

    return path;
  }

  @override
  Future<bool> exists(String path) async {
    if (_bytesByPath.containsKey(path)) return true;

    return await _restore(path) != null;
  }

  @override
  Future<Uint8List> readBytes(String path) async {
    final cached = _bytesByPath[path];
    if (cached != null) return cached;
    final restored = await _restore(path);
    if (restored == null) {
      // Draft lama menyimpan URL blob yang sudah dicabut browser, dan foto yang
      // gagal masuk IndexedDB tidak punya salinan lain. Pemanggil
      // memperlakukannya seperti foto hilang dan meminta pelanggan mengambil
      // ulang.
      throw StateError('Foto web tidak lagi tersedia: $path');
    }

    return restored;
  }

  @override
  Future<void> purgeUnscopedLegacyPhotos() async {
    // Foto web selalu tersimpan dengan kunci bermilik akun. Versi sebelumnya
    // tidak pernah menulis apa pun ke penyimpanan browser, jadi tidak ada sisa
    // tanpa pemilik yang perlu dibuang.
  }

  @override
  Future<void> clear(String owner) async {
    final prefix = _ownerPrefix(owner);
    _bytesByPath.removeWhere((path, _) => path.startsWith(prefix));
    await _forget(
      (await _cachedKeys()).where((key) => key.startsWith(prefix)),
    );
  }

  Future<Uint8List?> _restore(String path) async {
    if (!path.startsWith(_prefix)) return null;
    try {
      final bytes = await _cache.read(path);
      if (bytes != null) _bytesByPath[path] = bytes;

      return bytes;
    } on Object {
      return null;
    }
  }

  /// Jalur lain untuk sudut yang sama, termasuk jalur sebelumnya dari draft.
  /// Menyapu berdasarkan awalan sudut membuat foto yatim dari sesi yang
  /// terputus ikut terbuang, bukan menumpuk di kuota browser.
  Future<Iterable<String>> _stalePathsFor(
    String owner,
    String angle, {
    required String keep,
    String? previous,
  }) async {
    final anglePrefix = '${_ownerPrefix(owner)}$angle-';
    final stale = <String>{
      if (previous != null && previous != keep) previous,
      ..._bytesByPath.keys.where(
        (path) => path != keep && path.startsWith(anglePrefix),
      ),
      ...(await _cachedKeys()).where(
        (key) => key != keep && key.startsWith(anglePrefix),
      ),
    };

    return stale;
  }

  Future<void> _forget(Iterable<String> paths) async {
    final targets = paths.toList(growable: false);
    if (targets.isEmpty) return;
    for (final path in targets) {
      _bytesByPath.remove(path);
    }
    try {
      await _cache.delete(targets);
    } on Object {
      // Sampah di IndexedDB tidak boleh menggagalkan pemilihan foto.
    }
  }

  Future<void> _cacheWrite(String path, Uint8List bytes) async {
    try {
      await _cache.write(path, bytes);
    } on Object {
      // Penyimpanan browser bisa ditolak pada mode privat atau saat kuota
      // habis. Salinan memori tetap membuat sesi berjalan sampai selesai.
    }
  }

  Future<List<String>> _cachedKeys() async {
    try {
      return await _cache.keys();
    } on Object {
      return const [];
    }
  }

  static String _ownerPrefix(String owner) =>
      '$_prefix${owner.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')}/';

  static String _extensionOf(XFile photo) {
    final name = photo.name;
    final extension = name.contains('.')
        ? name.substring(name.lastIndexOf('.')).toLowerCase()
        : _extensionOfMimeType(photo.mimeType);

    return RegExp(r'^\.(jpg|jpeg|png|webp|heic)$').hasMatch(extension)
        ? extension
        : '.jpg';
  }

  static String _extensionOfMimeType(String? mimeType) =>
      switch (mimeType?.toLowerCase()) {
        'image/png' => '.png',
        'image/webp' => '.webp',
        'image/heic' => '.heic',
        _ => '.jpg',
      };
}
