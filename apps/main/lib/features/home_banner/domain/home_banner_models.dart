/// Banner iklan bergambar yang berputar di beranda; dikelola cabang lewat
/// panel admin (revisi 4 September 2026).
class HomeBanner {
  const HomeBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;

  bool get hasLink => linkUrl != null && linkUrl!.trim().isNotEmpty;

  factory HomeBanner.fromJson(Map<String, dynamic> json) => HomeBanner(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        linkUrl: json['link_url']?.toString(),
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}
