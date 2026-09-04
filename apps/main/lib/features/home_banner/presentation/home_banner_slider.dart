import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/home_banner_models.dart';

/// Slider banner iklan di beranda: gambar rasio 2:1 yang berganti otomatis
/// dan bisa digeser, dengan indikator halaman.
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key, required this.banners});

  final List<HomeBanner> banners;

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(covariant HomeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _page = 0;
      _scheduleAutoplay();
    }
  }

  void _scheduleAutoplay() {
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
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
        AspectRatio(
          aspectRatio: 2,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => _page = page),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
              child: HomeBannerCard(banner: widget.banners[index]),
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.banners.length; index++)
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

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key, required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: banner.title,
      button: banner.hasLink,
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadius.large,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: banner.hasLink ? () => openHomeBanner(banner) : null,
          child: Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> openHomeBanner(HomeBanner banner) async {
  final url = banner.linkUrl;
  if (url == null || url.trim().isEmpty) return;
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    // Tautan banner bersifat opsional; kegagalan membuka browser tidak
    // boleh mengganggu beranda.
  }
}
