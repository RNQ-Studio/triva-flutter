import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/body_paint_models.dart';
import '../body_paint_controller.dart';
import '../body_paint_paths.dart';

class AdminBodyPaintQueueScreen extends ConsumerStatefulWidget {
  const AdminBodyPaintQueueScreen({super.key});

  @override
  ConsumerState<AdminBodyPaintQueueScreen> createState() =>
      _AdminBodyPaintQueueScreenState();
}

class _AdminBodyPaintQueueScreenState
    extends ConsumerState<AdminBodyPaintQueueScreen> {
  final _search = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || !auth.user.canViewAnyBodyPaintEstimates) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return Scaffold(appBar: AppBar(title: Text(l10n.bodyPaintAdminQueue)));
    }
    final items = ref.watch(adminBodyPaintEstimatesProvider);
    final options = ref.watch(adminBodyPaintOptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintAdminQueue)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.small,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l10n.bodyPaintSearch,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.small),
                options.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (value) {
                    final statuses =
                        value['statuses'] as List<dynamic>? ?? const [];
                    return SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.bodyPaintAllStatuses),
                            selected: _status == null,
                            onSelected: (_) => setState(() => _status = null),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          for (final raw in statuses)
                            if (raw is Map<String, dynamic>) ...[
                              ChoiceChip(
                                label: Text(raw['label']?.toString() ?? ''),
                                selected: _status == raw['value']?.toString(),
                                onSelected: (_) => setState(
                                  () => _status = raw['value']?.toString(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.small),
                            ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _AdminError(
                onRetry: () => ref.invalidate(adminBodyPaintEstimatesProvider),
              ),
              data: (values) {
                final term = _search.text.trim().toLowerCase();
                final filtered = values.where((item) {
                  final matchesStatus =
                      _status == null || item.status == _status;
                  final haystack =
                      '${item.referenceNo} ${item.customerName ?? ''} '
                              '${item.vehicle?.licensePlate ?? ''}'
                          .toLowerCase();
                  return matchesStatus &&
                      (term.isEmpty || haystack.contains(term));
                }).toList(growable: false);
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(adminBodyPaintEstimatesProvider.future),
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xLarge),
                              child: Text(
                                l10n.bodyPaintAdminEmpty,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.large),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.small),
                          itemBuilder: (_, index) =>
                              _AdminQueueTile(estimate: filtered[index]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminQueueTile extends StatelessWidget {
  const _AdminQueueTile({required this.estimate});

  final BodyPaintEstimate estimate;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: estimate.hasHighRiskDamage
                ? Theme.of(context).colorScheme.errorContainer
                : AppColors.accentSoft,
            child: Icon(
              estimate.hasHighRiskDamage
                  ? Icons.warning_amber_rounded
                  : Icons.format_paint_outlined,
              color: estimate.hasHighRiskDamage
                  ? Theme.of(context).colorScheme.error
                  : AppColors.accent,
            ),
          ),
          title: Text(
            estimate.customerName ?? estimate.vehicle?.displayName ?? '-',
          ),
          subtitle: Text(
            '${estimate.referenceNo} - ${estimate.statusLabel}\n'
            '${estimate.vehicle?.licensePlate ?? ''}',
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(adminBodyPaintEstimatePath(estimate.id)),
        ),
      );
}

class AdminBodyPaintEstimateScreen extends ConsumerWidget {
  const AdminBodyPaintEstimateScreen({
    required this.estimateId,
    super.key,
  });

  final String estimateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final item = ref.watch(adminBodyPaintEstimateProvider(estimateId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintFlowTitle)),
      body: SafeArea(
        child: item.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _AdminError(
            onRetry: () =>
                ref.invalidate(adminBodyPaintEstimateProvider(estimateId)),
          ),
          data: (estimate) => RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(adminBodyPaintEstimateProvider(estimateId).future),
            child: _AdminEstimateContent(estimate: estimate),
          ),
        ),
      ),
    );
  }
}

