import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../maintenance_estimate/domain/maintenance_estimate_models.dart';
import '../../maintenance_estimate/presentation/maintenance_estimate_controller.dart';
import 'admin_content_paths.dart';
import 'admin_content_widgets.dart';

/// Tabel budget jasa dan part paket servis T-Care per model dan kelipatan km,
/// dasar simulasi biaya servis pelanggan (revisi 6 Oktober 2026).
class AdminServicePackageListScreen extends ConsumerWidget {
  const AdminServicePackageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    if (user == null || !user.canManageServicePackages) {
      return AdminContentAccessDenied(title: l10n.adminServicePackageTitle);
    }
    final rows = ref
        .watch(adminServicePackagesProvider)
        .whenData((packages) => _groupRows(packages, l10n));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminServicePackageTitle)),
      floatingActionButton: user.canCreateServicePackages
          ? FloatingActionButton.extended(
              onPressed: () => context.push(adminServicePackageNewPath),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminServicePackageNew),
            )
          : null,
      body: SafeArea(
        child: AdminContentListBody<_PackageRow>(
          items: rows,
          emptyIcon: Icons.build_circle_outlined,
          emptyTitle: l10n.adminServicePackageEmptyTitle,
          emptyDescription: l10n.adminServicePackageEmptyDescription,
          onRefresh: () async {
            ref.invalidate(adminServicePackagesProvider);
            try {
              await ref.read(adminServicePackagesProvider.future);
            } on Object {
              // Keadaan gagal sudah ditampilkan oleh daftar.
            }
          },
          itemBuilder: (context, row) => switch (row) {
            _PackageHeader(:final label) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.small),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            _PackageItem(:final package) => _ServicePackageTile(
                package: package,
              ),
          },
        ),
      ),
    );
  }

  /// Paket untuk semua model tampil lebih dulu, lalu per model menurut abjad;
  /// di dalam grup, urut kelipatan km.
  static List<_PackageRow> _groupRows(
    List<MaintenancePackage> packages,
    AppLocalizations l10n,
  ) {
    final groups = <String?, List<MaintenancePackage>>{};
    for (final package in packages) {
      final model = package.vehicleModel?.trim();
      groups
          .putIfAbsent(model == null || model.isEmpty ? null : model, () => [])
          .add(package);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return b == null ? 0 : -1;
        if (b == null) return 1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return [
      for (final key in keys) ...[
        _PackageHeader(key ?? l10n.adminServicePackageAllModels),
        for (final package
            in groups[key]!
              ..sort((a, b) => a.kmInterval.compareTo(b.kmInterval)))
          _PackageItem(package),
      ],
    ];
  }
}

sealed class _PackageRow {
  const _PackageRow();
}

class _PackageHeader extends _PackageRow {
  const _PackageHeader(this.label);

  final String label;
}

class _PackageItem extends _PackageRow {
  const _PackageItem(this.package);

  final MaintenancePackage package;
}

class _ServicePackageTile extends StatelessWidget {
  const _ServicePackageTile({required this.package});

