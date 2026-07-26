import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/region_option.dart';
import 'auth_repository_provider.dart';

final provinceOptionsProvider =
    FutureProvider.autoDispose<List<ProvinceOption>>((ref) {
  return ref.watch(authRepositoryProvider).getIndonesianProvinces();
});
