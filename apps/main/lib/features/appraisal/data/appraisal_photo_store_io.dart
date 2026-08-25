import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'appraisal_photo_store.dart';

AppraisalPhotoStore createAppraisalPhotoStore() => _IoAppraisalPhotoStore();

/// Menyalin foto ke direktori dokumen milik akun, sehingga draft bertahan
/// setelah aplikasi ditutup dan tidak bisa terbaca akun lain.
class _IoAppraisalPhotoStore implements AppraisalPhotoStore {
  @override
  Future<String> save({
    required String owner,
    required String angle,
    required XFile photo,
    String? previousPath,
  }) async {
    final directory = await _directory(owner);
    await directory.create(recursive: true);
    final extension = photo.name.contains('.')
        ? photo.name.substring(photo.name.lastIndexOf('.')).toLowerCase()
        : '.jpg';
    final target = File(
      '${directory.path}${Platform.pathSeparator}$angle$extension',
    );
    if (previousPath != null && previousPath != target.path) {
      final previous = File(previousPath);
      if (await previous.exists()) await previous.delete();
    }
    await File(photo.path).copy(target.path);

    return target.path;
  }

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<Uint8List> readBytes(String path) => File(path).readAsBytes();

  @override
  Future<void> clear(String owner) async {
    final directory = await _directory(owner);
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  @override
  Future<void> purgeUnscopedLegacyPhotos() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}triva_appraisal_draft',
    );
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      // Foto baru selalu berada di subdirektori milik akun. Hanya berkas yang
      // tergeletak langsung di direktori lama yang dibuang.
      if (entity is File) await entity.delete();
    }
  }

  Future<Directory> _directory(String owner) async {
    final root = await getApplicationDocumentsDirectory();
    final safeOwner = owner.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return Directory(
      '${root.path}${Platform.pathSeparator}triva_appraisal_draft'
      '${Platform.pathSeparator}$safeOwner',
    );
  }
}
