import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sales_contact_repository.dart';
import '../domain/sales_contact_models.dart';

final salesContactRepositoryProvider = Provider<SalesContactRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SalesContactRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final salesDirectoryProvider = FutureProvider<SalesDirectory>((ref) {
  return ref.watch(salesContactRepositoryProvider).list();
});
