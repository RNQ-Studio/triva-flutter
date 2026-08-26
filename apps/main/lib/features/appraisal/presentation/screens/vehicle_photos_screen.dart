import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';
import '../widgets/appraisal_photo_preview.dart';

class VehiclePhotosScreen extends ConsumerStatefulWidget {
  const VehiclePhotosScreen({super.key});

  @override
  ConsumerState<VehiclePhotosScreen> createState() =>
      _VehiclePhotosScreenState();
}

class _VehiclePhotosScreenState extends ConsumerState<VehiclePhotosScreen> {
  final _picker = ImagePicker();
  String? _busyAngle;

  Future<void> _pick(String angle) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoAdd),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _busyAngle = angle);
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 2200,
      );
      if (photo != null) {
        await ref.read(appraisalFlowProvider.notifier).savePhoto(angle, photo);
      }
    } on PlatformException {
      _showError(l10n.photoPermissionError);
    } on Object {
      // Di browser foto bisa gagal dibaca walau pemilihannya sukses, misalnya
      // saat URL blob sudah dicabut. Tanpa pesan, layar terlihat seperti tidak
      // merespons sama sekali.
      _showError(l10n.photoReadError);
    } finally {
      if (mounted) setState(() => _busyAngle = null);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = ref.watch(appraisalFlowProvider).value;
    if (value == null) return const AppraisalLoading();
    final draft = value.draft;
    final labels = {
      'front': l10n.photoFront,
      'rear': l10n.photoRear,
      'left_side': l10n.photoLeft,
      'right_side': l10n.photoRight,
      'dashboard_odometer': l10n.photoDashboard,
    };

    return AppraisalFlowScaffold(
      step: 3,
      fallbackLocation: appraisalConditionPath,
      title: l10n.photosTitle,
      description: l10n.photosDescription,
      primaryLabel:
          draft.hasAllPhotos ? l10n.next : '${draft.photoPaths.length}/5',
      onPrimary:
          draft.hasAllPhotos ? () => context.push(appraisalReviewPath) : null,
      body: Column(
        children: [
          if (draft.hasAllPhotos) ...[
            _CompleteBanner(label: l10n.photosComplete),
            const SizedBox(height: AppSpacing.medium),
          ],
          for (final angle in appraisalPhotoAngles) ...[
            _PhotoTile(
              label: labels[angle]!,
              path: draft.photoPaths[angle],
              busy: _busyAngle == angle,
              onTap: () => _pick(angle),
            ),
            if (angle != appraisalPhotoAngles.last)
              const SizedBox(height: AppSpacing.medium),
          ],
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.label,
    required this.path,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final String? path;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onTap,
        child: SizedBox(
          height: 148,
          child: Row(
            children: [
              SizedBox(
                width: 124,
                height: double.infinity,
                child: path == null
                    ? ColoredBox(
                        color: colors.surfaceContainerLow,
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: colors.primary,
                        ),
                      )
                    : Image(
                        image: appraisalPhotoProvider(path!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(
                        path == null ? l10n.photoAdd : l10n.photoReplace,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: CircularProgressIndicator(),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Icon(Icons.chevron_right_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteBanner extends StatelessWidget {
  const _CompleteBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.secondary),
            const SizedBox(width: AppSpacing.small),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
