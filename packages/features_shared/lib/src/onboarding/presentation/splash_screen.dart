import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../branding/triva_logo.dart';
import 'onboarding_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Durations.medium4,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Easing.emphasizedDecelerate,
    );
    _controller.forward();
    _navigationTimer = Timer(Durations.extralong4, _continue);
  }

  Future<void> _continue() async {
    if (!mounted) return;
    final hasOnboarded = ref.read(onboardingProvider).asData?.value ?? false;
    context.go(hasOnboarded ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TrivaLogo(width: 240),
                  const SizedBox(height: AppSpacing.xLarge),
                  Text(
                    l10n.splashTagline,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxLarge),
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
