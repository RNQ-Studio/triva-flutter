import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:features_shared/features_shared.dart';
import 'package:core/core.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeAsync = ref.watch(themeProvider);
    final localeAsync = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SectionHeader(l10n.appearance),
          themeAsync.when(
            data: (mode) => _ThemeTile(
              current: mode,
              onChanged: (val) =>
                  ref.read(themeProvider.notifier).setThemeMode(val),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          _SectionHeader(l10n.language),
          localeAsync.when(
            data: (locale) => _LanguageTile(
              current: locale,
              onChanged: (val) =>
                  ref.read(localeProvider.notifier).setLocale(val),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          const _SectionHeader('Keamanan'),
          const _BiometricToggleTile(),
          const Divider(),
          _SectionHeader(l10n.privacyAndAccount),
          _ExternalLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.privacyPolicySubtitle,
            path: '/privacy-policy',
          ),
          _ExternalLinkTile(
            icon: Icons.person_remove_outlined,
            title: l10n.accountDeletion,
            subtitle: l10n.accountDeletionSubtitle,
            path: '/account-deletion',
          ),
          const Divider(),
          const _AboutTile(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
        dense: true,
      );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.current, required this.onChanged});
  final ThemeMode current;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RadioGroup<ThemeMode>(
      groupValue: current,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      child: Column(
        children: ThemeMode.values
            .map((mode) => RadioListTile<ThemeMode>(
                  title: Text(switch (mode) {
                    ThemeMode.system => l10n.themeSystem,
                    ThemeMode.light => l10n.themeLight,
                    ThemeMode.dark => l10n.themeDark,
                  }),
                  value: mode,
                ))
            .toList(),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current, required this.onChanged});
  final Locale current;
  final void Function(Locale) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RadioGroup<String>(
      groupValue: current.languageCode,
      onChanged: (val) {
        if (val != null) onChanged(Locale(val));
      },
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(l10n.langIndonesia),
            value: 'id',
          ),
          RadioListTile<String>(
            title: Text(l10n.langEnglish),
            value: 'en',
          ),
        ],
      ),
    );
  }
}

class _ExternalLinkTile extends StatelessWidget {
  const _ExternalLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String path;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new_rounded, size: 20),
        onTap: () => _open(context),
      );

  Future<void> _open(BuildContext context) async {
    final apiBase = Uri.parse(AppConfig.instance.baseUrl);
    final destination = apiBase.replace(
      path: path,
      query: null,
      fragment: null,
    );
    final opened = await launchUrl(
      destination,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.openLinkError)),
      );
    }
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) => ListTile(
        title: Text(l10n.version),
        trailing: Text(snap.hasData
            ? '${snap.data!.version}+${snap.data!.buildNumber}'
            : '—'),
      ),
    );
  }
}

class _BiometricToggleTile extends StatefulWidget {
  const _BiometricToggleTile();

  @override
  State<_BiometricToggleTile> createState() => _BiometricToggleTileState();
}

class _BiometricToggleTileState extends State<_BiometricToggleTile> {
  bool _isSupported = false;
  bool _isEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    try {
      final service = BiometricAuthService();
      final supported = await service.isDeviceSupported();
      final canCheck = await service.canCheckBiometrics();

      final storage = SharedPreferencesStorage();
      await storage.init();
      final enabled = await storage.read(AppConstants.keyBiometricEnabled);

      if (mounted) {
        setState(() {
          _isSupported = supported && canCheck;
          _isEnabled = enabled == 'true';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final storage = SharedPreferencesStorage();
    await storage.init();
    await storage.write(
      AppConstants.keyBiometricEnabled,
      value.toString(),
    );
    setState(() => _isEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();
    if (!_isSupported) {
      return const ListTile(
        title: Text('Login Biometrik'),
        subtitle: Text('Tidak tersedia di perangkat ini'),
        enabled: false,
      );
    }

    return SwitchListTile(
      title: const Text('Login Biometrik'),
      subtitle: const Text('Gunakan sidik jari atau Face ID untuk masuk'),
      value: _isEnabled,
      onChanged: _toggleBiometric,
    );
  }
}
