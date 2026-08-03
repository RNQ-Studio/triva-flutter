import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../body_paint/presentation/body_paint_paths.dart';
import '../appraisal_paths.dart';
import '../appraisal_controller.dart';
import '../../../credit/presentation/credit_paths.dart';

class AppraisalCompleteScreen extends ConsumerWidget {
  const AppraisalCompleteScreen({
    super.key,
    required this.appraisalId,
    required this.outcome,
  });

  final String appraisalId;
  final String outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final accepted = outcome == 'accepted';
    final rejected = outcome == 'rejected';
    final inspection = outcome == 'inspection';
    final rejectedDetail =
        rejected ? ref.watch(appraisalDetailProvider(appraisalId)) : null;
    final rejectedVehicleId = rejectedDetail?.value?.vehicle?.id;
    final title = accepted
        ? l10n.decisionAcceptedTitle
        : inspection
            ? l10n.scheduleInspection
            : l10n.decisionRejectedTitle;
    final description = accepted
        ? l10n.decisionAcceptedDescription
        : inspection
            ? l10n.inspectionScheduledDescription
            : l10n.decisionRejectedDescription;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colors.secondaryContainer,
                    child: Icon(
                      inspection
                          ? Icons.event_available_outlined
                          : Icons.check_rounded,
                      size: 54,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: rejected && rejectedVehicleId == null
                          ? rejectedDetail?.hasError == true
                              ? () => ref.invalidate(
                                    appraisalDetailProvider(appraisalId),
                                  )
                              : null
                          : () => context.go(
                                accepted
                                    ? creditFromAppraisalPath(appraisalId)
                                    : rejected
                                        ? bodyPaintFromAppraisalPath(
                                            appraisalId: appraisalId,
                                            vehicleId: rejectedVehicleId!,
                                          )
                                        : '/',
                              ),
                      child: rejected &&
                              rejectedVehicleId == null &&
                              rejectedDetail?.hasError != true
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              accepted
                                  ? l10n.serviceCreditTitle
                                  : rejected
                                      ? rejectedDetail?.hasError == true
                                          ? l10n.retry
                                          : l10n.serviceBodyPaintTitle
                                      : l10n.backToHome,
                            ),
                    ),
                  ),
                  if (accepted || rejected)
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.backToHome),
                    ),
                  TextButton(
                    onPressed: () => context.go(appraisalActivityPath),
                    child: Text(l10n.activityTitle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
