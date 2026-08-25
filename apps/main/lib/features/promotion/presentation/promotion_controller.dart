import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/promotion_repository.dart';
import '../domain/promotion_models.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PromotionRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final runningPromotionsProvider = FutureProvider<List<Promotion>>((ref) {
  return ref.watch(promotionRepositoryProvider).listRunning();
});

/// Mengingat periode promo yang pop-upnya sudah dilihat, supaya pelanggan
/// tidak disambut dialog yang sama tiap membuka aplikasi.
class SeenPromotionPopups {
  SeenPromotionPopups(this._storage);

  static const _key = 'seen_promotion_popups_v1';

  final StorageService _storage;

  Future<bool> hasSeen(String periodKey) async {
    final raw = await _storage.read(_key) ?? '';
    return raw.split('|').contains(periodKey);
  }

  Future<void> markSeen(String periodKey) async {
    final raw = await _storage.read(_key) ?? '';
    final keys = raw.split('|').where((value) => value.isNotEmpty).toList();
    if (keys.contains(periodKey)) return;
    keys.add(periodKey);
    // Hanya beberapa periode terakhir yang perlu diingat; sisanya sudah tidak
    // pernah tayang lagi.
    final trimmed = keys.length > 12 ? keys.sublist(keys.length - 12) : keys;
    await _storage.write(_key, trimmed.join('|'));
  }
}

final seenPromotionPopupsProvider = Provider<SeenPromotionPopups>((ref) {
  return SeenPromotionPopups(ref.watch(storageServiceProvider));
});
