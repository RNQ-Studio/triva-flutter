import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_visit_statistics_repository.dart';
import '../data/visit_launch_reporter.dart';
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
