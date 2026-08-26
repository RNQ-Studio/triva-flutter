import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Simpanan byte foto appraisal di IndexedDB milik browser.
///
/// Menahan foto di memori saja tidak cukup. Browser mobile rutin membuang tab
/// saat aplikasi kamera terbuka lewat `<input capture>`, lalu memuat ulang
/// halaman ketika pelanggan kembali. Draft yang dipulihkan masih memuat jalur
/// fotonya, tetapi byte-nya sudah lenyap -- preview jadi kosong dan foto tidak
/// pernah terunggah. IndexedDB membuat byte itu bertahan melewati reload.
///
/// Seluruh operasi boleh gagal: penyimpanan browser dapat ditolak pada mode
/// privat atau saat kuota habis. Pemanggil memperlakukan kegagalan sebagai
/// "tidak ada cache" dan tetap berjalan dengan salinan memori.
class AppraisalPhotoWebCache {
  static const _databaseName = 'triva_appraisal_photos';
  static const _storeName = 'photos';

  Future<web.IDBDatabase>? _connection;

  Future<void> write(String key, Uint8List bytes) async {
    final database = await _connect();
    final transaction = database.transaction(_storeName.toJS, 'readwrite');
    transaction.objectStore(_storeName).put(bytes.toJS, key.toJS);
    await _finished(transaction);
  }

  Future<Uint8List?> read(String key) async {
    final database = await _connect();
    final transaction = database.transaction(_storeName.toJS, 'readonly');
    final request = transaction.objectStore(_storeName).get(key.toJS);
    final result = await _resultOf(request);
    if (result == null || !result.isA<JSUint8Array>()) return null;

    return (result as JSUint8Array).toDart;
  }

  Future<List<String>> keys() async {
    final database = await _connect();
    final transaction = database.transaction(_storeName.toJS, 'readonly');
    final request = transaction.objectStore(_storeName).getAllKeys();
    final result = await _resultOf(request);
    if (result == null || !result.isA<JSArray<JSAny?>>()) return const [];

    return (result as JSArray<JSAny?>)
        .toDart
        .whereType<JSString>()
        .map((key) => key.toDart)
        .toList(growable: false);
  }

  Future<void> delete(Iterable<String> keys) async {
    final targets = keys.toList(growable: false);
    if (targets.isEmpty) return;
    final database = await _connect();
    final transaction = database.transaction(_storeName.toJS, 'readwrite');
    final store = transaction.objectStore(_storeName);
    for (final key in targets) {
      store.delete(key.toJS);
    }
    await _finished(transaction);
  }

  Future<web.IDBDatabase> _connect() async {
    final pending = _connection;
    if (pending != null) return pending;
    final opening = _openDatabase();
    _connection = opening;
    try {
      return await opening;
    } catch (_) {
      // Biarkan percobaan berikutnya membuka ulang; kegagalan sekali tidak
      // boleh mematikan cache untuk sisa sesi.
      _connection = null;
      rethrow;
    }
  }

  Future<web.IDBDatabase> _openDatabase() {
    final completer = Completer<web.IDBDatabase>();
    final request = web.window.indexedDB.open(_databaseName, 1);
    request.onupgradeneeded = ((web.Event _) {
      final database = request.result as web.IDBDatabase;
      if (!database.objectStoreNames.contains(_storeName)) {
        database.createObjectStore(_storeName);
      }
    }).toJS;
    request.onsuccess = ((web.Event _) {
      completer.complete(request.result as web.IDBDatabase);
    }).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(
        StateError('IndexedDB foto appraisal tidak dapat dibuka.'),
      );
    }).toJS;

    return completer.future;
  }

  Future<JSAny?> _resultOf(web.IDBRequest request) {
    final completer = Completer<JSAny?>();
    request.onsuccess = ((web.Event _) {
      completer.complete(request.result);
    }).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(
        StateError('Permintaan IndexedDB foto appraisal gagal.'),
      );
    }).toJS;

    return completer.future;
  }

  Future<void> _finished(web.IDBTransaction transaction) {
    final completer = Completer<void>();
    transaction.oncomplete = ((web.Event _) {
      completer.complete();
    }).toJS;
    void fail(web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Transaksi IndexedDB foto appraisal gagal.'),
        );
      }
    }

    transaction.onerror = fail.toJS;
    transaction.onabort = fail.toJS;

    return completer.future;
  }
}
