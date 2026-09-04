import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_banner_repository.dart';
import '../domain/home_banner_models.dart';

final homeBannerRepositoryProvider = Provider<HomeBannerRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HomeBannerRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final runningHomeBannersProvider = FutureProvider<List<HomeBanner>>((ref) {
  return ref.watch(homeBannerRepositoryProvider).listRunning();
});
