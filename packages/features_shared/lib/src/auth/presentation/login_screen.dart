import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../branding/triva_logo.dart';
import '../data/biometric_auth_service.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      if (!_emailController.text.contains('@')) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is! AuthAuthenticated) return;
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess?.call();
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
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
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
                      l10n.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: l10n.email),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (value) {
                        return value == null || !value.contains('@')
                            ? l10n.errorInvalidEmail
                            : null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.large),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          tooltip: l10n.password,
                        ),
                      ),
                      validator: (value) {
                        return value == null || value.length < 6
                            ? l10n.errorPasswordTooShort
                            : null;
                      },
                    ),
                    if (authState is AuthError) ...[
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        authState.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xLarge),
                    FilledButton(
                      onPressed: authState is AuthLoading ? null : _submit,
                      child: authState is AuthLoading
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.login),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    const _BiometricLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BiometricLoginButton extends ConsumerWidget {
  const _BiometricLoginButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: _isBiometricAvailableAndEnabled(ref),
      builder: (context, snapshot) {
        if (!(snapshot.data ?? false)) return const SizedBox.shrink();

        return Column(
          children: [
            const Divider(),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.loginBiometricDivider,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.small),
            IconButton.filled(
              onPressed: authState is AuthLoading
                  ? null
                  : () => ref.read(authProvider.notifier).loginWithBiometric(),
              icon: const Icon(Icons.fingerprint),
              tooltip: l10n.loginBiometricAction,
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isBiometricAvailableAndEnabled(WidgetRef ref) async {
    try {
      final service = ref.read(biometricAuthServiceProvider);
      if (!await service.isDeviceSupported()) return false;
      if (!await service.canCheckBiometrics()) return false;

      final storage = SharedPreferencesStorage();
      await storage.init();
      final enabled = await storage.read(AppConstants.keyBiometricEnabled);
      return enabled == 'true';
    } on Exception {
      return false;
    }
  }
}
