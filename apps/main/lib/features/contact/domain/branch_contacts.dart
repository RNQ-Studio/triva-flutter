/// Nomor WhatsApp tujuan tiap layanan cabang.
///
/// Notulensi 19 Agustus 2026 meminta pelanggan tersambung langsung ke WhatsApp
/// cabang setelah mengisi form: Booking Service Toyota & SSC ke 0857-1311-2000
/// dan Booking OtoXpert ke 0815-1106-0290, sementara Estimasi Body & Paint
/// diteruskan ke nomor PIC cabang. Revisi 13 Oktober 2026 menambah tombol
/// WhatsApp di beranda dan Simulasi Biaya Servis (0857-1311-2000), serta
/// mengarahkan hasil appraisal dan Simulasi Kredit ke PIC appraisal a.n. Sam
/// (0815-5568-7868).
class BranchContacts {
  const BranchContacts({
    required this.toyotaService,
    required this.otoxpert,
    required this.bodyPaint,
    this.general = '6285713112000',
    this.appraisalPic = '6281555687868',
    this.appraisalPicName = 'Sam',
    this.credit = '6281555687868',
    this.serviceEstimate = '6285713112000',
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

  /// Kontak umum di bagian paling bawah beranda.
  final String general;

  /// PIC appraisal: hasil appraisal, jadwal inspeksi, dan terima harga.
  final String appraisalPic;

  /// Nama PIC appraisal yang ditampilkan di tombol hasil appraisal.
  final String appraisalPicName;

  /// Konsultasi Simulasi Kredit.
  final String credit;

  /// Tindak lanjut Simulasi Biaya Servis.
  final String serviceEstimate;

  factory BranchContacts.fromConfig(Map<String, dynamic> config) =>
      BranchContacts(
        toyotaService: _number(
          config['whatsapp_toyota_service'],
          fallback.toyotaService,
        ),
        otoxpert: _number(config['whatsapp_otoxpert'], fallback.otoxpert),
        bodyPaint: _number(config['whatsapp_body_paint'], fallback.bodyPaint),
        general: _number(config['whatsapp_general'], fallback.general),
        appraisalPic: _number(
          config['whatsapp_appraisal_pic'],
          fallback.appraisalPic,
        ),
        appraisalPicName: _name(
          config['whatsapp_appraisal_pic_name'],
          fallback.appraisalPicName,
        ),
        credit: _number(config['whatsapp_credit'], fallback.credit),
        serviceEstimate: _number(
          config['whatsapp_service_estimate'],
          fallback.serviceEstimate,
        ),
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

  static String _name(Object? raw, String fallbackName) {
    final name = (raw?.toString() ?? '').trim();
    return name.isEmpty ? fallbackName : name;
  }
}
