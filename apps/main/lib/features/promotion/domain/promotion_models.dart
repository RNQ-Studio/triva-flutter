/// Konten promo yang tampil sebagai banner berjalan dan pop-up halaman depan.
///
/// Notulensi 19 Agustus 2026: "Tampilkan Pop Up Promo konten berjalan Sales,
/// Service GR, Service BP, OtoXpert (Update per Month)".
class Promotion {
  const Promotion({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.startsOn,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
    this.showAsPopup = false,
    this.endsOn,
  });

  final String id;
  final String category;
  final String categoryLabel;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;
  final bool showAsPopup;
  final String startsOn;
  final String? endsOn;

  /// Penanda periode tayang, dipakai untuk memastikan pop-up muncul sekali
  /// per periode promo alih-alih setiap kali aplikasi dibuka.
  String get periodKey => '$id:$startsOn:${endsOn ?? 'open'}';

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        categoryLabel: json['category_label']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString(),
        description: json['description']?.toString(),
        imageUrl: json['image_url']?.toString(),
        ctaLabel: json['cta_label']?.toString(),
        ctaUrl: json['cta_url']?.toString(),
        showAsPopup: json['show_as_popup'] == true,
        startsOn: json['starts_on']?.toString() ?? '',
        endsOn: json['ends_on']?.toString(),
      );
}
