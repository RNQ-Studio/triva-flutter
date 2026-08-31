/// Asal angka total download yang dilaporkan backend.
///
/// Google Play tidak menyediakan API jumlah instal, jadi backend menghitungnya
/// dari perangkat unik yang pernah membuka aplikasi, atau mengambilnya dari
/// App Config yang diisi admin maupun ekspor laporan Play Console. Panel admin
/// menyebutkan asalnya supaya pembaca tahu angka apa yang sedang dilihat.
enum PlayStoreInstallsSource {
  manual('manual'),
  playReports('play_reports'),
  uniqueDevices('unique_devices');

  const PlayStoreInstallsSource(this.apiValue);

  final String apiValue;

  static PlayStoreInstallsSource? fromApi(Object? value) {
    for (final source in PlayStoreInstallsSource.values) {
      if (source.apiValue == value) return source;
    }
    return null;
  }
}

class PlayStoreInstallsSnapshot {
  const PlayStoreInstallsSnapshot({
    required this.packageName,
    required this.generatedAt,
    this.totalInstalls,
    this.source,
    this.reportedAt,
  });

  factory PlayStoreInstallsSnapshot.fromJson(Map<String, dynamic> json) =>
      PlayStoreInstallsSnapshot(
        packageName: json['package_name'] as String? ?? '',
        generatedAt: _parseDate(json['generated_at']) ?? DateTime.now(),
        totalInstalls: (json['total_installs'] as num?)?.toInt(),
        source: PlayStoreInstallsSource.fromApi(json['source']),
        reportedAt: _parseDate(json['reported_at']),
      );

  final String packageName;
  final DateTime generatedAt;

  /// Null selama angkanya belum pernah diisi di panel web. Nol adalah nilai
  /// yang sah dan sengaja tidak disamakan dengan keadaan belum diisi.
  final int? totalInstalls;

  final PlayStoreInstallsSource? source;

  /// Tanggal berlakunya angka, bukan waktu pengambilan data.
  final DateTime? reportedAt;

  bool get isConfigured => totalInstalls != null;
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
