import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/data/appraisal_repository.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';

class _MemoryStorage implements StorageService {
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

class _RetryRepository extends AppraisalRepository {
  _RetryRepository() : super(dio: Dio(), storage: _MemoryStorage());

  AppraisalDraft? lastSaved;
  final vehicleKeys = <String>[];
  final vehicleKeyWasPersisted = <bool>[];
  final appraisalKeys = <String>[];
  final appraisalKeyWasPersisted = <bool>[];

  @override
  Future<void> saveDraft(AppraisalDraft draft) async {
    lastSaved = draft;
  }

  @override
  Future<VehicleData> createVehicle(
    VehicleData vehicle, {
    String? idempotencyKey,
  }) async {
    vehicleKeys.add(idempotencyKey!);
    vehicleKeyWasPersisted.add(
      lastSaved?.vehicleCreationIdempotencyKey == idempotencyKey,
    );
    if (vehicleKeys.length == 1) {
      throw Exception('response lost after vehicle commit');
    }
    return const VehicleData(
      id: 'vehicle-1',
      make: 'Toyota',
      model: 'Avanza',
      variant: '1.5 G',
      year: 2022,
      transmission: 'automatic',
      fuelType: 'gasoline',
      mileage: 42000,
      color: 'Putih',
      licensePlate: 'L 1234 TRV',
      city: 'Surabaya',
    );
  }

  @override
  Future<AppraisalData> createAppraisal(
    String vehicleId, {
    required String idempotencyKey,
  }) async {
    appraisalKeys.add(idempotencyKey);
    appraisalKeyWasPersisted.add(
      lastSaved?.appraisalCreationIdempotencyKey == idempotencyKey,
    );
    throw Exception('response lost after appraisal commit');
  }
}

class _SeededFlowController extends AppraisalFlowController {
  _SeededFlowController(this.draft);

  final AppraisalDraft draft;

  @override
  Future<AppraisalFlowState> build() async => AppraisalFlowState(draft: draft);
}

void main() {
  test('creation keys survive lost responses and are persisted before POST',
      () async {
    final temporary = await Directory.systemTemp.createTemp(
      'triva-appraisal-idempotency-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    final photoPaths = <String, String>{};
    for (final angle in appraisalPhotoAngles) {
      final file = File('${temporary.path}/$angle.jpg');
      await file.writeAsBytes([1, 2, 3]);
      photoPaths[angle] = file.path;
    }
    final draft = AppraisalDraft(
      makeId: 1,
      modelId: 10,
      variantId: 100,
      make: 'Toyota',
      model: 'Avanza',
      variant: '1.5 G',
      year: 2022,
      transmission: 'automatic',
      fuelType: 'gasoline',
      mileage: 42000,
      color: 'Putih',
      licensePlate: 'L 1234 TRV',
      provinceId: 35,
      cityId: 3578,
      city: 'Surabaya',
      taxStatus: 'active',
      floodHistory: 'no',
      majorAccidentHistory: 'no',
      serviceHistory: 'complete',
      ownership: 'first',
      engineCondition: 'normal',
      tyreCondition: 'normal',
      photoPaths: photoPaths,
    );
    final repository = _RetryRepository();
    final container = ProviderContainer(
      overrides: [
        appraisalRepositoryProvider.overrideWithValue(repository),
        appraisalFlowProvider.overrideWith(
          () => _SeededFlowController(draft),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(appraisalFlowProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.read(appraisalFlowProvider.future);
    final controller = container.read(appraisalFlowProvider.notifier);

    expect(await controller.submit(), isNull);
    final vehicleKey = container
        .read(appraisalFlowProvider)
        .value
        ?.draft
        .vehicleCreationIdempotencyKey;
    expect(vehicleKey, isNotNull);
    expect(repository.vehicleKeyWasPersisted, [true]);

    // Moving back through the form and saving identical normalized values must
    // not rotate the key, otherwise the retry could create an orphan duplicate.
    await controller.saveDetails(
      transmission: 'automatic',
      fuelType: 'gasoline',
      mileage: 42000,
      color: 'Putih',
      licensePlate: 'l 1234 trv',
      provinceId: 35,
      cityId: 3578,
      city: 'Surabaya',
    );
    expect(
      container
          .read(appraisalFlowProvider)
          .value
          ?.draft
          .vehicleCreationIdempotencyKey,
      vehicleKey,
    );

    expect(await controller.submit(), isNull);
    final resumed = container.read(appraisalFlowProvider).value!.draft;
    expect(repository.vehicleKeys, [vehicleKey, vehicleKey]);
    expect(repository.vehicleKeyWasPersisted, [true, true]);
    expect(resumed.vehicleId, 'vehicle-1');
    expect(resumed.appraisalCreationIdempotencyKey, isNotNull);
    expect(repository.appraisalKeys, [resumed.appraisalCreationIdempotencyKey]);
    expect(repository.appraisalKeyWasPersisted, [true]);
  });

  test('editing an uncreated vehicle rotates stale creation keys', () async {
    const draft = AppraisalDraft(
      transmission: 'automatic',
      fuelType: 'gasoline',
      mileage: 42000,
      color: 'Putih',
      licensePlate: 'L 1234 TRV',
      provinceId: 35,
      cityId: 3578,
      city: 'Surabaya',
      vehicleCreationIdempotencyKey: 'stale-vehicle-key',
      appraisalCreationIdempotencyKey: 'stale-appraisal-key',
    );
    final repository = _RetryRepository();
    final container = ProviderContainer(
      overrides: [
        appraisalRepositoryProvider.overrideWithValue(repository),
        appraisalFlowProvider.overrideWith(
          () => _SeededFlowController(draft),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(appraisalFlowProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.read(appraisalFlowProvider.future);

    await container.read(appraisalFlowProvider.notifier).saveDetails(
          transmission: 'automatic',
          fuelType: 'gasoline',
          mileage: 43000,
          color: 'Putih',
          licensePlate: 'L 1234 TRV',
          provinceId: 35,
          cityId: 3578,
          city: 'Surabaya',
        );

    final updated = container.read(appraisalFlowProvider).value!.draft;
    expect(updated.vehicleCreationIdempotencyKey, isNull);
    expect(updated.appraisalCreationIdempotencyKey, isNull);
  });
}
