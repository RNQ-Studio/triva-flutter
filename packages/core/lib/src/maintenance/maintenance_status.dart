import 'package:flutter/foundation.dart';

/// Status maintenance backend TRIVA.
///
/// Berasal dari dua sumber yang saling melengkapi: payload `maintenance_*`
/// pada `GET v1/app/config` (endpoint yang sengaja dibiarkan terbuka backend
/// saat sistem mati), dan envelope error `503 MAINTENANCE_MODE` yang muncul
/// pada request apa pun ketika sakelar menyala.
@immutable
class MaintenanceStatus {
  const MaintenanceStatus({
    required this.isActive,
    this.title,
    this.message,
    this.until,
  });

  const MaintenanceStatus.inactive()
      : isActive = false,
        title = null,
        message = null,
        until = null;

  /// Membaca objek `data` dari `GET v1/app/config`.
  factory MaintenanceStatus.fromConfig(Map<String, dynamic> config) {
    return MaintenanceStatus(
      isActive: _asBool(config['maintenance_mode']),
      title: _asText(config['maintenance_title']),
      message: _asText(config['maintenance_message']),
      until: _asDate(config['maintenance_until']),
    );
  }

  /// Membaca envelope error 503. Dipakai interceptor jaringan, sehingga
  /// sistem yang mati di tengah pemakaian langsung terdeteksi tanpa polling.
  factory MaintenanceStatus.fromErrorBody(Map<String, dynamic> body) {
    return MaintenanceStatus(
      isActive: true,
      message: _asText(body['message']),
    );
  }

  final bool isActive;
  final String? title;
  final String? message;
  final DateTime? until;

  /// Backend mengirim boolean asli, tapi baris `app_configs` lama pernah
  /// menyimpannya sebagai string. Terima keduanya daripada gagal diam-diam.
  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static String? _asText(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _asDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim())?.toLocal();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceStatus &&
          other.isActive == isActive &&
          other.title == title &&
          other.message == message &&
          other.until == until;

  @override
  int get hashCode => Object.hash(isActive, title, message, until);
}
