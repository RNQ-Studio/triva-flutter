import 'dart:async';

import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/admin_demographics_repository.dart';
import '../data/admin_menu_usage_repository.dart';
import '../data/admin_visit_statistics_repository.dart';
import '../data/menu_usage_reporter.dart';
import '../data/visit_launch_reporter.dart';
import '../domain/demographics_models.dart';
import '../domain/menu_usage_models.dart';
import '../domain/visit_analytics_models.dart';

final visitLaunchReporterProvider = Provider<VisitLaunchReporter>(
  (_) => VisitLaunchReporter(DioClient.anonymous().dio),
);

final adminVisitStatisticsRepositoryProvider =
    Provider<AdminVisitStatisticsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AdminVisitStatisticsRepository(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final adminVisitStatisticsProvider =
    FutureProvider.autoDispose<VisitAnalyticsSnapshot>((ref) {
  return ref.watch(adminVisitStatisticsRepositoryProvider).fetch();
}, retry: (_, __) => null);

/// Kanal pelaporan analitik untuk pemasangan saat ini.
///
/// Null di luar Android dan web supaya data tetap sebanding dengan statistik
/// kunjungan yang hanya mengenal kedua kanal itu.
VisitSource? currentVisitSource() {
  if (kIsWeb) return VisitSource.web;
  return defaultTargetPlatform == TargetPlatform.android
      ? VisitSource.android
      : null;
}

final menuUsageReporterProvider = Provider<MenuUsageReporter>((ref) {
  final storage = ref.watch(storageServiceProvider);
  // Hanya produksi yang dilaporkan supaya angka dashboard tidak tercampur
  // ketukan saat pengembangan.
  final source = AppConfig.instance.environment == Environment.prod
      ? currentVisitSource()
      : null;

  return MenuUsageReporter(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
    source: source,
    appInfo: () async {
      final package = await PackageInfo.fromPlatform();
      return (version: package.version, build: package.buildNumber);
    },
  );
});

/// Mencatat menu yang dipilih tanpa menunda navigasi pemanggilnya.
void trackMenuUsage(WidgetRef ref, MenuKey menu) {
  unawaited(ref.read(menuUsageReporterProvider).track(menu));
}

final adminMenuUsageRepositoryProvider =
    Provider<AdminMenuUsageRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AdminMenuUsageRepository(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final adminMenuUsageProvider =
    FutureProvider.autoDispose<MenuUsageSnapshot>((ref) {
  return ref.watch(adminMenuUsageRepositoryProvider).fetch();
}, retry: (_, __) => null);

final adminDemographicsRepositoryProvider =
    Provider<AdminDemographicsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AdminDemographicsRepository(
    DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final adminDemographicsProvider =
    FutureProvider.autoDispose<DemographicsSnapshot>((ref) {
  return ref.watch(adminDemographicsRepositoryProvider).fetch();
}, retry: (_, __) => null);
