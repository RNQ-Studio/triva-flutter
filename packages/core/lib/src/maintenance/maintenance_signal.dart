import 'package:flutter/foundation.dart';

import 'maintenance_status.dart';

/// Kanal tunggal yang menghubungkan lapisan jaringan dengan UI.
///
/// `DioClient` dibangun ad-hoc di banyak controller dan tidak melewati
/// container Riverpod, jadi interceptor tidak punya cara menyuntikkan state
/// lewat provider. Satu titik global — sejalan dengan `AppConfig.instance` —
/// membuat setiap request yang menabrak 503 `MAINTENANCE_MODE` bisa
/// menyalakan layar maintenance dari mana pun ia terjadi.
class MaintenanceSignal {
  MaintenanceSignal._();

  static final MaintenanceSignal instance = MaintenanceSignal._();

  final ValueNotifier<MaintenanceStatus> status =
      ValueNotifier<MaintenanceStatus>(const MaintenanceStatus.inactive());

  /// Melaporkan sistem sedang mati.
  ///
  /// Status yang sudah aktif tidak ditimpa oleh laporan yang lebih miskin
  /// informasi: pesan dari `app/config` membawa judul dan perkiraan waktu,
  /// sedangkan laporan dari envelope 503 hanya membawa pesan.
  void report(MaintenanceStatus next) {
    if (!next.isActive) return;

    final current = status.value;
    if (current.isActive && next.title == null && next.until == null) {
      if (next.message == null || next.message == current.message) return;
      status.value = MaintenanceStatus(
        isActive: true,
        title: current.title,
        message: next.message,
        until: current.until,
      );
      return;
    }

    status.value = next;
  }

  /// Menandai sistem sudah hidup kembali.
  void clear() {
    if (status.value.isActive) {
      status.value = const MaintenanceStatus.inactive();
    }
  }

  /// Menerapkan hasil pembacaan `app/config` apa adanya, baik menyalakan
  /// maupun mematikan layar maintenance.
  void apply(MaintenanceStatus next) {
    if (next.isActive) {
      report(next);
    } else {
      clear();
    }
  }

  @visibleForTesting
  void resetForTest() {
    status.value = const MaintenanceStatus.inactive();
  }
}