class _AdminEstimateContent extends ConsumerWidget {
  const _AdminEstimateContent({required this.estimate});

  final BodyPaintEstimate estimate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mutation = ref.watch(adminBodyPaintMutationProvider);
    final auth = ref.watch(authProvider);
    final currentUserId = auth is AuthAuthenticated ? auth.user.id : null;
    final actions =
        estimate.availableAdminActions.map((item) => item.value).toSet();
    final money = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        estimate.referenceNo,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Chip(label: Text(estimate.statusLabel)),
                  ],
                ),
                Text(
                  '${l10n.bodyPaintCustomer}: '
                  '${estimate.customerName ?? '-'}',
                ),
                Text(estimate.vehicle?.displayName ?? '-'),
                Text(estimate.vehicle?.licensePlate ?? '-'),
                Text(
                  '${l10n.bodyPaintEstimator}: '
                  '${estimate.assignedEstimatorName ?? '-'}',
                ),
              ],
            ),
          ),
        ),
        if (estimate.engineLow != null && estimate.engineHigh != null) ...[
          const SizedBox(height: AppSpacing.medium),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: Text(l10n.bodyPaintEngineEstimate),
              subtitle: Text(
                '${money.format(estimate.engineLow)} - '
                '${money.format(estimate.engineHigh)}',
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.bodyPaintDamage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        for (final damage in estimate.damages)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.small),
            child: ExpansionTile(
              leading: damage.isHighRisk
                  ? Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    )
                  : const Icon(Icons.format_paint_outlined),
              title: Text(damage.panelLabel),
              subtitle: Text('${damage.damageTypeLabel} - ${damage.severity}'),
              children: [
                for (final photo in damage.photos)
                  ListTile(
                    leading: const Icon(Icons.photo_outlined),
                    title: Text(photo.reviewStatus),
                    subtitle: photo.rejectionReason == null
                        ? null
                        : Text(photo.rejectionReason!),
                  ),
              ],
            ),
          ),
        if (mutation.hasError)
          Text(
            l10n.errorGeneral,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: AppSpacing.large),
        if (actions.contains('assign') && currentUserId != null)
          OutlinedButton.icon(
            onPressed: mutation.isLoading
                ? null
                : () => _perform(
                      context,
                      ref,
                      'assign',
                      {'estimator_id': currentUserId},
                    ),
            icon: const Icon(Icons.person_add_alt_rounded),
            label: Text(l10n.bodyPaintAssignSelf),
          ),
        if (actions.contains('start_review')) ...[
          const SizedBox(height: AppSpacing.small),
          FilledButton.icon(
            onPressed: mutation.isLoading
                ? null
                : () => _perform(context, ref, 'start_review', const {}),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(l10n.bodyPaintStartReview),
          ),
        ],
        if (actions.contains('request_photos')) ...[
          const SizedBox(height: AppSpacing.small),
          OutlinedButton.icon(
            onPressed:
                mutation.isLoading ? null : () => _requestPhotos(context, ref),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(l10n.bodyPaintRequestPhotos),
          ),
        ],
        if (actions.contains('publish')) ...[
          const SizedBox(height: AppSpacing.small),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            onPressed: mutation.isLoading
                ? null
                : () => context.push(adminBodyPaintPublishPath(estimate.id)),
            icon: const Icon(Icons.publish_rounded),
            label: Text(l10n.bodyPaintPublish),
          ),
        ],
      ],
    );
  }

  Future<void> _perform(
    BuildContext context,
    WidgetRef ref,
    String action,
    Map<String, dynamic> fields,
  ) async {
    final result = await ref
        .read(adminBodyPaintMutationProvider.notifier)
        .perform(estimate.id, action, fields);
    if (!context.mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context)!.bodyPaintAdminActionSuccess),
      ),
    );
  }

  Future<void> _requestPhotos(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bodyPaintRequestPhotos),
        content: TextField(
          controller: reason,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          decoration:
              InputDecoration(labelText: l10n.bodyPaintRequestPhotoReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, reason.text.trim().length >= 5),
            child: Text(l10n.bodyPaintRequestPhotos),
          ),
        ],
      ),
    );
    if (!context.mounted) {
      reason.dispose();
      return;
    }
    if (confirmed == true) {
      final ids = <String>[
        for (final damage in estimate.damages)
          for (final photo in damage.photos) photo.id,
        for (final photo in estimate.contextPhotos) photo.id,
      ];
      await _perform(
        context,
        ref,
        'request_photos',
        {
          'reason_code': 'photo_quality',
          'reason': reason.text.trim(),
          'rejected_photo_ids': ids,
        },
      );
    }
    reason.dispose();
  }
}

