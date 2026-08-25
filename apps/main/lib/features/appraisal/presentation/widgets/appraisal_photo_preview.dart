import 'package:flutter/material.dart';

import 'appraisal_photo_preview_io.dart'
    if (dart.library.js_interop) 'appraisal_photo_preview_web.dart' as impl;

/// Sumber gambar untuk foto appraisal yang belum terkirim.
///
/// Di perangkat lokasinya berupa berkas, di browser berupa URL blob. Memakai
/// `Image.file` untuk keduanya membuat preview di web tidak pernah muncul --
/// keluhan yang dicatat notulensi 19 Agustus 2026.
ImageProvider appraisalPhotoProvider(String path) =>
    impl.appraisalPhotoProvider(path);
