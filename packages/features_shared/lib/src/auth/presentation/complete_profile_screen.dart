import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';
import 'auth_state.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  bool _serviceConsent = false;
  bool _marketingConsent = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final state = ref.read(authProvider);
    final user = state is AuthAuthenticated ? state.user : null;
    _phoneController = TextEditingController(text: user?.phone);
    _cityController = TextEditingController(text: user?.city);
    _serviceConsent = user?.serviceConsentAt != null;
    _marketingConsent = user?.marketingConsent ?? false;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_serviceConsent) {
      setState(() => _error = l10n.consentRequired);
      return;
    }

    final state = ref.read(authProvider);
    if (state is! AuthAuthenticated) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).updateUserProfile(
            name: state.user.name,
            email: state.user.email,
            phone: _phoneController.text.trim(),
            city: _cityController.text.trim(),
            serviceConsent: true,
            marketingConsent: _marketingConsent,
          );
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) setState(() => _error = l10n.profileSetupError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(authProvider);
    final user = state is AuthAuthenticated ? state.user : null;

    return Scaffold(
      appBar: AppBar(title: const Text('TRIVA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: AppRadius.large,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_pin_circle_outlined,
                              size: 36,
                              color: colors.onPrimaryContainer,
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.profileSetupTitle,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xSmall),
                                  Text(
                                    l10n.profileSetupDescription,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    Text(user?.name ?? '',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        LengthLimitingTextInputFormatter(16),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: '+628123456789',
                      ),
                      validator: (value) {
                        final normalized =
                            value?.trim().replaceFirst(RegExp(r'^\+'), '') ??
                                '';
                        if (normalized.isEmpty) return l10n.fieldRequired;
                        if (!RegExp(r'^[0-9]{9,15}$').hasMatch(normalized)) {
                          return l10n.phoneInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.addressCity],
                      decoration: InputDecoration(
                        labelText: l10n.city,
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? l10n.fieldRequired
                              : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    CheckboxListTile(
                      value: _serviceConsent,
                      onChanged: _submitting
                          ? null
                          : (value) => setState(
                                () => _serviceConsent = value ?? false,
                              ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.serviceConsentLabel),
                    ),
                    CheckboxListTile(
                      value: _marketingConsent,
                      onChanged: _submitting
                          ? null
                          : (value) => setState(
                                () => _marketingConsent = value ?? false,
                              ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.marketingConsentLabel),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveAndContinue),
                    ),
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
