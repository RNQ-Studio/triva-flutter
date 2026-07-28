import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';

class AppraisalDetailScreen extends ConsumerStatefulWidget {
  const AppraisalDetailScreen({super.key, required this.appraisalId});

  final String appraisalId;

  @override
  ConsumerState<AppraisalDetailScreen> createState() =>
      _AppraisalDetailScreenState();
}

class _AppraisalDetailScreenState extends ConsumerState<AppraisalDetailScreen> {
  bool _busy = false;

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    context.go('/');
  }

  Future<void> _replace(AppraisalPhoto photo) async {
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
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 2200,
      );
      if (image == null) return;
      setState(() => _busy = true);
      await ref.read(appraisalRepositoryProvider).replaceRejectedPhoto(
            appraisalId: widget.appraisalId,
            angle: photo.angle,
            filePath: image.path,
          );
      ref.invalidate(appraisalDetailProvider(widget.appraisalId));
      ref.invalidate(appraisalsProvider);
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photoPermissionError)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resubmit() async {
    setState(() => _busy = true);
    try {
      await ref.read(appraisalRepositoryProvider).resubmit(widget.appraisalId);
      ref.invalidate(appraisalDetailProvider(widget.appraisalId));
      ref.invalidate(appraisalsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(appraisalDetailProvider(widget.appraisalId));
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _goBack),
          title: Text(l10n.appraisalProgressTitle),
          actions: [
            IconButton(
              onPressed: () =>
                  ref.invalidate(appraisalDetailProvider(widget.appraisalId)),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l10n.refresh,
            ),
          ],
        ),
        body: SafeArea(
          child: async.when(
            data: (appraisal) => _DetailContent(
              appraisal: appraisal,
              busy: _busy,
              onReplace: _replace,
              onResubmit: _resubmit,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: OutlinedButton(
                onPressed: () => ref.invalidate(
                  appraisalDetailProvider(widget.appraisalId),
                ),
                child: Text(l10n.retry),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.appraisal,
    required this.busy,
    required this.onReplace,
    required this.onResubmit,
  });

  final AppraisalData appraisal;
  final bool busy;
  final ValueChanged<AppraisalPhoto> onReplace;
  final VoidCallback onResubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final rejected = appraisal.photos
        .where((photo) => photo.reviewStatus == 'rejected')
        .toList(growable: false);
    final needsAction = appraisal.needsAction;
    final processingFailed = appraisal.processingFailed;
    final resultReady = appraisal.resultReady;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: needsAction || processingFailed
                ? colors.errorContainer
                : colors.primaryContainer,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  needsAction
                      ? Icons.camera_alt_outlined
                      : processingFailed
                          ? Icons.error_outline_rounded
                          : resultReady
                              ? Icons.check_circle_outline_rounded
                              : Icons.manage_search_outlined,
                  size: 36,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  needsAction
                      ? l10n.needsActionTitle
                      : processingFailed
                          ? l10n.processingFailedTitle
                          : resultReady
                              ? l10n.resultTitle
                              : l10n.underReviewTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  needsAction
                      ? l10n.needsActionDescription
                      : processingFailed
                          ? l10n.processingFailedDescription
                          : resultReady
                              ? l10n.processResultDescription
                              : l10n.underReviewDescription,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          appraisal.referenceNo,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          appraisal.vehicle == null
              ? ''
              : '${appraisal.vehicle!.make} ${appraisal.vehicle!.model} '
                  '${appraisal.vehicle!.variant} · ${appraisal.vehicle!.year}',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        if (needsAction) ...[
          const SizedBox(height: AppSpacing.large),
          for (final photo in rejected) ...[
            _RejectedPhotoCard(
              photo: photo,
              busy: busy,
              onReplace: () => onReplace(photo),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (rejected.isEmpty)
            FilledButton.icon(
              onPressed: busy ? null : onResubmit,
              icon: const Icon(Icons.send_outlined),
              label: Text(l10n.sendReplacement),
            ),
        ],
        if (appraisal.resultReady) ...[
          const SizedBox(height: AppSpacing.large),
          FilledButton(
            onPressed: () => context.push(appraisalResultPath(appraisal.id)),
            child: Text(l10n.resultTitle),
          ),
        ],
        const SizedBox(height: AppSpacing.xLarge),
        Text(
          l10n.appraisalProgressTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        for (var index = 0; index < appraisal.timeline.length; index++)
          _TimelineItem(
            item: appraisal.timeline[index],
            isLast: index == appraisal.timeline.length - 1,
          ),
      ],
    );
  }
}

class _RejectedPhotoCard extends StatelessWidget {
  const _RejectedPhotoCard({
    required this.photo,
    required this.busy,
    required this.onReplace,
  });

  final AppraisalPhoto photo;
  final bool busy;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photo.url != null)
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: Image.network(
                  photo.url!,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(height: 80, child: Icon(Icons.image)),
                ),
              ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              photo.angleLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text(photo.rejectionNote ?? l10n.needsActionDescription),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: busy ? null : onReplace,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(l10n.photoReplace),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item, required this.isLast});

  final AppraisalTimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(Icons.check_circle, color: colors.secondary, size: 20),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: colors.outlineVariant),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      item.description!,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
