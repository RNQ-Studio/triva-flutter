import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppraisalFlowScaffold extends StatelessWidget {
  const AppraisalFlowScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.fallbackLocation,
    this.primaryBusy = false,
    this.secondary,
  });

  final int step;
  final String title;
  final String description;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String fallbackLocation;
  final bool primaryBusy;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    final routerCanPop =
        (router?.canPop() ?? false) || (navigator?.canPop() ?? false);
    final canHandleBack = router != null || (navigator?.canPop() ?? false);

    void goBack() {
      if (primaryBusy) return;
      if (router?.canPop() == true) {
        router!.pop();
      } else if (navigator?.canPop() == true) {
        navigator!.pop();
      } else {
        router?.go(fallbackLocation);
      }
    }

    return PopScope(
      canPop: !primaryBusy && (router == null || routerCanPop),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !primaryBusy && !routerCanPop && context.mounted) {
          router?.go(fallbackLocation);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !primaryBusy,
          leading: canHandleBack && !primaryBusy
              ? BackButton(onPressed: goBack)
              : null,
          title: Text(l10n.appraisalStep(step)),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index == 3 ? 0 : AppSpacing.xSmall,
                        ),
                        child: AnimatedContainer(
                          duration: Durations.short4,
                          height: 5,
                          decoration: BoxDecoration(
                            color: index < step
                                ? colors.primary
                                : colors.surfaceContainerHighest,
                            borderRadius: AppRadius.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    AppSpacing.medium,
                    AppSpacing.large,
                    AppSpacing.xLarge,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            description,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          body,
                          const SizedBox(height: AppSpacing.medium),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_done_outlined,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xSmall),
                              Flexible(
                                child: Text(
                                  l10n.draftSaved,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: colors.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.outlineVariant)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    AppSpacing.medium,
                    AppSpacing.large,
                    AppSpacing.large,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Row(
                        children: [
                          if (secondary != null) ...[
                            Expanded(child: secondary!),
                            const SizedBox(width: AppSpacing.medium),
                          ],
                          Expanded(
                            flex: secondary == null ? 1 : 2,
                            child: FilledButton(
                              onPressed: primaryBusy ? null : onPrimary,
                              child: primaryBusy
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(primaryLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppraisalCard extends StatelessWidget {
  const AppraisalCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: child,
      ),
    );
  }
}

class AppraisalLoading extends StatelessWidget {
  const AppraisalLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
