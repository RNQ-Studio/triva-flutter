import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../body_paint/presentation/body_paint_paths.dart';
import '../../../credit/presentation/credit_paths.dart';
import '../../domain/appraisal_models.dart';
import '../appraisal_controller.dart';
import '../appraisal_paths.dart';

class AppraisalResultScreen extends ConsumerStatefulWidget {
  const AppraisalResultScreen({super.key, required this.appraisalId});

  final String appraisalId;

  @override
  ConsumerState<AppraisalResultScreen> createState() =>
      _AppraisalResultScreenState();
}

class _AppraisalResultScreenState extends ConsumerState<AppraisalResultScreen> {
  bool _busy = false;

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    context.go('/');
  }

  Future<void> _decide(String decision) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(appraisalRepositoryProvider)
          .decide(widget.appraisalId, decision);
      _finishDecision(decision);
    } catch (_) {
      // The decision may have committed before a timeout or connection loss.
      // Reconcile once before offering a retry so the customer cannot submit a
      // duplicate decision or lose the continuation page.
      try {
        final latest = await ref
            .read(appraisalRepositoryProvider)
            .getAppraisal(widget.appraisalId);
        if (latest.customerDecision == decision) {
          _finishDecision(decision);
          return;
        }
      } on Object {
        // The normal retry feedback below remains appropriate while offline.
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _finishDecision(String decision) {
    if (!mounted) return;
    ref.invalidate(appraisalsProvider);
    ref.invalidate(appraisalDetailProvider(widget.appraisalId));
    if (decision == 'deferred') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.decisionDeferredMessage),
        ),
      );
      context.go(appraisalActivityPath);
    } else {
      context.go(appraisalCompletePath(widget.appraisalId, decision));
    }
  }

  Future<void> _schedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) return;
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => _busy = true);
    try {
      await ref.read(appraisalRepositoryProvider).scheduleInspection(
            widget.appraisalId,
            scheduled,
          );
      ref.invalidate(appraisalsProvider);
      if (mounted) {
        context.go(appraisalCompletePath(widget.appraisalId, 'inspection'));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(appraisalDetailProvider(widget.appraisalId));
    return PopScope(
      canPop: !_busy && Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy && mounted) context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_busy,
          leading: _busy ? null : BackButton(onPressed: _goBack),
          title: Text(l10n.resultTitle),
        ),
        body: SafeArea(
          child: async.when(
            data: (appraisal) {
              final result = appraisal.result;
              if (result == null) {
                return Center(child: Text(l10n.loadFailed));
              }
              String? provinceName;
              final provinceId = appraisal.vehicle?.provinceId;
              if (provinceId != null) {
                for (final province
                    in ref.watch(provinceOptionsProvider).value ?? const []) {
                  if (province.id == provinceId) {
                    provinceName = province.name;
                    break;
                  }
                }
              }
              return _ResultContent(
                appraisal: appraisal,
                result: result,
                provinceName: provinceName,
                busy: _busy,
                onAccept: () => _decide('accepted'),
                onReject: () => _decide('rejected'),
                onDefer: () => _decide('deferred'),
                onSchedule: _schedule,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: OutlinedButton(
                onPressed: () => ref.invalidate(
                  appraisalDetailProvider(widget.appraisalId),
                ),
                child: Text(l10n.retry),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({
    required this.appraisal,
    required this.result,
    required this.provinceName,
    required this.busy,
    required this.onAccept,
    required this.onReject,
    required this.onDefer,
    required this.onSchedule,
  });

  final AppraisalData appraisal;
  final AppraisalResultData result;
  final String? provinceName;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDefer;
  final VoidCallback onSchedule;

  String _money(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  String _transmissionLabel(AppLocalizations l10n, String value) =>
      switch (value) {
        'automatic' => l10n.automatic,
        'manual' => l10n.manual,
        _ => value,
      };

  String _fuelLabel(AppLocalizations l10n, String value) => switch (value) {
        'gasoline' => l10n.gasoline,
        'diesel' => l10n.diesel,
        'hybrid' => l10n.hybrid,
        'electric' => l10n.electric,
        _ => value,
      };

  String _taxLabel(AppLocalizations l10n, String value) => switch (value) {
        'active' => l10n.taxActive,
        'overdue' => l10n.taxOverdue,
        'unknown' => l10n.unknown,
        _ => value,
      };

  String _answerLabel(AppLocalizations l10n, String value) => switch (value) {
        'yes' => l10n.answerYes,
        'no' => l10n.answerNo,
        'unknown' => l10n.unknown,
        _ => value,
      };

  String _serviceLabel(AppLocalizations l10n, String value) => switch (value) {
        'complete' => l10n.serviceComplete,
        'partial' => l10n.servicePartial,
        'none' => l10n.serviceNone,
        'unknown' => l10n.unknown,
        _ => value,
      };

  String _ownershipLabel(AppLocalizations l10n, String value) =>
      switch (value) {
        'first' => l10n.ownershipFirst,
        'second' => l10n.ownershipSecond,
        'more' => l10n.ownershipMore,
        'unknown' => l10n.unknown,
        _ => value,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final date = result.validUntil == null
        ? '-'
        : DateFormat('d MMMM yyyy', 'id_ID').format(result.validUntil!);
    final dataAsOf = result.dataAsOf == null
        ? '-'
        : DateFormat('d MMMM yyyy', 'id_ID').format(result.dataAsOf!);
    final vehicle = appraisal.vehicle;
    final condition = appraisal.condition;
    final continuation = appraisal.continuation;
    final continuationPath = switch (continuation?.type) {
      'credit_simulation' =>
        creditFromAppraisalPath(continuation?.appraisalId ?? appraisal.id),
      'body_paint_estimate' when continuation?.vehicleId != null =>
        bodyPaintFromAppraisalPath(
          appraisalId: continuation?.appraisalId ?? appraisal.id,
          vehicleId: continuation!.vehicleId!,
        ),
      _ => null,
    };
    final photos = [...appraisal.photos]..sort((left, right) {
        final leftIndex = appraisalPhotoAngles.indexOf(left.angle);
        final rightIndex = appraisalPhotoAngles.indexOf(right.angle);
        return (leftIndex < 0 ? appraisalPhotoAngles.length : leftIndex)
            .compareTo(
          rightIndex < 0 ? appraisalPhotoAngles.length : rightIndex,
        );
      });

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        _AppraisalHeader(
          appraisal: appraisal,
        ),
        const SizedBox(height: AppSpacing.large),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: AppRadius.large,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tradeInEstimate,
                  style: TextStyle(color: colors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.small),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${_money(result.tradeInLow)} – '
                    '${_money(result.tradeInHigh)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  l10n.validUntil(date),
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResultRow(
                  label: l10n.marketRange,
                  value:
                      '${_money(result.marketLow)} – ${_money(result.marketHigh)}',
                ),
                const Divider(height: AppSpacing.xLarge),
                _ResultRow(
                  label: l10n.confidence,
                  value: result.confidence.toUpperCase(),
                ),
                const Divider(height: AppSpacing.xLarge),
                _ResultRow(
                  label: l10n.comparableCount(result.comparableCount),
                  value: result.comparableCount.toString(),
                ),
                const Divider(height: AppSpacing.xLarge),
                _ResultRow(
                  label: l10n.marketDataAsOf,
                  value: dataAsOf,
                ),
                if (result.sources.isNotEmpty) ...[
                  const Divider(height: AppSpacing.xLarge),
                  _ResultRow(
                    label: l10n.marketDataSources,
                    value:
                        result.sources.map((source) => source.label).join(', '),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (result.adjustments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appraisalAdjustments,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: result.adjustments
                        .map(
                          (adjustment) => Chip(
                            avatar: const Icon(
                              Icons.tune,
                              size: 16,
                            ),
                            label: Text(adjustment.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        Text(
          result.disclaimer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        if (vehicle != null) ...[
          const SizedBox(height: AppSpacing.xLarge),
          _SectionCard(
            icon: Icons.badge_outlined,
            title: l10n.vehicleIdentityTitle,
            children: [
              _DetailsGrid(
                items: [
                  (l10n.vehicleMake, vehicle.make),
                  (l10n.vehicleModel, vehicle.model),
                  (l10n.vehicleVariant, vehicle.variant),
                  (l10n.vehicleYear, vehicle.year.toString()),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          _SectionCard(
            icon: Icons.directions_car_outlined,
            title: l10n.vehicleDetailsTitle,
            children: [
              _DetailsGrid(
                items: [
                  (
                    l10n.transmission,
                    _transmissionLabel(l10n, vehicle.transmission),
                  ),
                  (l10n.fuelType, _fuelLabel(l10n, vehicle.fuelType)),
                  (
                    l10n.mileage,
                    '${NumberFormat.decimalPattern('id_ID').format(vehicle.mileage)} km',
                  ),
                  (l10n.vehicleColor, vehicle.color),
                  (l10n.licensePlate, vehicle.licensePlate),
                  (l10n.province, provinceName ?? '-'),
                  (l10n.vehicleCity, vehicle.city),
                ],
              ),
            ],
          ),
        ],
        if (condition != null) ...[
          const SizedBox(height: AppSpacing.medium),
          _SectionCard(
            icon: Icons.fact_check_outlined,
            title: l10n.conditionTitle,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.vehicleConditionPercentage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Text(
                    l10n.conditionPercentageValue(
                      condition.conditionPercentage,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              ClipRRect(
                borderRadius: AppRadius.small,
                child: LinearProgressIndicator(
                  value: condition.conditionPercentage / 100,
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const Divider(height: AppSpacing.xLarge),
              _DetailsGrid(
                items: [
                  (l10n.taxStatus, _taxLabel(l10n, condition.taxStatus)),
                  (
                    l10n.floodHistory,
                    _answerLabel(l10n, condition.floodHistory),
                  ),
                  (
                    l10n.majorAccidentHistory,
                    _answerLabel(l10n, condition.majorAccidentHistory),
                  ),
                  (
                    l10n.serviceHistory,
                    _serviceLabel(l10n, condition.serviceHistory),
                  ),
                  (
                    l10n.ownership,
                    _ownershipLabel(l10n, condition.ownership),
                  ),
                ],
              ),
            ],
          ),
        ],
        if (photos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          _SectionCard(
            icon: Icons.photo_library_outlined,
            title: l10n.photosTitle,
            children: [
              _PhotoGrid(photos: photos),
            ],
          ),
        ],
        if (appraisal.resultReady) ...[
          const SizedBox(height: AppSpacing.xLarge),
          FilledButton(
            onPressed: busy ? null : onAccept,
            child: Text(l10n.acceptPrice),
          ),
          const SizedBox(height: AppSpacing.small),
          if (result.requiresPhysicalInspection) ...[
            OutlinedButton.icon(
              onPressed: busy ? null : onSchedule,
              icon: const Icon(Icons.event_available_outlined),
              label: Text(l10n.scheduleInspection),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          OutlinedButton(
            onPressed: busy ? null : onReject,
            child: Text(l10n.declinePrice),
          ),
          TextButton(
            onPressed: busy ? null : onDefer,
            child: Text(l10n.decideLater),
          ),
        ] else if (continuationPath != null) ...[
          const SizedBox(height: AppSpacing.xLarge),
          FilledButton.icon(
            onPressed: busy ? null : () => context.push(continuationPath),
            icon: Icon(
              continuation?.type == 'credit_simulation'
                  ? Icons.calculate_outlined
                  : Icons.format_paint_outlined,
            ),
            label: Text(
              continuation?.type == 'credit_simulation'
                  ? l10n.serviceCreditTitle
                  : l10n.serviceBodyPaintTitle,
            ),
          ),
        ],
      ],
    );
  }
}

class _AppraisalHeader extends StatelessWidget {
  const _AppraisalHeader({required this.appraisal});

  final AppraisalData appraisal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final vehicle = appraisal.vehicle;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehicle == null
                  ? appraisal.referenceNo
                  : '${vehicle.make} ${vehicle.model} ${vehicle.variant}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (vehicle != null) ...[
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                '${vehicle.year} · ${vehicle.licensePlate}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetadataPill(
                  icon: Icons.confirmation_number_outlined,
                  label: '${l10n.referenceNumber}: ${appraisal.referenceNo}',
                ),
                _MetadataPill(
                  icon: Icons.verified_outlined,
                  label: appraisal.statusLabel,
                  emphasized: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        emphasized ? colors.secondaryContainer : colors.surfaceContainerHighest;
    final foreground =
        emphasized ? colors.onSecondaryContainer : colors.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.small),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadius.small,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    child: Icon(
                      icon,
                      size: 20,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 320 ? 2 : 1;
        final width = columns == 2
            ? (constraints.maxWidth - AppSpacing.large) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: AppSpacing.large,
          runSpacing: AppSpacing.large,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _DetailItem(label: item.$1, value: item.$2),
              ),
          ],
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          value.isEmpty ? '-' : value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});

  final List<AppraisalPhoto> photos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.small) / 2;
        return Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final photo in photos)
              SizedBox(
                width: width,
                child: _PhotoTile(photo: photo),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});

  final AppraisalPhoto photo;

  String _label(AppLocalizations l10n) => switch (photo.angle) {
        'front' => l10n.photoFront,
        'rear' => l10n.photoRear,
        'left_side' => l10n.photoLeft,
        'right_side' => l10n.photoRight,
        'dashboard_odometer' => l10n.photoDashboard,
        _ => photo.angleLabel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final label = _label(l10n);
    final url = photo.url;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: AppRadius.medium,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: url == null || url.isEmpty
            ? null
            : () => showDialog<void>(
                  context: context,
                  builder: (_) => _PhotoViewer(url: url, label: label),
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: url == null || url.isEmpty
                  ? const Icon(Icons.image_not_supported_outlined, size: 36)
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 36,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (url != null && url.isNotEmpty)
                    Icon(
                      Icons.zoom_out_map_outlined,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(label),
        ),
        body: SafeArea(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const CircularProgressIndicator(color: Colors.white),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppSpacing.xSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
          softWrap: true,
        ),
      ],
    );
  }
}
