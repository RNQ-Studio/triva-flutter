import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/maintenance_estimate_repository.dart';
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
