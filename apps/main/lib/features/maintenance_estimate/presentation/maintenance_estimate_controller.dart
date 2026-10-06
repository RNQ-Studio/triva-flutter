import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/maintenance_estimate_repository.dart';
import '../data/service_package_admin_repository.dart';
import '../domain/maintenance_estimate_models.dart';

final maintenanceEstimateRepositoryProvider =
    Provider<MaintenanceEstimateRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MaintenanceEstimateRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

class MaintenanceEstimateState {
  const MaintenanceEstimateState({
    this.isLoading = false,
    this.estimate,
    this.error,
  });

  final bool isLoading;
  final MaintenanceEstimate? estimate;
  final String? error;
}

class MaintenanceEstimateController extends Notifier<MaintenanceEstimateState> {
  @override
  MaintenanceEstimateState build() => const MaintenanceEstimateState();

  Future<void> estimate({String? vehicleModel, int? mileage}) async {
    state = const MaintenanceEstimateState(isLoading: true);
    try {
      final estimate = await ref
          .read(maintenanceEstimateRepositoryProvider)
          .estimate(vehicleModel: vehicleModel, mileage: mileage);
      state = MaintenanceEstimateState(estimate: estimate);
    } on Object catch (error) {
      state = MaintenanceEstimateState(error: error.toString());
    }
  }
}

final maintenanceEstimateProvider =
    NotifierProvider<MaintenanceEstimateController, MaintenanceEstimateState>(
  MaintenanceEstimateController.new,
);

/// Model yang punya paket khusus, untuk saran isian model kendaraan. Gagal
/// dimuat cukup berarti tanpa saran; pelanggan tetap bisa mengetik bebas.
final maintenanceModelOptionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  try {
    final estimate =
        await ref.watch(maintenanceEstimateRepositoryProvider).estimate();
    return estimate.availableModels;
  } on Object {
    return const [];
  }
});

final servicePackageAdminRepositoryProvider =
    Provider<ServicePackageAdminRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ServicePackageAdminRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

/// Daftar paket servis untuk Admin Panel, termasuk yang nonaktif.
class AdminServicePackagesController
    extends AsyncNotifier<List<MaintenancePackage>> {
  ServicePackageAdminRepository get _repository =>
      ref.read(servicePackageAdminRepositoryProvider);

  @override
  Future<List<MaintenancePackage>> build() =>
      ref.watch(servicePackageAdminRepositoryProvider).listAll();

  /// Membuat paket baru bila [id] kosong. Error dari server diteruskan ke
  /// pemanggil supaya pesan validasinya bisa ditampilkan di form.
  Future<void> save({String? id, required ServicePackageInput input}) async {
    if (id == null) {
      await _repository.create(input);
    } else {
      await _repository.update(id, input);
    }
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    ref.invalidateSelf();
  }
}

final adminServicePackagesProvider = AsyncNotifierProvider<
    AdminServicePackagesController, List<MaintenancePackage>>(
  AdminServicePackagesController.new,
);
