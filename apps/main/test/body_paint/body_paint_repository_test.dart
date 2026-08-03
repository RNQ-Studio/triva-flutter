import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/body_paint/data/body_paint_repository.dart';
import 'package:triva_app/features/body_paint/domain/body_paint_models.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

class _MockDio extends Mock implements Dio {}

class _MemoryStorage implements StorageService {
  final values = <String, String>{};

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  late _MockDio dio;
  late BodyPaintRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = BodyPaintRepository(
      dio: dio,
      storage: _MemoryStorage(),
      userId: 'customer-1',
    );
  });

  test('create draft sends selected scope and idempotency header', () async {
    Map<String, dynamic>? payload;
    Options? options;
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      payload = invocation.namedArguments[#data] as Map<String, dynamic>;
      options = invocation.namedArguments[#options] as Options;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/body-paint/estimates'),
        data: {'data': _estimateJson('estimate-1')},
      );
    });

    await repository.createDraft(_completeDraft());

    expect(payload?['vehicle_id'], 'vehicle-1');
    expect(payload?['appraisal_id'], 'appraisal-1');
    expect(payload?['service_location_id'], 'location-1');
    expect(payload?['campaign_source'], 'triva_app');
    expect(options?.headers?['Idempotency-Key'], 'idem-1');
  });

  test('attach photos preserves close damage relation and context privacy',
      () async {
    Map<String, dynamic>? payload;
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      payload = invocation.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'photos'),
        data: {'data': _estimateJson('estimate-1')},
      );
    });

    await repository.attachPhotos('estimate-1', _completeDraft());

    final photos = payload?['photos'] as List<dynamic>;
    expect(photos, hasLength(2));
    expect((photos.first as Map<String, dynamic>)['damage_id'], 'damage-1');
    expect((photos.last as Map<String, dynamic>)['damage_id'], isNull);
    expect((photos.last as Map<String, dynamic>)['photo_type'], 'context');
  });

  test('submit sends both service and indicative-estimate consents', () async {
    Map<String, dynamic>? payload;
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      payload = invocation.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'submit'),
        data: {'data': _estimateJson('estimate-1')},
      );
    });

    await repository.submit('estimate-1');

    expect(payload?['service_consent'], isTrue);
    expect(payload?['estimate_disclaimer_accepted'], isTrue);
  });

  test('estimate pagination collects every page', () async {
    final pages = <int>[];
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final query =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
      final page = query['page'] as int;
      pages.add(page);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/body-paint/estimates'),
        data: {
          'data': [_estimateJson('estimate-$page')],
          'meta': {
            'pagination': {'current_page': page, 'last_page': 2},
          },
        },
      );
    });

    final estimates = await repository.listEstimates();

    expect(estimates.map((item) => item.id), ['estimate-1', 'estimate-2']);
    expect(pages, [1, 2]);
  });

  test('draft storage is isolated per signed-in customer', () async {
    final storage = _MemoryStorage();
    final first = BodyPaintRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-a',
    );
    final second = BodyPaintRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-b',
    );
    await first.saveDraft(const BodyPaintDraft(notes: 'Private note A'));

    expect((await first.loadDraft()).notes, 'Private note A');
    expect((await second.loadDraft()).notes, isEmpty);
  });
}

BodyPaintDraft _completeDraft() => const BodyPaintDraft(
      estimateId: 'estimate-1',
      sourceAppraisalId: 'appraisal-1',
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
      damages: [
        BodyPaintDraftDamage(
          key: 'local-1',
          remoteId: 'damage-1',
          panelCode: 'hood',
          damageType: 'dent',
          severity: 'medium',
          closePhotoAssetId: 'asset-close',
        ),
      ],
      contextPhotoAssetId: 'asset-context',
      consent: true,
      idempotencyKey: 'idem-1',
    );

Map<String, dynamic> _estimateJson(String id) => {
      'id': id,
      'reference_no': 'BP-001',
      'status': 'draft',
      'status_label': 'Draft',
      'allowed_customer_actions': ['update'],
      'requires_physical_inspection': true,
      'damages': <Map<String, dynamic>>[],
      'context_photos': <Map<String, dynamic>>[],
      'timeline': <Map<String, dynamic>>[],
    };
