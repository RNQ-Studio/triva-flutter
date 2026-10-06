import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../partner_logo/domain/partner_logo_models.dart';
import '../../partner_logo/presentation/partner_logo_controller.dart';
import 'admin_content_paths.dart';
import 'admin_content_widgets.dart';

/// Daftar logo Mitra resmi beranda di Admin Panel (revisi 6 Oktober 2026).
class AdminPartnerLogoListScreen extends ConsumerWidget {
  const AdminPartnerLogoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    if (user == null || !user.canManageHomeContent) {
      return AdminContentAccessDenied(title: l10n.adminPartnerLogoTitle);
    }
    final logos = ref.watch(adminPartnerLogosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPartnerLogoTitle)),
      floatingActionButton: user.canCreateHomeContent
          ? FloatingActionButton.extended(
              onPressed: () => context.push(adminPartnerLogoNewPath),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminPartnerLogoNew),
            )
          : null,
      body: SafeArea(
        child: AdminContentListBody<PartnerLogo>(
          items: logos,
          emptyIcon: Icons.handshake_outlined,
          emptyTitle: l10n.adminPartnerLogoEmptyTitle,
          emptyDescription: l10n.adminPartnerLogoEmptyDescription,
          onRefresh: () async {
            ref.invalidate(adminPartnerLogosProvider);
            try {
              await ref.read(adminPartnerLogosProvider.future);
            } on Object {
              // Keadaan gagal sudah ditampilkan oleh daftar.
            }
          },
          itemBuilder: (context, logo) => _PartnerLogoTile(logo: logo),
        ),
      ),
    );
  }
}

class _PartnerLogoTile extends StatelessWidget {
  const _PartnerLogoTile({required this.logo});

  final PartnerLogo logo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(adminPartnerLogoEditPath(logo.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              _LogoThumbnail(url: logo.logoUrl),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      logo.linkUrl ?? l10n.adminPartnerLogoNoLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: logo.hasLink
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.xSmall,
                      children: [
                        AdminStatusChip(
                          label: l10n.adminContentOrderSummary(logo.sortOrder),
                        ),
                        AdminStatusChip(
                          label: logo.isActive
                              ? l10n.adminContentActive
                              : l10n.adminContentInactive,
                          positive: logo.isActive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo berwarna asli selalu berdudukan putih, sama seperti di beranda.
class _LogoThumbnail extends StatelessWidget {
  const _LogoThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.hairlineLight),
      ),
      child: SizedBox(
        width: 72,
        height: 46,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Form tambah (tanpa [id]) atau ubah logo mitra.
class AdminPartnerLogoFormScreen extends ConsumerWidget {
  const AdminPartnerLogoFormScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final title =
        id == null ? l10n.adminPartnerLogoNew : l10n.adminPartnerLogoEdit;
    if (user == null ||
        !user.canManageHomeContent ||
        (id == null && !user.canCreateHomeContent)) {
      return AdminContentAccessDenied(title: title);
    }

    final logos = ref.watch(adminPartnerLogosProvider);
    if (id == null) {
      final existing = logos.value ?? const <PartnerLogo>[];
      final nextOrder = existing.isEmpty
          ? 1
          : existing.map((logo) => logo.sortOrder).reduce(
                    (a, b) => a > b ? a : b,
                  ) +
              1;
      return _PartnerLogoForm(
        initial: null,
        initialSortOrder: nextOrder,
        canDelete: false,
      );
    }

    return logos.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: AdminContentMessage(
          icon: Icons.error_outline_rounded,
          title: l10n.loadFailed,
          description: l10n.errorGeneral,
          action: OutlinedButton.icon(
            onPressed: () => ref.invalidate(adminPartnerLogosProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ),
      ),
      data: (items) {
        final logo = items.where((item) => item.id == id).firstOrNull;
        if (logo == null) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: AdminContentMessage(
              icon: Icons.search_off_rounded,
              title: l10n.adminContentNotFoundTitle,
              description: l10n.adminContentNotFoundDescription,
            ),
          );
        }
        return _PartnerLogoForm(
          key: ValueKey(logo.id),
          initial: logo,
          initialSortOrder: logo.sortOrder,
          canDelete: user.canDeleteHomeContent,
        );
      },
    );
  }
}

class _PartnerLogoForm extends ConsumerStatefulWidget {
  const _PartnerLogoForm({
    super.key,
    required this.initial,
    required this.initialSortOrder,
    required this.canDelete,
  });

  final PartnerLogo? initial;
  final int initialSortOrder;
  final bool canDelete;

  @override
  ConsumerState<_PartnerLogoForm> createState() => _PartnerLogoFormState();
}

class _PartnerLogoFormState extends ConsumerState<_PartnerLogoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _linkUrl;
  late final TextEditingController _sortOrder;
  late bool _active;
  PickedImage? _logo;
  String? _logoError;
  bool _saving = false;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _linkUrl = TextEditingController(text: initial?.linkUrl ?? '');
    _sortOrder = TextEditingController(text: '${widget.initialSortOrder}');
    _active = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _linkUrl.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final logo = await pickAdminImage(compress: false);
    if (logo == null || !mounted) return;
    setState(() {
      _logo = logo;
      _logoError = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final formValid = _formKey.currentState!.validate();
    final logoMissing = _isNew && _logo == null;
    setState(() {
      _logoError = logoMissing ? l10n.adminContentImageRequired : null;
    });
    if (!formValid || logoMissing) return;

    setState(() => _saving = true);
    final input = PartnerLogoInput(
      name: _name.text,
      linkUrl: _linkUrl.text,
      sortOrder: int.parse(digitsOnly(_sortOrder.text)),
      isActive: _active,
    );
    try {
      await ref.read(adminPartnerLogosProvider.notifier).save(
            id: widget.initial?.id,
            input: input,
            logoBytes: _logo?.bytes,
            logoName: _logo?.name,
          );
      if (!mounted) return;
      showAdminSnackBar(context, l10n.adminContentSaved);
      context.pop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAdminSnackBar(context, adminContentErrorMessage(l10n, error));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final logo = widget.initial!;
    if (!await confirmAdminDelete(context, logo.name) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminPartnerLogosProvider.notifier).delete(logo.id);
      if (!mounted) return;
      showAdminSnackBar(context, l10n.adminContentDeleted);
      context.pop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAdminSnackBar(context, adminContentErrorMessage(l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isNew ? l10n.adminPartnerLogoNew : l10n.adminPartnerLogoEdit),
        actions: [
          if (!_isNew && widget.canDelete)
            IconButton(
              tooltip: l10n.adminContentDelete,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              AdminImageField(
                label: l10n.adminPartnerLogoFieldLogo,
                helperText: l10n.adminPartnerLogoLogoHint,
                aspectRatio: 72 / 46,
                picked: _logo,
                currentUrl: widget.initial?.logoUrl,
                errorText: _logoError,
                lightBackground: true,
                onPick: _saving ? () {} : _pickLogo,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _name,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.adminPartnerLogoFieldName,
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _linkUrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.adminPartnerLogoFieldUrl,
                  hintText: 'https://',
                  helperText: l10n.adminPartnerLogoUrlHint,
                ),
                validator: (value) => adminOptionalUrlValidator(l10n, value),
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _sortOrder,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.adminContentSortOrder,
                  helperText: l10n.adminContentSortOrderHint,
                ),
                validator: adminIntRangeValidator(l10n, min: 0, max: 9999),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(l10n.adminContentActive),
                subtitle: Text(l10n.adminContentActiveHint),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: AppIconSize.medium,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
