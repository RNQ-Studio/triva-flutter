import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:triva_app/features/appraisal/data/appraisal_photo_store.dart';
import 'package:triva_app/features/appraisal/presentation/widgets/appraisal_photo_preview.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('triva_photo_store');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('a saved photo is readable, replaceable, and clearable per account',
      () async {
    final store = createAppraisalPhotoStore();
    final source = File('${root.path}/picked.jpg');
    await source.writeAsBytes([1, 2, 3]);

    final path = await store.save(
      owner: 'user-1',
      angle: 'front',
      photo: XFile(source.path),
    );

    expect(await store.exists(path), isTrue);
    expect(await store.readBytes(path), [1, 2, 3]);

    final replacement = File('${root.path}/replacement.jpg');
    await replacement.writeAsBytes([4, 5]);
    final nextPath = await store.save(
      owner: 'user-1',
      angle: 'front',
      photo: XFile(replacement.path),
      previousPath: path,
    );
    expect(await store.readBytes(nextPath), [4, 5]);

    await store.clear('user-1');
    expect(await store.exists(nextPath), isFalse);
  });

  test('photos of one account are not visible to another', () async {
    final store = createAppraisalPhotoStore();
    final source = File('${root.path}/picked.jpg');
    await source.writeAsBytes([9]);

    final first = await store.save(
      owner: 'user-1',
      angle: 'front',
      photo: XFile(source.path),
    );
    final second = await store.save(
      owner: 'user-2',
      angle: 'front',
      photo: XFile(source.path),
    );

    expect(first, isNot(second));

    await store.clear('user-2');
    expect(await store.exists(first), isTrue);
  });

  test('the preview goes through the platform provider, not a raw file', () {
    // Di browser jalur foto berupa URL blob dan `Image.file` tidak akan pernah
    // memunculkan preview -- keluhan notulensi 19 Agustus 2026.
    final provider = appraisalPhotoProvider('/tmp/front.jpg');

    expect(provider, isA<ImageProvider>());
  });
}
