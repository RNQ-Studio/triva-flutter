import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../info_popup/domain/info_popup_models.dart';
import '../../info_popup/presentation/info_popup_controller.dart';
import '../../info_popup/presentation/info_popup_dialog.dart';
import 'admin_content_paths.dart';
import 'admin_content_widgets.dart';

/// Daftar popup informasi beranda di Admin Panel (revisi 6 Oktober 2026).
class AdminInfoPopupListScreen extends ConsumerWidget {
  const AdminInfoPopupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    if (user == null || !user.canManageHomeContent) {
      return AdminContentAccessDenied(title: l10n.adminInfoPopupTitle);
    }
    final popups = ref.watch(adminInfoPopupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminInfoPopupTitle),
        actions: [
          IconButton(
            tooltip: l10n.adminInfoPopupPreview,
            icon: const Icon(Icons.slideshow_outlined),
            onPressed: () => _preview(context, popups.value),
          ),
        ],
      ),
      floatingActionButton: user.canCreateHomeContent
          ? FloatingActionButton.extended(
              onPressed: () => context.push(adminInfoPopupNewPath),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminInfoPopupNew),
            )
          : null,
      body: SafeArea(
        child: AdminContentListBody<InfoPopup>(
          items: popups,
          emptyIcon: Icons.web_asset_outlined,
          emptyTitle: l10n.adminInfoPopupEmptyTitle,
          emptyDescription: l10n.adminInfoPopupEmptyDescription,
          onRefresh: () async {
            ref.invalidate(adminInfoPopupsProvider);
            try {
              await ref.read(adminInfoPopupsProvider.future);
            } on Object {
              // Keadaan gagal sudah ditampilkan oleh daftar.
            }
          },
          itemBuilder: (context, popup) => _InfoPopupTile(popup: popup),
        ),
      ),
    );
  }

  /// Pratinjau memakai dialog yang sama dengan beranda pelanggan, hanya
  /// untuk popup yang sedang tayang.
  void _preview(BuildContext context, List<InfoPopup>? popups) {
    final running = [
      for (final popup in popups ?? const <InfoPopup>[])
        if (popup.isRunning) popup,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (running.isEmpty) {
      showAdminSnackBar(
        context,
        AppLocalizations.of(context)!.adminInfoPopupPreviewEmpty,
      );
      return;
    }
    showInfoPopupDialog(context, popups: running);
  }
}

class _InfoPopupTile extends StatelessWidget {
  const _InfoPopupTile({required this.popup});

  final InfoPopup popup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final (statusLabel, live) = _status(l10n);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(adminInfoPopupEditPath(popup.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.small,
                child: SizedBox(
                  width: 56,
                  height: 70,
                  child: ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Image.network(
                      popup.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      popup.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      l10n.adminInfoPopupSummary(
                        popup.sortOrder,
                        popup.intervalHours,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    if (popup.hasButton) ...[
                      const SizedBox(height: 2),
                      Text(
                        popup.buttonLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                            ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.small),
                    AdminStatusChip(label: statusLabel, positive: live),
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

  (String, bool) _status(AppLocalizations l10n) {
    if (!popup.isActive) return (l10n.adminContentInactive, false);
    if (popup.isRunning) return (l10n.adminInfoPopupStatusRunning, true);
    final startsOn = popup.startsOn;
    final today = DateUtils.dateOnly(DateTime.now());
    if (startsOn != null && startsOn.isAfter(today)) {
      return (l10n.adminInfoPopupStatusScheduled, false);
    }
    return (l10n.adminInfoPopupStatusEnded, false);
  }
}

/// Form tambah (tanpa [id]) atau ubah popup informasi.
class AdminInfoPopupFormScreen extends ConsumerWidget {
  const AdminInfoPopupFormScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final title = id == null ? l10n.adminInfoPopupNew : l10n.adminInfoPopupEdit;
    if (user == null ||
        !user.canManageHomeContent ||
        (id == null && !user.canCreateHomeContent)) {
      return AdminContentAccessDenied(title: title);
    }

    final popups = ref.watch(adminInfoPopupsProvider);
    if (id == null) {
      final existing = popups.value ?? const <InfoPopup>[];
      final nextOrder = existing.isEmpty
          ? 1
          : existing.map((popup) => popup.sortOrder).reduce(
                    (a, b) => a > b ? a : b,
                  ) +
              1;
      return _InfoPopupForm(
        initial: null,
        initialSortOrder: nextOrder,
        canDelete: false,
      );
    }

    return popups.when(
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
            onPressed: () => ref.invalidate(adminInfoPopupsProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ),
      ),
      data: (items) {
        final popup = items.where((item) => item.id == id).firstOrNull;
        if (popup == null) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: AdminContentMessage(
              icon: Icons.search_off_rounded,
              title: l10n.adminContentNotFoundTitle,
              description: l10n.adminContentNotFoundDescription,
            ),
          );
        }
        return _InfoPopupForm(
          key: ValueKey(popup.id),
          initial: popup,
          initialSortOrder: popup.sortOrder,
          canDelete: user.canDeleteHomeContent,
        );
      },
    );
  }
}

class _InfoPopupForm extends ConsumerStatefulWidget {
  const _InfoPopupForm({
    super.key,
    required this.initial,
    required this.initialSortOrder,
    required this.canDelete,
  });

  final InfoPopup? initial;
  final int initialSortOrder;
  final bool canDelete;

  @override
  ConsumerState<_InfoPopupForm> createState() => _InfoPopupFormState();
}

class _InfoPopupFormState extends ConsumerState<_InfoPopupForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _buttonLabel;
  late final TextEditingController _buttonUrl;
  late final TextEditingController _sortOrder;
  late final TextEditingController _interval;
  late bool _active;
  DateTime? _startsOn;
  DateTime? _endsOn;
  PickedImage? _image;
  String? _imageError;
  String? _dateError;
  bool _saving = false;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _buttonLabel = TextEditingController(text: initial?.buttonLabel ?? '');
    _buttonUrl = TextEditingController(text: initial?.buttonUrl ?? '');
    _sortOrder = TextEditingController(text: '${widget.initialSortOrder}');
    _interval = TextEditingController(text: '${initial?.intervalHours ?? 24}');
    _active = initial?.isActive ?? true;
    _startsOn = initial?.startsOn;
    _endsOn = initial?.endsOn;
  }