class AdminBodyPaintPublishScreen extends ConsumerStatefulWidget {
  const AdminBodyPaintPublishScreen({
    required this.estimateId,
    super.key,
  });

  final String estimateId;

  @override
  ConsumerState<AdminBodyPaintPublishScreen> createState() =>
      _AdminBodyPaintPublishScreenState();
}

class _AdminBodyPaintPublishScreenState
    extends ConsumerState<AdminBodyPaintPublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assumptions = TextEditingController();
  final _disclaimer = TextEditingController();
  final _validDays = TextEditingController(text: '14');
  final _overrideReason = TextEditingController();
  final _items = <_PublishItemDraft>[];
  var _initialized = false;

  @override
  void dispose() {
    _assumptions.dispose();
    _disclaimer.dispose();
    _validDays.dispose();
    _overrideReason.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final estimate =
        ref.watch(adminBodyPaintEstimateProvider(widget.estimateId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyPaintPublish)),
      body: SafeArea(
        child: estimate.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _AdminError(
            onRetry: () => ref.invalidate(
              adminBodyPaintEstimateProvider(widget.estimateId),
            ),
          ),
          data: (value) {
            _initialize(value, l10n);
            return _publishForm(value);
          },
        ),
      ),
    );
  }

  void _initialize(BodyPaintEstimate estimate, AppLocalizations l10n) {
    if (_initialized) return;
    final damageById = {
      for (final damage in estimate.damages) damage.id: damage,
    };
    if (estimate.engineItems.isNotEmpty) {
      for (final engine in estimate.engineItems) {
        final damage = damageById[engine.damageId];
        if (damage != null) {
          _items.add(_PublishItemDraft(damage: damage, engine: engine));
        }
      }
    } else {
      for (final damage in estimate.damages) {
        _items.add(_PublishItemDraft(damage: damage));
      }
    }
    _assumptions.text = l10n.bodyPaintPublishAssumptionDefault;
    _disclaimer.text = l10n.bodyPaintPublishDisclaimerDefault;
    _initialized = true;
  }

  Widget _publishForm(BodyPaintEstimate estimate) {
    final l10n = AppLocalizations.of(context)!;
    final mutation = ref.watch(adminBodyPaintMutationProvider);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          Text(
            l10n.bodyPaintPublishDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.large),
          for (var index = 0; index < _items.length; index++) ...[
            _PublishItemCard(item: _items[index]),
            const SizedBox(height: AppSpacing.medium),
          ],
          TextFormField(
            controller: _assumptions,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.bodyPaintAssumption),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _disclaimer,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.bodyPaintDisclaimer),
            validator: (value) =>
                (value?.trim().length ?? 0) < 20 ? l10n.errorGeneral : null,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _validDays,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.bodyPaintValidDays),
            validator: _positiveInt,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            controller: _overrideReason,
            minLines: 2,
            maxLines: 4,
            maxLength: 2000,
            decoration:
                InputDecoration(labelText: l10n.bodyPaintOverrideReason),
            validator: (value) =>
                (value?.trim().length ?? 0) < 5 ? l10n.errorGeneral : null,
          ),
          if (mutation.hasError) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.errorGeneral,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            onPressed: mutation.isLoading ? null : () => _publish(estimate),
            icon: const Icon(Icons.publish_rounded),
            label: Text(l10n.bodyPaintPublish),
          ),
        ],
      ),
    );
  }

  Future<void> _publish(BodyPaintEstimate estimate) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result =
        await ref.read(adminBodyPaintMutationProvider.notifier).perform(
      estimate.id,
      'publish',
      {
        'items': _items.map((item) => item.toJson()).toList(),
        'assumptions': _assumptions.text
            .split('\n')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),
        'disclaimer': _disclaimer.text.trim(),
        'valid_days': int.parse(_validDays.text),
        'override_reason_code': 'estimator_review',
        'override_reason': _overrideReason.text.trim(),
      },
    );
    if (!mounted || result == null) return;
    context.go(adminBodyPaintEstimatePath(estimate.id));
  }

  String? _required(String? value) => (value?.trim().isEmpty ?? true)
      ? AppLocalizations.of(context)!.errorGeneral
      : null;

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed < 1
        ? AppLocalizations.of(context)!.errorGeneral
        : null;
  }
}

