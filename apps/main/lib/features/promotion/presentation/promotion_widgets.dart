import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/promotion_models.dart';

/// Banner promo berjalan di halaman depan.
///
/// Notulensi 19 Agustus 2026 meminta konten promo Sales, Service GR, Service
/// BP, dan OtoXpert tampil berjalan dan diperbarui tiap bulan.
class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key, required this.promotions});

  final List<Promotion> promotions;

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.promotions.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_page + 1) % widget.promotions.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => _page = page),
            itemCount: widget.promotions.length,
            itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
              child: PromotionBanner(promotion: widget.promotions[index]),
            ),
          ),
        ),
        if (widget.promotions.length > 1) ...[
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.promotions.length; index++)
                Container(
                  width: index == _page ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color:
                        index == _page ? colors.primary : colors.outlineVariant,
                    borderRadius: AppRadius.pill,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class PromotionBanner extends StatelessWidget {
  const PromotionBanner({super.key, required this.promotion});

  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image = promotion.imageUrl;

    return Material(
      color: colors.primaryContainer,
      borderRadius: AppRadius.large,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openPromotion(promotion),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null && image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            if (image != null && image.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CategoryChip(label: promotion.categoryLabel),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    promotion.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: image == null || image.isEmpty
                              ? colors.onPrimaryContainer
                              : AppColors.surfaceLight,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (promotion.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      promotion.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: image == null || image.isEmpty
                                ? colors.onPrimaryContainer
                                : AppColors.surfaceLight,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: 2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accentStrong,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Pop-up promo unggulan bulan berjalan.
Future<void> showPromotionPopup(
  BuildContext context, {
  required Promotion promotion,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final image = promotion.imageUrl;

      return AlertDialog(
        contentPadding: const EdgeInsets.all(AppSpacing.large),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null && image.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: AppRadius.medium,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
              _CategoryChip(label: promotion.categoryLabel),
              const SizedBox(height: AppSpacing.small),
              Text(
                promotion.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (promotion.description != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(promotion.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.promoPopupDismiss),
          ),
          if (promotion.ctaUrl != null && promotion.ctaUrl!.isNotEmpty)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                openPromotion(promotion);
              },
              child: Text(promotion.ctaLabel ?? l10n.promoPopupCta),
            ),
        ],
      );
    },
  );
}

/// Membuka tautan promo bila cabang mengisinya. Promo tanpa tautan hanya
/// bersifat informasi, jadi ketukannya sengaja tidak melakukan apa-apa.
Future<void> openPromotion(Promotion promotion) async {
  final url = promotion.ctaUrl;
  if (url == null || url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    // Tautan yang tidak bisa dibuka tidak boleh menjatuhkan halaman depan.
  }
}