  @override
  void dispose() {
    _title.dispose();
    _buttonLabel.dispose();
    _buttonUrl.dispose();
    _sortOrder.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await pickAdminImage();
    if (image == null || !mounted) return;
    setState(() {
      _image = image;
      _imageError = null;
    });
  }

  String? _validateButtonPair(String? value, TextEditingController other) {
    final filled = value?.trim().isNotEmpty ?? false;
    final otherFilled = other.text.trim().isNotEmpty;
    if (!filled && otherFilled) {
      return AppLocalizations.of(context)!.adminInfoPopupButtonPair;
    }
    return null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final formValid = _formKey.currentState!.validate();
    final imageMissing = _isNew && _image == null;
    final startsOn = _startsOn;
    final endsOn = _endsOn;
    final datesInvalid =
        startsOn != null && endsOn != null && endsOn.isBefore(startsOn);
    setState(() {
      _imageError = imageMissing ? l10n.adminContentImageRequired : null;
      _dateError = datesInvalid ? l10n.adminInfoPopupEndsBeforeStart : null;
    });
    if (!formValid || imageMissing || datesInvalid) return;

    setState(() => _saving = true);
    final input = InfoPopupInput(
      title: _title.text,
      buttonLabel: _buttonLabel.text,
      buttonUrl: _buttonUrl.text,
      sortOrder: int.parse(digitsOnly(_sortOrder.text)),
      intervalHours: int.parse(digitsOnly(_interval.text)),
      isActive: _active,
      startsOn: startsOn,
      endsOn: endsOn,
    );
    try {
      await ref.read(adminInfoPopupsProvider.notifier).save(
            id: widget.initial?.id,
            input: input,
            imageBytes: _image?.bytes,
            imageName: _image?.name,
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
    final popup = widget.initial!;
    if (!await confirmAdminDelete(context, popup.title) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminInfoPopupsProvider.notifier).delete(popup.id);
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
        title: Text(_isNew ? l10n.adminInfoPopupNew : l10n.adminInfoPopupEdit),
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
                label: l10n.adminInfoPopupFieldImage,
                helperText: l10n.adminInfoPopupImageHint,
                aspectRatio: 4 / 5,
                picked: _image,
                currentUrl: widget.initial?.imageUrl,
                errorText: _imageError,
                onPick: _saving ? () {} : _pickImage,
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _title,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.adminInfoPopupFieldTitle,
                  helperText: l10n.adminInfoPopupFieldTitleHint,
                  helperMaxLines: 2,
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                l10n.adminInfoPopupButtonSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _buttonLabel,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.adminInfoPopupButtonLabel,
                  hintText: l10n.adminInfoPopupButtonLabelHint,
                ),
                validator: (value) => _validateButtonPair(value, _buttonUrl),
              ),
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _buttonUrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.adminInfoPopupButtonUrl,
                  hintText: 'https://',
                  helperText: l10n.adminInfoPopupButtonUrlHint,
                ),
                validator: (value) =>
                    adminOptionalUrlValidator(l10n, value) ??
                    _validateButtonPair(value, _buttonLabel),
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
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _interval,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.adminInfoPopupInterval,
                  suffixText: l10n.adminInfoPopupIntervalSuffix,
                  helperText: l10n.adminInfoPopupIntervalHint,
                  helperMaxLines: 2,
                ),
                validator: adminIntRangeValidator(l10n, min: 1, max: 720),
              ),
              const SizedBox(height: AppSpacing.medium),
              _DateField(
                label: l10n.adminInfoPopupStartsOn,
                value: _startsOn,
                onChanged: (value) => setState(() {
                  _startsOn = value;
                  _dateError = null;
                }),
              ),
              _DateField(
                label: l10n.adminInfoPopupEndsOn,
                value: _endsOn,
                errorText: _dateError,
                onChanged: (value) => setState(() {
                  _endsOn = value;
                  _dateError = null;
                }),
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

/// Tanggal tayang opsional; kosong berarti tanpa batas.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5, 12, 31),
    );
    if (picked != null) onChanged(DateUtils.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final value = this.value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(
        errorText ??
            (value == null
                ? l10n.adminInfoPopupDateUnset
                : MaterialLocalizations.of(context).formatMediumDate(value)),
        style: errorText == null ? null : TextStyle(color: colors.error),
      ),
      trailing: value == null
          ? null
          : IconButton(
              tooltip: l10n.clear,
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.close_rounded),
            ),
      onTap: () => _pick(context),
    );
  }
}