  final MaintenancePackage package;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(adminServicePackageEditPath(package.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adminServicePackageKm(
                        formatRupiahAmount(package.kmInterval),
                      ),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      package.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      l10n.adminServicePackageCostSummary(
                        formatAdminRupiah(package.laborCost),
                        formatAdminRupiah(package.partsCost),
                      ),
                      style: textTheme.bodySmall,
                    ),
                    if (!package.isActive || !package.isEffective) ...[
                      const SizedBox(height: AppSpacing.small),
                      AdminStatusChip(
                        label: package.isActive
                            ? l10n.adminServicePackageOutsidePeriod
                            : l10n.adminContentInactive,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                formatAdminRupiah(package.totalCost),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xSmall),
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

/// Form tambah (tanpa [id]) atau ubah paket servis.
class AdminServicePackageFormScreen extends ConsumerWidget {
  const AdminServicePackageFormScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final title =
        id == null ? l10n.adminServicePackageNew : l10n.adminServicePackageEdit;
    if (user == null ||
        !user.canManageServicePackages ||
        (id == null && !user.canCreateServicePackages)) {
      return AdminContentAccessDenied(title: title);
    }
    if (id == null) {
      return const _ServicePackageForm(initial: null, canDelete: false);
    }

    return ref.watch(adminServicePackagesProvider).when(
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
                onPressed: () => ref.invalidate(adminServicePackagesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
          ),
          data: (items) {
            final package = items.where((item) => item.id == id).firstOrNull;
            if (package == null) {
              return Scaffold(
                appBar: AppBar(title: Text(title)),
                body: AdminContentMessage(
                  icon: Icons.search_off_rounded,
                  title: l10n.adminContentNotFoundTitle,
                  description: l10n.adminContentNotFoundDescription,
                ),
              );
            }
            return _ServicePackageForm(
              key: ValueKey(package.id),
              initial: package,
              canDelete: user.canDeleteServicePackages,
            );
          },
        );
  }
}

class _ServicePackageForm extends ConsumerStatefulWidget {
  const _ServicePackageForm({
    super.key,
    required this.initial,
    required this.canDelete,
  });

  final MaintenancePackage? initial;
  final bool canDelete;

  @override
  ConsumerState<_ServicePackageForm> createState() =>
      _ServicePackageFormState();
}

class _ServicePackageFormState extends ConsumerState<_ServicePackageForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _model;
  late final TextEditingController _km;
  late final TextEditingController _labor;
  late final TextEditingController _parts;
  late final TextEditingController _name;
  late final TextEditingController _includes;
  late bool _active;
  bool _saving = false;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    String amount(int? value) => value == null ? '' : formatRupiahAmount(value);
    _model = TextEditingController(text: initial?.vehicleModel ?? '');
    _km = TextEditingController(text: amount(initial?.kmInterval));
    _labor = TextEditingController(text: amount(initial?.laborCost));
    _parts = TextEditingController(text: amount(initial?.partsCost));
    _name = TextEditingController(text: initial?.name ?? '');
    _includes = TextEditingController(
      text: initial?.includes.join('\n') ?? '',
    );
    _active = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _model.dispose();
    _km.dispose();
    _labor.dispose();
    _parts.dispose();
    _name.dispose();
    _includes.dispose();
    super.dispose();
  }

  String? Function(String?) _amountValidator(
    AppLocalizations l10n, {
    required int min,
    required int max,
  }) {
    final range = adminIntRangeValidator(l10n, min: min, max: max);
    return (value) =>
        digitsOnly(value ?? '').isEmpty ? l10n.fieldRequired : range(value);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final input = ServicePackageInput(
      vehicleModel: _model.text,
      kmInterval: rupiahValueOf(_km.text),
      laborCost: rupiahValueOf(_labor.text),
      partsCost: rupiahValueOf(_parts.text),
      name: _name.text,
      includes: _includes.text.split('\n'),
      isActive: _active,
    );
    try {
      await ref
          .read(adminServicePackagesProvider.notifier)
          .save(id: widget.initial?.id, input: input);
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
    final package = widget.initial!;
    if (!await confirmAdminDelete(context, package.name) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminServicePackagesProvider.notifier).delete(package.id);
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
        title: Text(
          _isNew ? l10n.adminServicePackageNew : l10n.adminServicePackageEdit,
        ),
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
              TextFormField(
                controller: _model,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldModel,
                  hintText: l10n.adminServicePackageAllModels,
                  helperText: l10n.adminServicePackageModelHint,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _km,
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldKm,
                  suffixText: 'km',
                  helperText: l10n.adminServicePackageKmHint,
                ),
                validator: _amountValidator(l10n, min: 1000, max: 1000000),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _labor,
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldLabor,
                  prefixText: 'Rp ',
                ),
                validator: _amountValidator(l10n, min: 0, max: 1000000000),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _parts,
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldParts,
                  prefixText: 'Rp ',
                ),
                validator: _amountValidator(l10n, min: 0, max: 1000000000),
              ),
              const SizedBox(height: AppSpacing.small),
              ListenableBuilder(
                listenable: Listenable.merge([_labor, _parts]),
                builder: (context, _) => Text(
                  l10n.adminServicePackageTotal(
                    formatAdminRupiah(
                      rupiahValueOf(_labor.text) + rupiahValueOf(_parts.text),
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _name,
                maxLength: 120,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldName,
                  helperText: l10n.adminServicePackageNameHint,
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _includes,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.adminServicePackageFieldIncludes,
                  helperText: l10n.adminServicePackageIncludesHint,
                  alignLabelWithHint: true,
                ),
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
