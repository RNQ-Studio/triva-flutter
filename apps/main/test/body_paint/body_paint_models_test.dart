import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/body_paint/domain/body_paint_models.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

void main() {
  test('published estimate parses immutable result and customer actions', () {
    final estimate = BodyPaintEstimate.fromJson({
      'id': 'estimate-1',
      'reference_no': 'BP-001',
      'status': 'estimate_ready',
      'status_label': 'Estimasi siap',
      'allowed_customer_actions': ['accept', 'decline'],
      'requires_physical_inspection': true,
      'damages': [
        {
          'id': 'damage-1',
          'panel_code': 'hood',
          'panel_label': 'Kap mesin',
          'damage_type': 'dent',
          'damage_type_label': 'Penyok',
          'customer_severity': 'medium',
          'is_high_risk': false,
          'photos': <Map<String, dynamic>>[],
        },
      ],
      'context_photos': <Map<String, dynamic>>[],
      'timeline': <Map<String, dynamic>>[],
      'estimate': {
        'version': 2,
        'low': 1500000,
        'high': 2100000,
        'duration': {'min_days': 2, 'max_days': 3},
        'assumptions': ['Tidak ada kerusakan struktur.'],
        'disclaimer': 'Nilai final mengikuti inspeksi fisik kendaraan.',
        'valid_until': '2026-08-14T00:00:00Z',
        'items': [
          {
            'damage_id': 'damage-1',
            'panel_code': 'hood',
            'panel_label': 'Kap mesin',
            'damage_type': 'dent',
            'severity': 'medium',
            'work_type': 'repair',
            'work_type_label': 'Perbaikan panel',
            'cost': {
              'labor_low': 500000,
              'labor_high': 700000,
              'material_low': 1000000,
              'material_high': 1400000,
              'parts_low': 0,
              'parts_high': 0,
              'other_low': 0,
              'other_high': 0,
              'total_low': 1500000,
              'total_high': 2100000,
            },
            'duration_min_hours': 8,
            'duration_max_hours': 16,
          },
        ],
      },
    });

    expect(estimate.allows('accept'), isTrue);
    expect(estimate.result?.version, 2);
    expect(estimate.result?.items.single.totalHigh, 2100000);
    expect(estimate.result?.items.single.laborLow, 500000);
    expect(estimate.requiresPhysicalInspection, isTrue);
  });

  test('draft readiness requires each close photo and one context photo', () {
    const damage = BodyPaintDraftDamage(
      key: 'damage-1',
      panelCode: 'hood',
      damageType: 'dent',
      severity: 'medium',
      closePhotoAssetId: 'asset-close',
    );
    const incomplete = BodyPaintDraft(
      vehicle: ToyotaServiceVehicle(
        id: 'vehicle-1',
        make: 'Honda',
        model: 'Brio',
        variant: 'RS',
        year: 2024,
        mileage: 12000,
        licensePlate: 'L 1234 AB',
      ),
      location: ToyotaServiceLocation(
        id: 'location-1',
        name: 'TRIVA Surabaya',
        address: 'Surabaya',
        city: 'Surabaya',
      ),
      damages: [damage],
      consent: true,
    );

    expect(incomplete.canSubmit, isFalse);
    expect(
      incomplete.copyWith(contextPhotoAssetId: 'asset-context').canSubmit,
      isTrue,
    );
  });

  test('draft persists its source appraisal for resumable continuation', () {
    const draft = BodyPaintDraft(sourceAppraisalId: 'appraisal-1');

    final restored = BodyPaintDraft.fromJson(draft.toJson());

    expect(restored.sourceAppraisalId, 'appraisal-1');
  });
}
