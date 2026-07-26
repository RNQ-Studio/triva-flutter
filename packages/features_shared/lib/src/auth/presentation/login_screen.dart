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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TrivaLogo(width: 200)),
                  const SizedBox(height: AppSpacing.xxLarge),
                  Text(
                    l10n.signIn,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    l10n.googleLoginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  const _GoogleAccountNotice(),
                  if (authState case AuthError(:final kind)) ...[
                    const SizedBox(height: AppSpacing.large),
                    _AuthErrorMessage(kind: kind),
                  ],
                  const SizedBox(height: AppSpacing.xLarge),
                  OutlinedButton.icon(
                    key: const ValueKey('google-sign-in-button'),
                    onPressed: authState is AuthLoading
                        ? null
                        : () =>
                            ref.read(authProvider.notifier).loginWithGoogle(),
                    icon: authState is AuthLoading
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const _GoogleMark(),
                    label: Text(
                      authState is AuthLoading
                          ? l10n.googleLoginLoading
                          : l10n.googleLoginAction,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    l10n.googleLoginPrivacyNotice,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
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
