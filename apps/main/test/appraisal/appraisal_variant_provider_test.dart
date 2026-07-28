import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/data/appraisal_repository.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';

class _FailingVariantRepository extends AppraisalRepository {
  _FailingVariantRepository()
      : super(dio: Dio(), storage: _NoopStorageService());

  int attempts = 0;

  @override
  Future<List<VehicleVariantOption>> listVehicleVariants({
    required int modelId,
  }) async {
    attempts++;
    throw Exception('variant endpoint failed');
  }
}

class _NoopStorageService implements StorageService {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}
}

void main() {
  test('variant load failure is exposed without automatic request retries',
      () async {
    final repository = _FailingVariantRepository();
    final container = ProviderContainer(
      overrides: [
        appraisalRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final provider = vehicleVariantsProvider(289);
    final subscription = container.listen(
      provider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(repository.attempts, 1);
    expect(container.read(provider).hasError, isTrue);
  });
}
