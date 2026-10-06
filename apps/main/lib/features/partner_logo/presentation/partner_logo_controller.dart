import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/partner_logo_repository.dart';
import '../domain/partner_logo_models.dart';

final partnerLogoRepositoryProvider = Provider<PartnerLogoRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PartnerLogoRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

final activePartnerLogosProvider = FutureProvider<List<PartnerLogo>>((ref) {
  return ref.watch(partnerLogoRepositoryProvider).listActive();
});

/// Daftar logo untuk Admin Panel, termasuk yang nonaktif.
class AdminPartnerLogosController extends AsyncNotifier<List<PartnerLogo>> {
  PartnerLogoRepository get _repository =>
      ref.read(partnerLogoRepositoryProvider);

  @override
  Future<List<PartnerLogo>> build() =>
      ref.watch(partnerLogoRepositoryProvider).listAll();

  /// Membuat mitra baru bila [id] kosong. Error dari server diteruskan ke
  /// pemanggil supaya pesan validasinya bisa ditampilkan di form.
  Future<void> save({
    String? id,
    required PartnerLogoInput input,
    List<int>? logoBytes,
    String? logoName,
  }) async {
    if (id == null) {
      await _repository.create(
        input,
        logoBytes: logoBytes!,
        logoName: logoName ?? 'logo.png',
      );
    } else {
      await _repository.update(
        id,
        input,
        logoBytes: logoBytes,
        logoName: logoName,
      );
    }
    _refresh();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _refresh();
  }

  void _refresh() {
    ref
      ..invalidateSelf()
      ..invalidate(activePartnerLogosProvider);
  }
}

final adminPartnerLogosProvider =
    AsyncNotifierProvider<AdminPartnerLogosController, List<PartnerLogo>>(
  AdminPartnerLogosController.new,
);
