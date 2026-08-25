/// Nomor WhatsApp tujuan tiap layanan cabang.
///
/// Notulensi 19 Agustus 2026 meminta pelanggan tersambung langsung ke WhatsApp
/// cabang setelah mengisi form: Booking Service Toyota & SSC ke 0857-1311-2000
/// dan Booking OtoXpert ke 0815-1106-0290, sementara Estimasi Body & Paint
/// diteruskan ke nomor PIC cabang.
class BranchContacts {
  const BranchContacts({
    required this.toyotaService,
    required this.otoxpert,
    required this.bodyPaint,
  });

  /// Nilai bawaan sama dengan nomor pada notulensi, sehingga handoff tetap
  /// bekerja walau konfigurasi server belum termuat atau jaringan gagal.
  static const fallback = BranchContacts(
    toyotaService: '6285713112000',
    otoxpert: '6281511060290',
    bodyPaint: '6285713112000',
  );

  final String toyotaService;
  final String otoxpert;
  final String bodyPaint;

  factory BranchContacts.fromConfig(Map<String, dynamic> config) =>
      BranchContacts(
        toyotaService: _number(
          config['whatsapp_toyota_service'],
          fallback.toyotaService,
        ),
        otoxpert: _number(config['whatsapp_otoxpert'], fallback.otoxpert),
        bodyPaint: _number(config['whatsapp_body_paint'], fallback.bodyPaint),
      );

  /// Menormalkan nomor apa pun bentuknya di panel admin -- `0857...`,
  /// `+62 857...`, atau bertanda hubung -- menjadi bentuk yang diterima
  /// tautan WhatsApp.
  static String _number(Object? raw, String fallbackNumber) {
    final digits = (raw?.toString() ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return fallbackNumber;
    if (digits.startsWith('62')) return digits;
    if (digits.startsWith('0')) return '62${digits.substring(1)}';
    if (digits.startsWith('8')) return '62$digits';

    return digits;
  }
}
