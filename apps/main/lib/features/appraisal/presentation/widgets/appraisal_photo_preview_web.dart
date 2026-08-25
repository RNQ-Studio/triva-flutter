import 'package:flutter/material.dart';

/// URL blob yang diberikan browser dapat dimuat lewat pemuat jaringan.
ImageProvider appraisalPhotoProvider(String path) => NetworkImage(path);
