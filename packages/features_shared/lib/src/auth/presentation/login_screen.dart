import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../branding/triva_logo.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is! AuthAuthenticated) return;
      if (onLoginSuccess case final callback?) {
        callback();
      } else {
        context.go('/');
      }
    });

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight < 700 ? 250 : 320,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/branding/welcome_vehicle.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: colors.primaryContainer,
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              size: 84,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.large),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: 0.94),
                                borderRadius: AppRadius.large,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.large,
                                  vertical: AppSpacing.medium,
                                ),
                                child: TrivaLogo(width: 142),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xLarge,
                          AppSpacing.xLarge,
                          AppSpacing.xLarge,
                          AppSpacing.large,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.loginHeroTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.small),
                            Text(
                              l10n.loginHeroDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: colors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            if (authState case AuthError(:final kind)) ...[
                              const SizedBox(height: AppSpacing.large),
                              _AuthErrorMessage(kind: kind),
                            ],
                            const SizedBox(height: AppSpacing.xLarge),
                            OutlinedButton.icon(
                              key: const ValueKey('google-sign-in-button'),
                              onPressed: authState is AuthLoading
                                  ? null
                                  : () => ref
                                      .read(authProvider.notifier)
                                      .loginWithGoogle(),
                              icon: authState is AuthLoading
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const _GoogleMark(),
                              label: Text(
                                authState is AuthLoading
                                    ? l10n.googleLoginLoading
                                    : l10n.googleLoginAction,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            const _GoogleAccountNotice(),
                            const SizedBox(height: AppSpacing.medium),
                            Text(
                              l10n.googleLoginPrivacyNotice,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _GoogleAccountNotice extends StatelessWidget {
  const _GoogleAccountNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.medium,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined, color: colors.secondary),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                l10n.googleLoginAccountNotice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.kind});

  final AuthFailureKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final message = switch (kind) {
      AuthFailureKind.network => l10n.googleLoginNetworkError,
      AuthFailureKind.configuration => l10n.googleLoginConfigurationError,
      AuthFailureKind.rejected => l10n.googleLoginRejectedError,
      AuthFailureKind.general => l10n.errorGeneral,
    };

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: AppRadius.medium,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colors.onErrorContainer),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onErrorContainer,
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

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Text(
        'G',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
