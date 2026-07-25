import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_notifier.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _OnboardingPage(
        icon: Icons.directions_car_filled_outlined,
        title: l10n.onboardingValueTitle,
        description: l10n.onboardingValueDescription,
      ),
      _OnboardingPage(
        icon: Icons.fact_check_outlined,
        title: l10n.onboardingTrackTitle,
        description: l10n.onboardingTrackDescription,
      ),
      _OnboardingPage(
        icon: Icons.trending_up_rounded,
        title: l10n.onboardingUpgradeTitle,
        description: l10n.onboardingUpgradeDescription,
      ),
    ];
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                ),
                child: TextButton(
                  onPressed: _complete,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingPageView(page: pages[index]);
                },
              ),
            ),
            _PageIndicator(
              count: pages.length,
              currentIndex: _currentPage,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLastPage
                      ? _complete
                      : () => _pageController.nextPage(
                            duration: Durations.medium4,
                            curve: Easing.standard,
                          ),
                  child: Text(
                    isLastPage ? l10n.onboardingStart : l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xLarge,
        vertical: AppSpacing.large,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xLarge),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppRadius.dialog,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxLarge),
                child: Icon(
                  page.icon,
                  size: 64,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxLarge),
            Text(
              page.title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              page.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xSmall,
          ),
          child: AnimatedContainer(
            duration: Durations.short4,
            width: index == currentIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? colorScheme.primary
                  : colorScheme.outline,
              borderRadius: AppRadius.small,
            ),
          ),
        ),
      ),
    );
  }
}
