import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Logo mitra yang tampil di permukaan customer.
///
/// Aset dinormalisasi dari kiriman brand: margin kosong dipangkas tanpa
/// mengubah bentuk, tipografi, atau warna lockup aslinya. Karena setiap lockup
/// punya rasio berbeda, [heightFactor] menyetarakan bobot optiknya di dalam
/// kotak yang sama.
enum PartnerBrand {
  auto2000(
    'assets/branding/auto2000.png',
    'Auto2000',
    0.58,
    Icons.car_repair_rounded,
  ),
  otoxpert(
    'assets/branding/otoxpert.png',
    'OtoXpert',
    0.55,
    Icons.handyman_rounded,
  ),
  acc(
    'assets/branding/acc.png',
    'ACC',
    1,
    Icons.account_balance_rounded,
  ),
  taf(
    'assets/branding/taf.png',
    'TAF',
    0.66,
    Icons.account_balance_rounded,
  ),
  olx(
    'assets/branding/olx.png',
    'OLX',
    0.70,
    Icons.storefront_rounded,
  );

  const PartnerBrand(
    this.asset,
    this.label,
    this.heightFactor,
    this.fallbackIcon,
  );

  final String asset;
  final String label;

  /// Tinggi maksimum logo sebagai pecahan tinggi kotak dudukannya.
  final double heightFactor;

  /// Glyph monokrom bila aset merek belum tersedia, supaya baris layanan tetap
  /// terbaca alih-alih menampilkan kotak kosong.
  final IconData fallbackIcon;
}

/// Logo mitra yang dipasang ke dalam kotak berukuran tetap.
///
/// Lockup mitra tetap berwarna asli — identitas merek tidak boleh diwarnai
/// ulang oleh palet monokrom TRIVA — sehingga selalu dialasi permukaan putih
/// agar terbaca sama pada tema terang maupun gelap.
class PartnerLogo extends StatelessWidget {
  const PartnerLogo({
    super.key,
    required this.brand,
    required this.boxHeight,
    this.boxWidth,
  });

  final PartnerBrand brand;
  final double boxHeight;
  final double? boxWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Center(
        child: ConstrainedBox(
          // Batas ganda ini membuat wordmark lebar dan badge tegak sama-sama
          // muat, dan `Image` tetap menjaga rasio aslinya.
          constraints: BoxConstraints(
            maxWidth: boxWidth ?? double.infinity,
            maxHeight: boxHeight * brand.heightFactor,
          ),
          child: Image.asset(
            brand.asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            semanticLabel: brand.label,
            errorBuilder: (context, error, stackTrace) => Icon(
              brand.fallbackIcon,
              size: boxHeight * brand.heightFactor,
              color: AppColors.accent,
              semanticLabel: brand.label,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu putih bergaris rambut sebagai dudukan netral untuk logo mitra.
///
/// Satu layanan bisa dijalankan lebih dari satu mitra — simulasi kredit
/// memakai ACC sekaligus TAF. Untuk kasus itu isi [secondaryBrand]: kedua
/// lockup berbagi satu kartu berukuran sama, sehingga baris layanan tetap
/// sejajar dengan baris bermitra tunggal.
class PartnerLogoPlate extends StatelessWidget {
  const PartnerLogoPlate({
    super.key,
    required this.brand,
    this.secondaryBrand,
    this.width = 92,
    this.height = 60,
  });

  final PartnerBrand brand;

  /// Mitra kedua pada layanan yang dijalankan bersama. `null` untuk layanan
  /// bermitra tunggal.
  final PartnerBrand? secondaryBrand;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final secondary = secondaryBrand;
    final boxHeight = height - AppSpacing.small;
    final boxWidth = width - AppSpacing.large;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.hairlineLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.xSmall,
        ),
        child: secondary == null
            ? PartnerLogo(
                brand: brand,
                boxHeight: boxHeight,
                boxWidth: boxWidth,
              )
            // Lebar dikunci di sini karena dudukan mitra tunggal juga
            // dikunci oleh `boxWidth`-nya sendiri; tanpa ini baris layanan
            // menerima lebar tak hingga dan `Expanded` tidak punya acuan.
            : SizedBox(
                width: boxWidth,
                child: Row(
                  children: [
                    // Lockup tegak seperti ACC hanya butuh sedikit lebar,
                    // sedangkan wordmark melebar seperti TAF butuh lebih —
                    // bagi ruangnya menurut bentuk supaya bobot optiknya
                    // setara.
                    Expanded(
                      flex: 4,
                      child: PartnerLogo(brand: brand, boxHeight: boxHeight),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      flex: 5,
                      child:
                          PartnerLogo(brand: secondary, boxHeight: boxHeight),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