class _PublishItemCard extends StatelessWidget {
  const _PublishItemCard({required this.item});

  final _PublishItemDraft item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.damage.panelLabel} - '
              '${item.damage.damageTypeLabel}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<String>(
              initialValue: item.severity,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.bodyPaintSeverity),
              items: [
                DropdownMenuItem(
                  value: 'light',
                  child: Text(l10n.bodyPaintLight),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text(l10n.bodyPaintMedium),
                ),
                DropdownMenuItem(
                  value: 'heavy',
                  child: Text(l10n.bodyPaintHeavy),
                ),
              ],
              onChanged: (value) => item.severity = value ?? 'medium',
            ),
            const SizedBox(height: AppSpacing.small),
            DropdownButtonFormField<String>(
              initialValue: item.workType,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.bodyPaintWorkType),
              items: [
                DropdownMenuItem(
                  value: 'inspect',
                  child: Text(l10n.bodyPaintInspect),
                ),
                DropdownMenuItem(
                  value: 'repair',
                  child: Text(l10n.bodyPaintRepair),
                ),
                DropdownMenuItem(
                  value: 'paint',
                  child: Text(l10n.bodyPaintPaint),
                ),
                DropdownMenuItem(
                  value: 'replace',
                  child: Text(l10n.bodyPaintReplace),
                ),
                DropdownMenuItem(
                  value: 'polish',
                  child: Text(l10n.bodyPaintPolish),
                ),
              ],
              onChanged: (value) => item.workType = value ?? 'repair',
            ),
            const SizedBox(height: AppSpacing.medium),
            _CostRow(
              label: l10n.bodyPaintLabor,
              low: item.laborLow,
              high: item.laborHigh,
            ),
            _CostRow(
              label: l10n.bodyPaintMaterial,
              low: item.materialLow,
              high: item.materialHigh,
            ),
            _CostRow(
              label: l10n.bodyPaintParts,
              low: item.partsLow,
              high: item.partsHigh,
            ),
            _CostRow(
              label: l10n.bodyPaintOther,
              low: item.otherLow,
              high: item.otherHigh,
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.minHours,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: l10n.bodyPaintMinHours),
                    validator: (value) => _positive(context, value),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: TextFormField(
                    controller: item.maxHours,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: l10n.bodyPaintMaxHours),
                    validator: (value) => _atLeast(
                      context,
                      value,
                      item.minHours,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            TextFormField(
              controller: item.recommendation,
              minLines: 1,
              maxLines: 3,
              decoration:
                  InputDecoration(labelText: l10n.bodyPaintRecommendation),
            ),
          ],
        ),
      ),
    );
  }

  String? _positive(BuildContext context, String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed < 1
        ? AppLocalizations.of(context)!.errorGeneral
        : null;
  }

  String? _atLeast(
    BuildContext context,
    String? value,
    TextEditingController minimum,
  ) {
    final parsed = int.tryParse(value ?? '');
    final minimumValue = int.tryParse(minimum.text);
    if (parsed == null ||
        minimumValue == null ||
        parsed < 1 ||
        parsed < minimumValue) {
      return AppLocalizations.of(context)!.errorGeneral;
    }
    return null;
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.low,
    required this.high,
  });

  final String label;
  final TextEditingController low;
  final TextEditingController high;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xSmall),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: low,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.bodyPaintLowCost),
                  validator: (value) => _nonNegative(context, value),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: TextFormField(
                  controller: high,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: l10n.bodyPaintHighCost),
                  validator: (value) => _highAtLeastLow(context, value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _nonNegative(BuildContext context, String? value) {
    final parsed = int.tryParse(value ?? '');
    return parsed == null || parsed < 0
        ? AppLocalizations.of(context)!.errorGeneral
        : null;
  }

  String? _highAtLeastLow(BuildContext context, String? value) {
    final parsed = int.tryParse(value ?? '');
    final lowValue = int.tryParse(low.text);
    if (parsed == null || lowValue == null || parsed < 0 || parsed < lowValue) {
      return AppLocalizations.of(context)!.errorGeneral;
    }
    return null;
  }
}

