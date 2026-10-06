import 'dart:convert';

import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/info_popup_repository.dart';
import '../domain/info_popup_models.dart';

final infoPopupRepositoryProvider = Provider<InfoPopupRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return InfoPopupRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final runningInfoPopupsProvider = FutureProvider<List<InfoPopup>>((ref) {
  return ref.watch(infoPopupRepositoryProvider).listRunning();
});

/// Mengingat kapan tiap popup terakhir tampil di perangkat ini, supaya popup
/// hanya muncul lagi setelah jeda `interval_hours` yang diatur admin.
class InfoPopupSchedule {
  InfoPopupSchedule(this._storage);

  static const _key = 'info_popup_last_shown_v1';

  /// Catatan yang lebih tua dari ini milik popup yang sudah lama selesai.
  static const _retention = Duration(days: 60);

  final StorageService _storage;

  Future<List<InfoPopup>> due(
    List<InfoPopup> popups, {
    DateTime? now,
  }) async {
    final shown = await _read();
    final reference = now ?? DateTime.now();
    final due = popups
        .where((popup) => isInfoPopupDue(popup, shown[popup.id], reference))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return due;
  }

  Future<void> markShown(Iterable<InfoPopup> popups, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final shown = await _read()
      ..removeWhere(
        (_, record) => reference.difference(record.shownAt) > _retention,
      );
    for (final popup in popups) {
      shown[popup.id] = InfoPopupShownRecord(
        shownAt: reference,
        version: popup.updatedAt?.toIso8601String(),
      );
    }
    await _storage.write(
      _key,
      jsonEncode({
        for (final entry in shown.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  Future<Map<String, InfoPopupShownRecord>> _read() async {
    try {
      final raw = await _storage.read(_key);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return {
        for (final entry in decoded.entries)
          if (InfoPopupShownRecord.tryParse(entry.value) case final record?)
            entry.key: record,
      };
    } on FormatException {
      // Catatan rusak cukup dianggap kosong; akibat terburuknya popup tampil
      // sekali lagi.
      return {};
    }
  }
}

class InfoPopupShownRecord {
  const InfoPopupShownRecord({required this.shownAt, this.version});

  final DateTime shownAt;

  /// `updated_at` popup saat terakhir tampil. Dibandingkan apa adanya, bukan
  /// sebagai waktu, supaya jam perangkat yang meleset tidak membuat popup
  /// tampil terus-menerus.
  final String? version;

  Map<String, Object?> toJson() => {
        't': shownAt.millisecondsSinceEpoch,
        'v': version,
      };

  static InfoPopupShownRecord? tryParse(Object? value) {
    if (value is! Map || value['t'] is! int) return null;
    return InfoPopupShownRecord(
      shownAt: DateTime.fromMillisecondsSinceEpoch(value['t'] as int),
      version: value['v']?.toString(),
    );
  }
}

/// Popup jatuh tempo bila belum pernah tampil, isinya diubah admin sejak
/// terakhir tampil, atau jeda tayangnya sudah lewat.
bool isInfoPopupDue(
  InfoPopup popup,
  InfoPopupShownRecord? lastShown,
  DateTime now,
) {
  if (lastShown == null) return true;
  final version = popup.updatedAt?.toIso8601String();
  if (version != null && version != lastShown.version) return true;
  final hours = popup.intervalHours < 1 ? 1 : popup.intervalHours;
  return !now.isBefore(lastShown.shownAt.add(Duration(hours: hours)));
}

final infoPopupScheduleProvider = Provider<InfoPopupSchedule>((ref) {
  return InfoPopupSchedule(ref.watch(storageServiceProvider));
});

/// Daftar popup untuk Admin Panel, termasuk yang nonaktif atau terjadwal.
class AdminInfoPopupsController extends AsyncNotifier<List<InfoPopup>> {
  InfoPopupRepository get _repository => ref.read(infoPopupRepositoryProvider);

  @override
  Future<List<InfoPopup>> build() =>
      ref.watch(infoPopupRepositoryProvider).listAll();

  /// Membuat popup baru bila [id] kosong. Error dari server diteruskan ke
  /// pemanggil supaya pesan validasinya bisa ditampilkan di form.
  Future<void> save({
    String? id,
    required InfoPopupInput input,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    if (id == null) {
      await _repository.create(
        input,
        imageBytes: imageBytes!,
        imageName: imageName ?? 'popup.jpg',
      );
    } else {
      await _repository.update(
        id,
        input,
        imageBytes: imageBytes,
        imageName: imageName,
      );
    }
    _refresh();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _refresh();
  }

  void _refresh() {
    ref
      ..invalidateSelf()
      ..invalidate(runningInfoPopupsProvider);
  }
}

final adminInfoPopupsProvider =
    AsyncNotifierProvider<AdminInfoPopupsController, List<InfoPopup>>(
  AdminInfoPopupsController.new,
);
