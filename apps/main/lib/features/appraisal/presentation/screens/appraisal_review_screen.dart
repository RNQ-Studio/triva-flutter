import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';
import '../widgets/appraisal_photo_preview.dart';

class AppraisalReviewScreen extends ConsumerStatefulWidget {
  const AppraisalReviewScreen({super.key});

  @override
  ConsumerState<AppraisalReviewScreen> createState() =>
      _AppraisalReviewScreenState();
}

class _AppraisalReviewScreenState extends ConsumerState<AppraisalReviewScreen> {
  bool _consent = false;
  bool? _marketing;

  Future<void> _submit() async {
    if (!_consent) return;
    await ref
        .read(appraisalFlowProvider.notifier)
        .saveMarketingConsent(_marketing ?? false);
    final appraisal = await ref.read(appraisalFlowProvider.notifier).submit();
    if (mounted && appraisal != null) {
      context.go(appraisalSubmittedPath(appraisal.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = ref.watch(appraisalFlowProvider).value;
    if (value == null) return const AppraisalLoading();
    final draft = value.draft;
    _marketing ??= draft.marketingConsent;
    final taxLabel = switch (draft.taxStatus) {
      'active' => l10n.taxActive,
      'overdue' => l10n.taxOverdue,
      _ => l10n.unknown,
    };
    final serviceLabel = switch (draft.serviceHistory) {
      'complete' => l10n.serviceComplete,
      'partial' => l10n.servicePartial,
      'none' => l10n.serviceNone,
      _ => l10n.unknown,
    };

    return AppraisalFlowScaffold(
      step: 4,
      fallbackLocation: appraisalPhotosPath,
      title: l10n.reviewTitle,
      description: l10n.reviewDescription,
      primaryLabel:
          value.isSubmitting ? l10n.submittingAppraisal : l10n.submitAppraisal,
      primaryBusy: value.isSubmitting,
      onPrimary: _consent ? _submit : null,
      body: Column(
        children: [
          _SummaryCard(
            icon: Icons.directions_car_outlined,
            title: l10n.reviewVehicle,
            value:
                '${draft.make} ${draft.model} ${draft.variant} · ${draft.year}\n'
                '${draft.transmission} · ${draft.mileage} km · ${draft.licensePlate}',
            onEdit: () => context.push(appraisalIdentityPath),
          ),
          const SizedBox(height: AppSpacing.medium),
          _SummaryCard(
            icon: Icons.fact_check_outlined,
            title: l10n.reviewCondition,
            value: '${l10n.conditionGrade}: '
                '${draft.conditionGrade.toUpperCase()}\n'
                '${l10n.taxStatus}: $taxLabel\n'
                '${l10n.serviceHistory}: $serviceLabel',
            onEdit: () => context.push(appraisalConditionPath),
          ),
          const SizedBox(height: AppSpacing.medium),
          AppraisalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.photo_library_outlined),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        '${l10n.reviewPhotos} · 5/5',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(appraisalPhotosPath),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  height: AppSpacing.xLarge * 3,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: appraisalPhotoAngles.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.small),
                    itemBuilder: (context, index) {
                      final path =
                          draft.photoPaths[appraisalPhotoAngles[index]]!;
                      return ClipRRect(
                        borderRadius: AppRadius.small,
                        child: AspectRatio(
                          aspectRatio: 1.25,
                          child: Image(
                            image: appraisalPhotoProvider(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          AppraisalCard(
            child: Column(
              children: [
                CheckboxListTile(
                  value: _consent,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.reviewConsent),
                  onChanged: value.isSubmitting
                      ? null
                      : (checked) =>
                          setState(() => _consent = checked ?? false),
                ),
                CheckboxListTile(
                  value: _marketing,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.marketingConsentLabel),
                  onChanged: value.isSubmitting
                      ? null
                      : (checked) =>
                          setState(() => _marketing = checked ?? false),
                ),
              ],
            ),
          ),
          if (value.isSubmitting) ...[
            const SizedBox(height: AppSpacing.medium),
            AppraisalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_stageLabel(l10n, value.stage)),
                  const SizedBox(height: AppSpacing.small),
                  LinearProgressIndicator(
                    value:
                        value.uploadProgress == 0 ? null : value.uploadProgress,
                  ),
                ],
              ),
            ),
          ],
          if (value.error != null) ...[
            const SizedBox(height: AppSpacing.medium),
            _ErrorBanner(message: _errorLabel(l10n, value.error!)),
          ],
        ],
      ),
    );
  }

  String _stageLabel(AppLocalizations l10n, String? stage) {
    if (stage?.startsWith('upload:') ?? false) {
      return l10n.uploadingPhoto(
        int.tryParse(stage!.split(':').last) ?? 1,
      );
    }
    return switch (stage) {
      'prepare_vehicle' => l10n.uploadPreparingVehicle,
      'create_request' => l10n.uploadCreatingRequest,
      'save_condition' => l10n.uploadSavingCondition,
      'submit' => l10n.uploadSending,
      'success' => l10n.uploadSuccess,
      _ => l10n.submittingAppraisal,
    };
  }

  String _errorLabel(AppLocalizations l10n, String error) {
    return switch (error) {
      'incomplete' => l10n.incompleteDraftError,
      'network' => l10n.submissionNetworkError,
      'auth' => l10n.submissionAuthError,
      _ => l10n.submissionGeneralError,
    };
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppraisalCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xSmall),
                Text(value),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
