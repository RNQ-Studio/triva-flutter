import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';

void main() {
  test('draft round-trip keeps resume-critical identifiers and photos', () {
    const draft = AppraisalDraft(
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
      taxStatus: 'active',
      floodHistory: 'no',
      majorAccidentHistory: 'no',
      serviceHistory: 'complete',
      ownership: 'first',
      photoPaths: {'front': '/draft/front.jpg'},
      assetIds: {'front': 'asset-1'},
      vehicleId: 'vehicle-1',
      appraisalId: 'appraisal-1',
      idempotencyKey: '89a96c9f-27af-42dc-9fea-4fb7d5f08cb4',
    );

    final restored = AppraisalDraft.fromJson(draft.toJson());

    expect(restored.vehicleId, 'vehicle-1');
    expect(restored.appraisalId, 'appraisal-1');
    expect(restored.assetIds['front'], 'asset-1');
    expect(restored.idempotencyKey, draft.idempotencyKey);
  });

  test('appraisal parser exposes result and rejected photo state', () {
    final appraisal = AppraisalData.fromJson({
      'id': 'appraisal-1',
      'reference_no': 'TIA-20260726-00000001',
      'status': 'result_ready',
      'status_label': 'Hasil tersedia',
      'photos': [
        {
          'id': 'photo-1',
          'angle': 'front',
          'angle_label': 'Depan',
          'review_status': 'rejected',
          'rejection_note': 'Foto buram',
        },
      ],
      'timeline': const [],
      'result': {
        'trade_in_estimate': {'low': 168000000, 'high': 176000000},
        'market_price': {
          'low': 178000000,
          'mid': 185000000,
          'high': 192000000,
        },
        'confidence': 'medium',
        'comparable_count': 6,
        'valid_until': '2026-08-02T10:00:00+07:00',
        'requires_physical_inspection': true,
        'disclaimer': 'Indikatif.',
      },
    });

    expect(appraisal.resultReady, isTrue);
    expect(appraisal.photos.single.rejectionNote, 'Foto buram');
    expect(appraisal.result?.tradeInLow, 168000000);
    expect(appraisal.result?.comparableCount, 6);
  });
}
