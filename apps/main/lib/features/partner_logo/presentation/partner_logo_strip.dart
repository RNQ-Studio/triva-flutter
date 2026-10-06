import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../branding/partner_brands.dart'
    show PartnerBrand, PartnerLogoPlate;
import '../domain/partner_logo_models.dart';
import 'partner_logo_controller.dart';

const _plateWidth = 72.0;
const _plateHeight = 46.0;

/// Bagian "Mitra resmi" di beranda.
///
/// Daftar logonya dikelola dari Admin Panel. Bila server tidak terjangkau,
/// kelima mitra bawaan yang diminta notulensi 19 Agustus 2026 tetap tampil
/// supaya beranda luring tidak kehilangan bagian ini; bila admin
/// menonaktifkan semua logo, bagian ini disembunyikan.
class PartnerLogoStrip extends ConsumerWidget {
  const PartnerLogoStrip({super.key});

  static const _fallbackBrands = [
    PartnerBrand.auto2000,
    PartnerBrand.otoxpert,
    PartnerBrand.olx,
    PartnerBrand.acc,
    PartnerBrand.taf,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logos = ref.watch(activePartnerLogosProvider);
    final List<Widget>? plates = logos.when(
      data: (items) => [
        for (final logo in items) PartnerNetworkLogoPlate(logo: logo),
      ],
      error: (_, __) => [
        for (final brand in _fallbackBrands)
          PartnerLogoPlate(
            brand: brand,
            width: _plateWidth,
            height: _plateHeight,
          ),
      ],
      loading: () => null,
    );
    if (plates != null && plates.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homePartnersTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          l10n.homePartnersSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (plates == null)
          const SizedBox(height: _plateHeight)
        else
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: plates,
          ),
      ],
    );
  }
}

/// Logo mitra unggahan admin di atas dudukan putih yang sama dengan
/// [PartnerLogoPlate], supaya lockup berwarna asli tetap terbaca pada tema
/// gelap.
class PartnerNetworkLogoPlate extends StatelessWidget {
  const PartnerNetworkLogoPlate({super.key, required this.logo});

  final PartnerLogo logo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: logo.name,
      button: logo.hasLink,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: AppColors.hairlineLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: logo.hasLink ? () => openPartnerLogoLink(logo) : null,
          child: SizedBox(
            width: _plateWidth,
            height: _plateHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: AppSpacing.small,
              ),
              child: Image.network(
                logo.logoUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    logo.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.accentStrong,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Membuka situs mitra di browser. Kegagalan membuka tautan tidak boleh
/// mengganggu beranda.
Future<void> openPartnerLogoLink(PartnerLogo logo) async {
  final uri = Uri.tryParse(logo.linkUrl?.trim() ?? '');
  if (uri == null || !uri.hasScheme) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    // Diabaikan: tautan mitra hanya pelengkap.
  }
}