class _PublishItemDraft {
  _PublishItemDraft({
    required this.damage,
    BodyPaintEstimateItem? engine,
  })  : severity = engine?.severity == 'unsure'
            ? 'medium'
            : engine?.severity ??
                (damage.severity == 'unsure' ? 'medium' : damage.severity),
        workType = engine?.workType ?? 'repair',
        laborLow = _controller(engine?.laborLow ?? 0),
        laborHigh = _controller(engine?.laborHigh ?? 0),
        materialLow = _controller(engine?.materialLow ?? 0),
        materialHigh = _controller(engine?.materialHigh ?? 0),
        partsLow = _controller(engine?.partsLow ?? 0),
        partsHigh = _controller(engine?.partsHigh ?? 0),
        otherLow = _controller(engine?.otherLow ?? 0),
        otherHigh = _controller(engine?.otherHigh ?? 0),
        minHours = _controller(engine?.durationMinHours ?? 1),
        maxHours = _controller(engine?.durationMaxHours ?? 8),
        recommendation =
            TextEditingController(text: engine?.recommendation ?? '');

  final BodyPaintDamage damage;
  String severity;
  String workType;
  final TextEditingController laborLow;
  final TextEditingController laborHigh;
  final TextEditingController materialLow;
  final TextEditingController materialHigh;
  final TextEditingController partsLow;
  final TextEditingController partsHigh;
  final TextEditingController otherLow;
  final TextEditingController otherHigh;
  final TextEditingController minHours;
  final TextEditingController maxHours;
  final TextEditingController recommendation;

  Map<String, dynamic> toJson() => {
        'damage_id': damage.id,
        'severity': severity,
        'work_type': workType,
        'labor_low': int.parse(laborLow.text),
        'labor_high': int.parse(laborHigh.text),
        'material_low': int.parse(materialLow.text),
        'material_high': int.parse(materialHigh.text),
        'parts_low': int.parse(partsLow.text),
        'parts_high': int.parse(partsHigh.text),
        'other_low': int.parse(otherLow.text),
        'other_high': int.parse(otherHigh.text),
        'duration_min_hours': int.parse(minHours.text),
        'duration_max_hours': int.parse(maxHours.text),
        if (recommendation.text.trim().isNotEmpty)
          'recommendation': recommendation.text.trim(),
      };

  void dispose() {
    laborLow.dispose();
    laborHigh.dispose();
    materialLow.dispose();
    materialHigh.dispose();
    partsLow.dispose();
    partsHigh.dispose();
    otherLow.dispose();
    otherHigh.dispose();
    minHours.dispose();
    maxHours.dispose();
    recommendation.dispose();
  }

  static TextEditingController _controller(int value) =>
      TextEditingController(text: '$value');
}

class _AdminError extends StatelessWidget {
  const _AdminError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem_rounded, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.bodyPaintLoadFailed, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
