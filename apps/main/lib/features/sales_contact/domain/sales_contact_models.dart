/// Sales atau supervisor cabang yang bisa dihubungi pelanggan lewat WhatsApp
/// (revisi 4 September 2026). Dikelola admin lewat panel Data Sales.
class SalesContact {
  const SalesContact({
    required this.id,
    required this.name,
    required this.role,
    required this.whatsappNumber,
    this.roleLabel = '',
    this.photoUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;

  /// `sales` atau `spv`.
  final String role;
  final String roleLabel;

  /// Format internasional tanpa tanda plus (62812...), siap untuk wa.me.
  final String whatsappNumber;
  final String? photoUrl;
  final int sortOrder;

  bool get isSpv => role == 'spv';
  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  factory SalesContact.fromJson(Map<String, dynamic> json) => SalesContact(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: json['role']?.toString() ?? 'sales',
        roleLabel: json['role_label']?.toString() ?? '',
        whatsappNumber: json['whatsapp_number']?.toString() ?? '',
        photoUrl: json['photo_url']?.toString(),
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}

/// Daftar kontak dengan pembagian peran yang dibutuhkan alur WhatsApp.
class SalesDirectory {
  const SalesDirectory(this.contacts);

  final List<SalesContact> contacts;

  List<SalesContact> get sales =>
      contacts.where((item) => !item.isSpv).toList(growable: false);

  List<SalesContact> get supervisors =>
      contacts.where((item) => item.isSpv).toList(growable: false);

  /// Supervisor tujuan bawaan: SPV pertama, atau sales pertama bila cabang
  /// belum mendaftarkan supervisor.
  SalesContact? get defaultSupervisor =>
      supervisors.firstOrNull ?? sales.firstOrNull;

  bool get isEmpty => contacts.isEmpty;
}
