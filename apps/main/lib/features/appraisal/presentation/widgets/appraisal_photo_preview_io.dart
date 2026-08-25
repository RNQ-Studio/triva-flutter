import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider appraisalPhotoProvider(String path) => FileImage(File(path));
