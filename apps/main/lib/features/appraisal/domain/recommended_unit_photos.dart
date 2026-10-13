/// Foto bawaan unit Toyota yang direkomendasikan di hasil appraisal.
///
/// Revisi 13 Oktober 2026: kartu unit rekomendasi memakai foto dari
/// `triva-docs/gambar-mobil`. Program kredit di produksi belum punya gambar,
/// jadi foto ini dibundel di aplikasi; gambar dari panel admin tetap
/// didahulukan bila ada.
const recommendedUnitPhotos = <String, String>{
  'raize': 'assets/units/raize.jpg',
  'veloz_hybrid': 'assets/units/veloz_hybrid.jpg',
  'zenix_hybrid': 'assets/units/zenix_hybrid.jpg',
  'innova_reborn': 'assets/units/innova_reborn.jpg',
  'agya': 'assets/units/agya.jpg',
};

/// Mencari foto berdasarkan `unit_key`, lalu nama model sebagai cadangan
/// untuk program yang belum diberi `unit_key` oleh cabang. Mengembalikan null
/// bila unitnya memang belum punya foto, supaya kartu tidak menampilkan mobil
/// yang salah.
String? recommendedUnitPhoto({String? unitKey, required String vehicleModel}) {
  final byKey = recommendedUnitPhotos[unitKey?.trim().toLowerCase()];
  if (byKey != null) return byKey;

  final model = vehicleModel.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  final key = switch (model) {
    _ when model.contains('zenix') => 'zenix_hybrid',
    _ when model.contains('innova') => 'innova_reborn',
    _ when model.contains('velozhybrid') => 'veloz_hybrid',
    _ when model.contains('raize') => 'raize',
    _ when model.contains('agya') => 'agya',
    _ => null,
  };

  return key == null ? null : recommendedUnitPhotos[key];
}
