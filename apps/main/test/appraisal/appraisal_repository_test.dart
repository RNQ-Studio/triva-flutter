import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/appraisal/data/appraisal_repository.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';

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
  test('creation calls send their persisted idempotency keys', () async {
    final dio = _MockDio();
    final repository = AppraisalRepository(
      dio: dio,
      storage: _MemoryStorage(),
      userId: 'customer-a',
    );
    final optionsByPath = <String, Options>{};
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      final path = invocation.positionalArguments.first as String;
      optionsByPath[path] = invocation.namedArguments[#options] as Options;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        data: {
          'data': path == 'v1/vehicles'
              ? _vehicleJson('vehicle-1')
              : _appraisalJson('appraisal-1'),
        },
      );
    });

    await repository.createVehicle(
      _vehicle(),
      idempotencyKey: 'vehicle-create-key',
    );
    await repository.createAppraisal(
      'vehicle-1',
      idempotencyKey: 'appraisal-create-key',
    );

    expect(
      optionsByPath['v1/vehicles']?.headers?['Idempotency-Key'],
      'vehicle-create-key',
    );
    expect(
      optionsByPath['v1/appraisals']?.headers?['Idempotency-Key'],
      'appraisal-create-key',
    );
  });

  test('draft storage is isolated per signed-in customer', () async {
    final storage = _MemoryStorage();
    final dio = _MockDio();
    final first = AppraisalRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-a',
    );
    final second = AppraisalRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-b',
    );

    await first.saveDraft(
      const AppraisalDraft(licensePlate: 'L 1234 PRIVATE'),
    );

    expect((await first.loadDraft()).licensePlate, 'L 1234 PRIVATE');
    expect((await second.loadDraft()).licensePlate, isEmpty);
  });

  test('unowned legacy draft is discarded instead of assigned to a user',
      () async {
    final storage = _MemoryStorage()
      ..values['appraisal_draft_v1'] = '{"license_plate":"L OTHER CUSTOMER"}';
    final repository = AppraisalRepository(
      dio: _MockDio(),
      storage: storage,
      userId: 'customer-b',
    );

    final draft = await repository.loadDraft();

    expect(draft.licensePlate, isEmpty);
    expect(storage.values, isNot(contains('appraisal_draft_v1')));
  });
}

VehicleData _vehicle() => const VehicleData(
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

Map<String, dynamic> _vehicleJson(String id) => {
      'id': id,
      'make': 'Toyota',
      'model': 'Avanza',
      'variant': '1.5 G',
      'year': 2022,
      'transmission': 'automatic',
      'fuel_type': 'gasoline',
      'mileage': 42000,
      'color': 'Putih',
      'license_plate': 'L 1234 TRV',
      'city': 'Surabaya',
    };

Map<String, dynamic> _appraisalJson(String id) => {
      'id': id,
      'reference_no': 'TIA-20260803-00000001',
      'status': 'draft',
      'status_label': 'Draft',
      'photos': <Map<String, dynamic>>[],
      'timeline': <Map<String, dynamic>>[],
    };
