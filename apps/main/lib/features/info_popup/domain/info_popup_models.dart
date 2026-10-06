/// Popup informasi bergambar yang menyambut pelanggan di beranda; dikelola
/// dari Admin Panel (revisi 6 Oktober 2026).
///
/// Beberapa popup yang jatuh tempo ditampilkan bersama sebagai slide menurut
/// [sortOrder], dan tiap popup muncul lagi di perangkat yang sama setelah
/// [intervalHours] berlalu.
class InfoPopup {
  const InfoPopup({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.buttonLabel,
    this.buttonUrl,
    this.sortOrder = 0,
    this.intervalHours = 24,
    this.updatedAt,
    this.isActive = true,
    this.isRunning = true,
    this.startsOn,
    this.endsOn,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? buttonLabel;
  final String? buttonUrl;
  final int sortOrder;
  final int intervalHours;
  final DateTime? updatedAt;

  /// Field berikut hanya dikirim endpoint admin; respons publik selalu berisi
  /// popup yang sedang tayang.
  final bool isActive;
  final bool isRunning;
  final DateTime? startsOn;
  final DateTime? endsOn;

  /// Tombol hanya tampil bila label dan tautannya sama-sama terisi.
  bool get hasButton =>
      (buttonLabel?.trim().isNotEmpty ?? false) &&
      (buttonUrl?.trim().isNotEmpty ?? false);

  factory InfoPopup.fromJson(Map<String, dynamic> json) => InfoPopup(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        buttonLabel: _optionalString(json['button_label']),
        buttonUrl: _optionalString(json['button_url']),
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        intervalHours: (json['interval_hours'] as num?)?.toInt() ?? 24,
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        isActive: json['is_active'] as bool? ?? true,
        isRunning: json['is_running'] as bool? ?? true,
        startsOn: DateTime.tryParse(json['starts_on']?.toString() ?? ''),
        endsOn: DateTime.tryParse(json['ends_on']?.toString() ?? ''),
      );
}

/// Isian form admin; [buttonLabel] dan [buttonUrl] kosong berarti popup tanpa
/// tombol.
class InfoPopupInput {
  const InfoPopupInput({
    required this.title,
    required this.sortOrder,
    required this.intervalHours,
    required this.isActive,
    this.buttonLabel = '',
    this.buttonUrl = '',
    this.startsOn,
    this.endsOn,
  });

  final String title;
  final String buttonLabel;
  final String buttonUrl;
  final int sortOrder;
  final int intervalHours;
  final bool isActive;
  final DateTime? startsOn;
  final DateTime? endsOn;
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
