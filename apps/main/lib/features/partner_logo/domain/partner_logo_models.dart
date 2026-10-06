/// Logo mitra pada bagian "Mitra resmi" di beranda; dikelola dari Admin
/// Panel (revisi 6 Oktober 2026).
class PartnerLogo {
  const PartnerLogo({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.linkUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String logoUrl;
  final String? linkUrl;
  final int sortOrder;

  /// Hanya dikirim endpoint admin; respons publik selalu berisi logo aktif.
  final bool isActive;

  bool get hasLink => linkUrl?.trim().isNotEmpty ?? false;

  factory PartnerLogo.fromJson(Map<String, dynamic> json) {
    final link = json['link_url']?.toString().trim();
    return PartnerLogo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? '',
      linkUrl: link == null || link.isEmpty ? null : link,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class PartnerLogoInput {
  const PartnerLogoInput({
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.linkUrl = '',
  });

  final String name;
  final String linkUrl;
  final int sortOrder;
  final bool isActive;
}
