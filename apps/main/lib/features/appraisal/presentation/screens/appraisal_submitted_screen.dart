import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../appraisal_controller.dart';
import '../appraisal_paths.dart';
import '../widgets/appraisal_flow_scaffold.dart';

class AppraisalSubmittedScreen extends ConsumerWidget {
  const AppraisalSubmittedScreen({super.key, required this.appraisalId});

  final String appraisalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(appraisalDetailProvider(appraisalId));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xLarge),
                      child: Icon(
                        Icons.check_rounded,
                        size: 56,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  Text(
                    l10n.submittedTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    l10n.submittedDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  AppraisalCard(
                    child: async.when(
                      data: (appraisal) => Column(
                        children: [
                          Text(
                            l10n.referenceNumber,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          SelectableText(
                            appraisal.referenceNo,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          Chip(label: Text(appraisal.statusLabel)),
                        ],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text(l10n.loadFailed),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          context.go(appraisalDetailPath(appraisalId)),
                      child: Text(l10n.viewProgress),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.backToHome),
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
