import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_guard.dart';
import 'auth_provider.dart';
import 'auth_state.dart';
import '../domain/entities/region_option.dart';
import '../domain/entities/user.dart';
import 'region_provider.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final _phoneFocusNode = FocusNode();
  final _provinceFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _genderFocusNode = FocusNode();
  int? _selectedProvinceId;
  int? _selectedCityId;
  Gender? _selectedGender;
  DateTime? _birthDate;
  bool _birthDateTouched = false;
  bool _serviceConsent = false;
  bool _marketingConsent = false;
  bool _submitting = false;
  String? _error;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final state = ref.read(authProvider);
    final user = state is AuthAuthenticated ? state.user : null;
    _phoneController = TextEditingController(text: user?.phone);
    _selectedGender = user?.gender;
    _birthDate = user?.birthDate;
    _serviceConsent = user?.serviceConsentAt != null;
    _marketingConsent = user?.marketingConsent ?? false;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _provinceFocusNode.dispose();
    _cityFocusNode.dispose();
    _genderFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _error = null;
      _birthDateTouched = true;
    });
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _birthDate == null) {
      setState(
        () => _autovalidateMode = AutovalidateMode.onUserInteraction,
      );
      if (_validatePhone(_phoneController.text) != null) {
        _phoneFocusNode.requestFocus();
      } else if (_selectedProvinceId == null) {
        _provinceFocusNode.requestFocus();
      } else if (_selectedCityId == null) {
        _cityFocusNode.requestFocus();
      } else if (_selectedGender == null) {
        _genderFocusNode.requestFocus();
      }
      return;
    }
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
            provinceId: _selectedProvinceId,
            cityId: _selectedCityId,
            gender: _selectedGender,
            birthDate: _birthDate,
            serviceConsent: true,
            marketingConsent: _marketingConsent,
          );
      if (mounted) {
        context.go(safeAuthReturnLocation(widget.returnTo) ?? '/');
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.profileSetupError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    // Batasnya menyamai validasi server: minimal 17 tahun, maksimal 100 tahun.
    final latest = DateTime(now.year - 17, now.month, now.day);
    final earliest = DateTime(now.year - 100, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: earliest,
      lastDate: latest,
      helpText: AppLocalizations.of(context)!.birthDate,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = DateTime(picked.year, picked.month, picked.day);
      _birthDateTouched = true;
    });
  }

  String? _validatePhone(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = value?.trim().replaceFirst(RegExp(r'^\+'), '') ?? '';
    if (normalized.isEmpty) return l10n.fieldRequired;
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(normalized)) {
      return l10n.phoneInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(authProvider);
    final provinces = ref.watch(provinceOptionsProvider);
    final user = state is AuthAuthenticated ? state.user : null;
    final regionOptionsReady = provinces.asData?.value.isNotEmpty ?? false;

    final screen = Scaffold(
      appBar: AppBar(title: const Text('TRIVA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
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
                      focusNode: _phoneFocusNode,
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
                      validator: _validatePhone,
                      onEditingComplete: _provinceFocusNode.requestFocus,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _RegionFields(
                      provinces: provinces,
                      selectedProvinceId: _selectedProvinceId,
                      selectedCityId: _selectedCityId,
                      provinceFocusNode: _provinceFocusNode,
                      cityFocusNode: _cityFocusNode,
                      onProvinceChanged: (value) {
                        setState(() {
                          _selectedProvinceId = value;
                          _selectedCityId = null;
                        });
                      },
                      onCityChanged: (value) {
                        setState(() => _selectedCityId = value);
                      },
                      onRetry: () => ref.invalidate(provinceOptionsProvider),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    DropdownButtonFormField<Gender>(
                      key: const ValueKey('profile-gender-field'),
                      initialValue: _selectedGender,
                      focusNode: _genderFocusNode,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.gender,
                        prefixIcon: const Icon(Icons.wc_outlined),
                      ),
                      hint: Text(l10n.chooseGender),
                      items: [
                        for (final gender in Gender.values)
                          DropdownMenuItem(
                            value: gender,
                            child: Text(genderLabel(l10n, gender)),
                          ),
                      ],
                      onChanged: _submitting
                          ? null
                          : (value) => setState(() => _selectedGender = value),
                      validator: (value) =>
                          value == null ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _BirthDateField(
                      value: _birthDate,
                      errorText: _birthDateTouched && _birthDate == null
                          ? l10n.fieldRequired
                          : null,
                      onTap: _submitting ? null : _pickBirthDate,
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
                      onPressed:
                          _submitting || !regionOptionsReady ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: AppSpacing.xLarge,
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

    return PopScope(
      // Profile setup is mandatory. Consuming back here also preserves the
      // original `from` destination until setup succeeds.
      canPop: false,
      child: screen,
    );
  }
}

class _RegionFields extends StatelessWidget {
  const _RegionFields({
    required this.provinces,
    required this.selectedProvinceId,
    required this.selectedCityId,
    required this.provinceFocusNode,
    required this.cityFocusNode,
    required this.onProvinceChanged,
    required this.onCityChanged,
    required this.onRetry,
  });

  final AsyncValue<List<ProvinceOption>> provinces;
  final int? selectedProvinceId;
  final int? selectedCityId;
  final FocusNode provinceFocusNode;
  final FocusNode cityFocusNode;
  final ValueChanged<int?> onProvinceChanged;
  final ValueChanged<int?> onCityChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return provinces.when(
      loading: () => const _RegionLoadingFields(),
      error: (_, __) => _RegionUnavailable(
        message: l10n.regionLoadError,
        onRetry: onRetry,
      ),
      data: (items) {
        if (items.isEmpty) {
          return _RegionUnavailable(
            message: l10n.regionEmpty,
            onRetry: onRetry,
          );
        }

        ProvinceOption? selectedProvince;
        for (final province in items) {
          if (province.id == selectedProvinceId) {
            selectedProvince = province;
            break;
          }
        }
        final cities = selectedProvince?.cities ?? const <CityOption>[];

        return Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedProvinceId,
              focusNode: provinceFocusNode,
              isExpanded: true,
              menuMaxHeight: 320,
              decoration: InputDecoration(
                labelText: l10n.province,
                prefixIcon: const Icon(Icons.map_outlined),
              ),
              hint: Text(l10n.chooseProvince),
              items: [
                for (final province in items)
                  DropdownMenuItem(
                    value: province.id,
                    child: Text(
                      province.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: onProvinceChanged,
              validator: (value) => value == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<int>(
              key: ValueKey(selectedProvinceId),
              initialValue: selectedCityId,
              focusNode: cityFocusNode,
              isExpanded: true,
              menuMaxHeight: 320,
              decoration: InputDecoration(
                labelText: l10n.cityOrRegency,
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
              hint: Text(
                selectedProvinceId == null
                    ? l10n.chooseProvinceFirst
                    : l10n.chooseCity,
              ),
              items: [
                for (final city in cities)
                  DropdownMenuItem(
                    value: city.id,
                    child: Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: selectedProvinceId == null || cities.isEmpty
                  ? null
                  : onCityChanged,
              validator: (value) => value == null ? l10n.fieldRequired : null,
            ),
          ],
        );
      },
    );
  }
}

class _RegionLoadingFields extends StatelessWidget {
  const _RegionLoadingFields();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          semanticsLabel: l10n.regionLoading,
        ),
        const SizedBox(height: AppSpacing.small),
        DropdownButtonFormField<int>(
          isExpanded: true,
          items: const [],
          onChanged: null,
          decoration: InputDecoration(
            labelText: l10n.province,
            prefixIcon: const Icon(Icons.map_outlined),
          ),
          hint: Text(
            l10n.regionLoading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        DropdownButtonFormField<int>(
          isExpanded: true,
          items: const [],
          onChanged: null,
          decoration: InputDecoration(
            labelText: l10n.cityOrRegency,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
          hint: Text(
            l10n.chooseProvinceFirst,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RegionUnavailable extends StatelessWidget {
  const _RegionUnavailable({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

String genderLabel(AppLocalizations l10n, Gender gender) => switch (gender) {
      Gender.male => l10n.genderMale,
      Gender.female => l10n.genderFemale,
      Gender.undisclosed => l10n.genderUndisclosed,
    };

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.value,
    required this.errorText,
    required this.onTap,
  });

  final DateTime? value;
  final String? errorText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: const ValueKey('profile-birth-date-field'),
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.birthDate,
          prefixIcon: const Icon(Icons.cake_outlined),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          errorText: errorText,
        ),
        child: Text(
          value == null ? l10n.chooseBirthDate : AppDateUtils.format(value!),
          style: value == null
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
              : Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
