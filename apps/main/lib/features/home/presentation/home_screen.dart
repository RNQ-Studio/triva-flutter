import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../branding/partner_brands.dart';
import '../../appraisal/domain/appraisal_models.dart';
import '../../appraisal/presentation/appraisal_controller.dart';
import '../../appraisal/presentation/appraisal_paths.dart';
import '../../toyota_service/presentation/toyota_service_controller.dart';
import '../../toyota_service/presentation/toyota_service_paths.dart';
import '../../toyota_service/domain/toyota_service_models.dart';
import '../../otoxpert/presentation/otoxpert_paths.dart';
import '../../credit/presentation/credit_paths.dart';
import '../../promotion/domain/promotion_models.dart';
import '../../promotion/presentation/promotion_controller.dart';
import '../../promotion/presentation/promotion_widgets.dart';
import '../../home_banner/domain/home_banner_models.dart';
import '../../home_banner/presentation/home_banner_controller.dart';
import '../../home_banner/presentation/home_banner_slider.dart';
import '../../info_popup/domain/info_popup_models.dart';
import '../../info_popup/presentation/info_popup_controller.dart';
import '../../info_popup/presentation/info_popup_dialog.dart';
import '../../partner_logo/presentation/partner_logo_strip.dart';
import '../../body_paint/presentation/body_paint_paths.dart';
import '../../visit_analytics/domain/menu_usage_models.dart';
import '../../visit_analytics/presentation/visit_analytics_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _startupPopupsHandled = false;
  bool _showingPopup = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _recheckInfoPopups);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Popup informasi didahulukan; pop-up promo hanya muncul bila tidak ada
  /// popup informasi yang jatuh tempo, supaya pelanggan tidak disambut dua
  /// dialog bertumpuk.
  void _scheduleStartupPopups(
    AsyncValue<List<InfoPopup>> infoPopups,
    AsyncValue<List<Promotion>> promotions,
  ) {
    if (_startupPopupsHandled) return;
    if (infoPopups.isLoading || promotions.isLoading) return;
    _startupPopupsHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shown = await _showDueInfoPopups(
        infoPopups.value ?? const <InfoPopup>[],
      );
      if (shown || !mounted) return;
      await _maybeShowPromotionPopup(
        promotions.value ?? const <Promotion>[],
      );
    });
  }

  /// Jeda tayang popup dihitung dalam jam, jadi aplikasi yang lama tertahan
  /// di latar belakang juga perlu memeriksa ulang saat kembali dibuka.
  Future<void> _recheckInfoPopups() async {
    if (!_startupPopupsHandled || _showingPopup) return;
    ref.invalidate(runningInfoPopupsProvider);
    try {
      final popups = await ref.read(runningInfoPopupsProvider.future);
      if (!mounted) return;
      await _showDueInfoPopups(popups);
    } on Object {
      // Luring: diperiksa lagi pada kesempatan berikutnya.
    }
  }

  Future<bool> _showDueInfoPopups(List<InfoPopup> popups) async {
    if (_showingPopup || popups.isEmpty) return false;
    final schedule = ref.read(infoPopupScheduleProvider);
    final due = await schedule.due(popups);
    if (due.isEmpty || !mounted || !_canPresentPopup()) return false;
    _showingPopup = true;
    try {
      await schedule.markShown(due);
      if (!mounted) return false;
      await showInfoPopupDialog(context, popups: due);
      return true;
    } finally {
      _showingPopup = false;
    }
  }

  /// Beranda tetap hidup di balik tab lain dan layar yang di-push, jadi
  /// dialog hanya boleh muncul saat beranda benar-benar sedang dilihat.
  bool _canPresentPopup() {
    final route = ModalRoute.of(context);
    return (route?.isCurrent ?? true) && TickerMode.valuesOf(context).enabled;
  }

  /// Menampilkan pop-up promo unggulan sekali per periode tayang, sesuai
  /// permintaan notulensi 19 Agustus 2026 ("Update per Month").
  Future<void> _maybeShowPromotionPopup(List<Promotion> promotions) async {
    final featured = promotions.where((promo) => promo.showAsPopup).firstOrNull;
    if (featured == null) return;
    final seen = ref.read(seenPromotionPopupsProvider);
    if (await seen.hasSeen(featured.periodKey)) return;
    if (!mounted || !_canPresentPopup()) return;
    await showPromotionPopup(context, promotion: featured);
    await seen.markSeen(featured.periodKey);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final vehicles = ref.watch(toyotaServiceVehiclesProvider);
    final draft = ref.watch(appraisalFlowProvider).value?.draft;
    final startPath = appraisalResumePath(
      draft ?? const AppraisalDraft(),
    );
    final serviceDraft = ref.watch(toyotaServiceFlowProvider).value?.draft;
    ref.watch(toyotaServiceOptionsProvider);
    final promotionsValue = ref.watch(runningPromotionsProvider);
    final promotions = promotionsValue.value ?? const <Promotion>[];
    final banners =
        ref.watch(runningHomeBannersProvider).value ?? const <HomeBanner>[];
    _scheduleStartupPopups(
      ref.watch(runningInfoPopupsProvider),
      promotionsValue,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(toyotaServiceVehiclesProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        AppSpacing.medium,
                        AppSpacing.large,
                        AppSpacing.xxLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            onNotifications: () {
                              trackMenuUsage(ref, MenuKey.notification);
                              context.go('/notifications');
                            },
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          Text(
                            l10n.homeGreeting(
                              user?.name.split(' ').first ?? 'TRIVA',
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            l10n.homeGreetingSubtitle,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          if (banners.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.large),
                            HomeBannerSlider(banners: banners),
                          ],
                          if (promotions.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.large),
                            _SectionHeading(title: l10n.promoSectionTitle),
                            const SizedBox(height: AppSpacing.medium),
                            PromotionCarousel(promotions: promotions),
                          ],
                          const SizedBox(height: AppSpacing.xLarge),
                          _AppraisalHero(
                            onTap: () {
                              trackMenuUsage(ref, MenuKey.appraisal);
                              context.push(startPath);
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxLarge),
                          _SectionHeading(title: l10n.homeServicesTitle),
                          const SizedBox(height: AppSpacing.medium),
                          _ServiceList(
                            onToyotaService: () async {
                              trackMenuUsage(ref, MenuKey.toyotaService);
                              final activeDraft =
                                  serviceDraft ?? const ToyotaServiceDraft();
                              ToyotaServiceOptions? options;
                              try {
                                options = await ref.read(
                                  toyotaServiceOptionsProvider.future,
                                );
                              } on Object {
                                // A stale persisted draft may not bypass the
                                // operational selection step while offline.
                              }
                              if (!context.mounted) return;
                              context.push(
                                options == null && activeDraft.hasFulfillment
                                    ? toyotaServiceFulfillmentPath
                                    : toyotaServiceResumePath(
                                        activeDraft,
                                        options: options,
                                      ),
                              );
                            },
                            onOtoxpert: () {
                              trackMenuUsage(ref, MenuKey.otoxpert);
                              context.push(otoxpertPath);
                            },
                            onCredit: () {
                              trackMenuUsage(ref, MenuKey.credit);
                              context.push(creditPath);
                            },
                            onBodyPaint: () {
                              trackMenuUsage(ref, MenuKey.bodyPaint);
                              context.push(bodyPaintPath);
                            },
                          ),
                          const SizedBox(height: AppSpacing.xxLarge),
                          _SectionHeading(title: l10n.myVehicle),
                          const SizedBox(height: AppSpacing.medium),
                          vehicles.when(
                            data: (items) => items.isEmpty
                                ? _EmptyVehicle(
                                    onStart: () {
                                      trackMenuUsage(ref, MenuKey.appraisal);
                                      context.push(startPath);
                                    },
                                  )
                                : _LatestVehicle(vehicle: items.first),
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => _VehicleLoadError(
                              onRetry: () =>
                                  ref.invalidate(toyotaServiceVehiclesProvider),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxLarge),
                          const PartnerLogoStrip(),
                        ],
                      ),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Flexible(child: TrivaLogo(width: 122)),
        const Spacer(),
        Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pill,
            side: BorderSide(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
            color: colors.primary,
            iconSize: AppIconSize.medium,
            tooltip: AppLocalizations.of(context)!.notifications,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: AppRadius.pill,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _AppraisalHero extends StatelessWidget {
  const _AppraisalHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final onHero = AppColors.surfaceLight;
    return ClipRRect(
      borderRadius: AppRadius.xLarge,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blue800, AppColors.blue600],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -24,
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 150,
                color: onHero.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarketSourceBadge(label: l10n.homeMarketSourceBadge),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    l10n.serviceAppraisalTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    l10n.serviceAppraisalDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onHero.withValues(alpha: 0.82),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: onHero,
                      foregroundColor: colors.primary,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded,
                        size: AppIconSize.small),
                    iconAlignment: IconAlignment.end,
                    label: Text(l10n.startAppraisal),
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

/// Menandai sumber pembanding harga di hero appraisal.
class _MarketSourceBadge extends StatelessWidget {
  const _MarketSourceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.small,
          AppSpacing.medium,
          AppSpacing.small,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PartnerLogo(
              brand: PartnerBrand.olx,
              boxHeight: 18,
              boxWidth: 34,
            ),
            const SizedBox(width: AppSpacing.small),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.accentStrong,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({
    required this.onToyotaService,
    required this.onOtoxpert,
    required this.onCredit,
    required this.onBodyPaint,
  });

  final VoidCallback onToyotaService;
  final VoidCallback onOtoxpert;
  final VoidCallback onCredit;
  final VoidCallback onBodyPaint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Setiap layanan lanjutan dijalankan oleh mitra, jadi logo mitralah yang
    // menjadi penanda barisnya. Auto2000 muncul dua kali karena memang
    // mengoperasikan servis berkala sekaligus Body & Paint, dan simulasi
    // kredit membawa dua logo karena programnya berasal dari ACC maupun TAF.
    final services = <_ServiceEntry>[
      _ServiceEntry(
        brand: PartnerBrand.auto2000,
        title: l10n.serviceToyotaTitle,
        description: l10n.serviceToyotaDescription,
        onTap: onToyotaService,
      ),
      _ServiceEntry(
        brand: PartnerBrand.otoxpert,
        title: l10n.serviceOtoxpertTitle,
        description: l10n.serviceOtoxpertDescription,
        onTap: onOtoxpert,
      ),
      _ServiceEntry(
        brand: PartnerBrand.acc,
        secondaryBrand: PartnerBrand.taf,
        title: l10n.serviceCreditTitle,
        description: l10n.serviceCreditDescription,
        onTap: onCredit,
      ),
      _ServiceEntry(
        brand: PartnerBrand.auto2000,
        title: l10n.serviceBodyPaintTitle,
        description: l10n.serviceBodyPaintDescription,
        onTap: onBodyPaint,
      ),
    ];

    return Column(
      children: [
        for (final service in services) ...[
          _ServiceRow(entry: service),
          if (service != services.last)
            const SizedBox(height: AppSpacing.medium),
        ],
      ],
    );
  }
}

class _ServiceEntry {
  const _ServiceEntry({
    required this.brand,
    required this.title,
    required this.description,
    required this.onTap,
    this.secondaryBrand,
  });

  final PartnerBrand brand;

  /// Mitra kedua bila layanannya dijalankan bersama, seperti simulasi kredit
  /// yang programnya datang dari ACC dan TAF.
  final PartnerBrand? secondaryBrand;

  final String title;
  final String description;
  final VoidCallback onTap;
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.entry});

  final _ServiceEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: entry.onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              PartnerLogoPlate(
                brand: entry.brand,
                secondaryBrand: entry.secondaryBrand,
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      entry.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVehicle extends StatelessWidget {
  const _EmptyVehicle({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.garage_outlined,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.emptyVehicleTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    l10n.emptyVehicleDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  TextButton(
                    onPressed: onStart,
                    child: Text(l10n.startAppraisal),
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

class _LatestVehicle extends StatelessWidget {
  const _LatestVehicle({required this.vehicle});

  final ToyotaServiceVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.directions_car_outlined,
            color: colors.onPrimaryContainer,
          ),
        ),
        title: Text('${vehicle.make} ${vehicle.model} ${vehicle.year}'),
        subtitle: Text(
          '${vehicle.licensePlate} · ${vehicle.mileage} km',
        ),
      ),
    );
  }
}

class _VehicleLoadError extends StatelessWidget {
  const _VehicleLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.cloud_off_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(l10n.loadFailed),
        trailing: IconButton(
          onPressed: onRetry,
          tooltip: l10n.retry,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}
