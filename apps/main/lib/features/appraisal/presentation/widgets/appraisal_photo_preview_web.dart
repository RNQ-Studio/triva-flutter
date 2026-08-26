import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/appraisal_photo_store_web.dart';

/// Di browser jalur foto bukan berkas maupun URL yang bisa diambil pemuat
/// jaringan: URL blob mati begitu halaman dimuat ulang. Preview karena itu
/// membaca byte dari penyimpanan foto, yang menahannya di memori dan
/// IndexedDB.
ImageProvider appraisalPhotoProvider(String path) => _StoredPhotoImage(path);

@immutable
class _StoredPhotoImage extends ImageProvider<_StoredPhotoImage> {
  const _StoredPhotoImage(this.path);

  final String path;

  @override
  Future<_StoredPhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_StoredPhotoImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _decode(decode),
      scale: 1,
      debugLabel: path,
    );
  }

  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    final bytes = await webAppraisalPhotoStore.readBytes(path);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is _StoredPhotoImage && other.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'AppraisalPhotoImage("$path")';
}
