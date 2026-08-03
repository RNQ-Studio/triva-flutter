import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/body_paint/data/body_paint_repository.dart';
import 'package:triva_app/features/body_paint/domain/body_paint_models.dart';
import 'package:triva_app/features/body_paint/presentation/body_paint_controller.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

class _MockDio extends Mock implements Dio {}

class _MockStorage extends Mock implements StorageService {}

class _DelayedDraftRepository extends BodyPaintRepository {
  _DelayedDraftRepository()
      : super(
          dio: _MockDio(),
          storage: _MockStorage(),
          userId: 'customer-1',
        );

  BodyPaintDraft saved = const BodyPaintDraft();

  @override
  Future<BodyPaintDraft> loadDraft() async => const BodyPaintDraft();

  @override
  Future<void> saveDraft(BodyPaintDraft draft) async {
    if (draft.notes == 'older slow value' && !draft.consent) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    saved = draft;
  }
}

void main() {
  test('notes and consent writes are serialized and merge the newest values',
      () async {
    final repository = _DelayedDraftRepository();
    final container = ProviderContainer(
      overrides: [
        bodyPaintRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(bodyPaintFlowProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.read(bodyPaintFlowProvider.future);
    final controller = container.read(bodyPaintFlowProvider.notifier);

    final older = controller.setNotes('older slow value');
    final consent = controller.setConsent(true);
    final newest = controller.setNotes('newest value');
    await Future.wait([older, consent, newest]);

    expect(repository.saved.notes, 'newest value');
    expect(repository.saved.consent, isTrue);
    expect(
        container.read(bodyPaintFlowProvider).value?.draft, repository.saved);
  });

  test('appraisal continuation persists source and preselects its vehicle',
      () async {
    final repository = _DelayedDraftRepository();
    final container = ProviderContainer(
      overrides: [
        bodyPaintRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(bodyPaintFlowProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.read(bodyPaintFlowProvider.future);
    const vehicle = ToyotaServiceVehicle(
      id: 'vehicle-1',
      make: 'Honda',
      model: 'Brio',
      variant: 'RS',
      year: 2024,
      mileage: 12000,
      licensePlate: 'L 1234 AB',
    );

    await container.read(bodyPaintFlowProvider.notifier).initializeSource(
          appraisalId: 'appraisal-1',
          vehicle: vehicle,
        );

    expect(repository.saved.sourceAppraisalId, 'appraisal-1');
    expect(repository.saved.vehicle?.id, 'vehicle-1');
  });
}
