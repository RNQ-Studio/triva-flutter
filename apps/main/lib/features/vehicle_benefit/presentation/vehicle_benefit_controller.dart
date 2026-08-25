import 'package:core/core.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vehicle_benefit_repository.dart';
import '../domain/vehicle_benefit_models.dart';

final vehicleBenefitRepositoryProvider =
    Provider<VehicleBenefitRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return VehicleBenefitRepository(
    dio: DioClient(
      storage,
      onLogout: () => ref.read(authProvider.notifier).expireSession(),
    ).dio,
  );
});

class VehicleBenefitCheckState {
  const VehicleBenefitCheckState({
    this.isChecking = false,
    this.result,
    this.error,
  });

  final bool isChecking;
  final VehicleBenefitCheckResult? result;
  final String? error;
}

class VehicleBenefitCheckController extends Notifier<VehicleBenefitCheckState> {
  @override
  VehicleBenefitCheckState build() => const VehicleBenefitCheckState();

  Future<void> check({required String vin, int? year}) async {
    state = const VehicleBenefitCheckState(isChecking: true);
    try {
      final result = await ref
          .read(vehicleBenefitRepositoryProvider)
          .check(vin: vin, year: year);
      state = VehicleBenefitCheckState(result: result);
    } on Object catch (error) {
      state = VehicleBenefitCheckState(error: error.toString());
    }
  }

  void reset() => state = const VehicleBenefitCheckState();
}

final vehicleBenefitCheckProvider =
    NotifierProvider<VehicleBenefitCheckController, VehicleBenefitCheckState>(
  VehicleBenefitCheckController.new,
);
