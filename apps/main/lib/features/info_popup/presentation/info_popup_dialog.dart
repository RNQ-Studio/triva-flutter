import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/info_popup_models.dart';

/// Menampilkan popup informasi sebagai satu dialog bergeser; urutan slide
/// mengikuti urutan [popups].
Future<void> showInfoPopupDialog(
  BuildContext context, {
  required List<InfoPopup> popups,
}) {
  if (popups.isEmpty) return Future.value();
  return showDialog<void>(
    context: context,
    builder: (context) => InfoPopupDialog(popups: popups),
  );
}

class InfoPopupDialog extends StatefulWidget {
  const InfoPopupDialog({super.key, required this.popups});

  final List<InfoPopup> popups;

  @override
  State<InfoPopupDialog> createState() => _InfoPopupDialogState();
}

class _InfoPopupDialogState extends State<InfoPopupDialog> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(InfoPopup popup) {
    Navigator.of(context).pop();
    openInfoPopupLink(popup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final popups = widget.popups;
    final current = popups[_page.clamp(0, popups.length - 1)];
    // Gambar 4:5 dibatasi tinggi layar supaya tombol tetap terlihat di
    // ponsel pendek maupun saat lanskap.
    final maxImageHeight = MediaQuery.sizeOf(context).height * 0.62;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xLarge),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxImageHeight),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: popups.length,
                    onPageChanged: (page) => setState(() => _page = page),
                    itemBuilder: (context, index) {
                      final popup = popups[index];
                      return Semantics(
                        image: true,
                        label: popup.title,
                        child: GestureDetector(
                          onTap: popup.hasButton ? () => _open(popup) : null,
                          child: InfoPopupImage(url: popup.imageUrl),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (popups.length > 1) ...[
              const SizedBox(height: AppSpacing.medium),
              Semantics(
                label: l10n.infoPopupPage(_page + 1, popups.length),
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < popups.length; index++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: index == _page ? 18 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: index == _page
                                ? colors.primary
                                : colors.outlineVariant,
                            borderRadius: AppRadius.pill,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.infoPopupClose),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  if (current.hasButton)
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _open(current),
                        child: Text(
                          current.buttonLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gambar popup yang selalu utuh di dalam bingkai 4:5; gambar berasio lain
/// tidak dipotong supaya teks di dalamnya tetap terbaca.
class InfoPopupImage extends StatelessWidget {
  const InfoPopupImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator()),
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Membuka tautan tombol popup di browser. Kegagalan membuka tautan tidak
/// boleh mengganggu beranda.
Future<void> openInfoPopupLink(InfoPopup popup) async {
  final uri = Uri.tryParse(popup.buttonUrl?.trim() ?? '');
  if (uri == null || !uri.hasScheme) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    // Diabaikan: popup hanya informasi tambahan.
  }
}
