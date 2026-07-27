import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/toyota_service/data/toyota_service_repository.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';

class _MockDio extends Mock implements Dio {}

class _MemoryStorage implements StorageService {
  final _values = <String, String>{};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

void main() {
  late _MockDio dio;
  late ToyotaServiceRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = ToyotaServiceRepository(
      dio: dio,
      storage: _MemoryStorage(),
    );
  });

  test('collects every booking from nested two-page pagination metadata',
      () async {
    final requestedPages = <int>[];
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final query =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
      final page = query['page'] as int;
      requestedPages.add(page);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/toyota-service/bookings'),
        data: {
          'data': [_bookingJson('booking-$page')],
          'meta': {
            'pagination': {
              'current_page': page,
              'last_page': 2,
            },
          },
        },
      );
    });

    final bookings = await repository.listBookings();

    expect(bookings.map((item) => item.id), ['booking-1', 'booking-2']);
    expect(requestedPages, [1, 2]);
  });

  test('throws instead of looping when pagination metadata stops progressing',
      () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/toyota-service/bookings'),
        data: {
          'data': [_bookingJson('booking')],
          'meta': {
            'pagination': {
              'current_page': 1,
              'last_page': 2,
            },
          },
        },
      ),
    );

    await expectLater(
      repository.listBookings(),
      throwsA(isA<FormatException>()),
    );
    verify(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(2);
  });

  test('submit sends Laravel accepted consent as boolean true', () async {
    Map<String, dynamic>? capturedPayload;
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      capturedPayload =
          invocation.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/toyota-service/bookings'),
        data: {'data': _bookingJson('submitted')},
      );
    });

    await repository.submit(_completeWorkshopDraft());

    expect(capturedPayload?['service_consent'], isTrue);
    expect(capturedPayload?['service_consent'], isA<bool>());
    expect(capturedPayload?['photo_asset_ids'], ['asset-1', 'asset-2']);
  });

  test('draft storage is isolated between authenticated user identities',
      () async {
    final storage = _MemoryStorage();
    final repositoryA = ToyotaServiceRepository(
      dio: dio,
      storage: storage,
      userId: 'user-a',
    );
    final repositoryB = ToyotaServiceRepository(
      dio: dio,
      storage: storage,
      userId: 'user-b',
    );
    await repositoryA.saveDraft(
      const ToyotaServiceDraft(complaint: 'Private complaint from A'),
    );

    expect((await repositoryB.loadDraft()).complaint, isEmpty);
    expect(
      (await repositoryA.loadDraft()).complaint,
      'Private complaint from A',
    );
  });

  test('admin action preserves optional partner number and internal note',
      () async {
    Map<String, dynamic>? capturedPayload;
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      capturedPayload =
          invocation.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(
          path: 'v1/admin/toyota-service/bookings/booking-1/actions',
        ),
        data: {'data': _bookingJson('booking-1')},
      );
    });

    await repository.performAdminAction(
      'booking-1',
      action: 'confirm',
      fields: {
        'external_booking_number': 'PARTNER-123',
        'note': 'Internal operations note',
      },
    );

    expect(capturedPayload, {
      'action': 'confirm',
      'external_booking_number': 'PARTNER-123',
      'note': 'Internal operations note',
    });
  });

  test('admin queue sends selected sort and query equality includes it',
      () async {
    Map<String, dynamic>? capturedQuery;
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      capturedQuery = Map<String, dynamic>.from(
        invocation.namedArguments[#queryParameters] as Map<String, dynamic>,
      );
      return Response<dynamic>(
        requestOptions: RequestOptions(
          path: 'v1/admin/toyota-service/bookings',
        ),
        data: {
          'data': <Map<String, dynamic>>[],
          'meta': {
            'pagination': {'current_page': 1, 'last_page': 1},
          },
        },
      );
    });

    await repository.listAdminBookings(sort: 'due_asc');

    expect(capturedQuery?['sort'], 'due_asc');
    const initial = AdminToyotaServiceQuery();
    expect(initial.sort, 'updated_desc');
    expect(initial.copyWith(sort: 'slot_asc').sort, 'slot_asc');
    expect(initial, isNot(initial.copyWith(sort: 'slot_asc')));
  });

  test('vehicle intake collects owned vehicles from every page', () async {
    final requestedPages = <int>[];
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final query =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
      final page = query['page'] as int;
      requestedPages.add(page);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/vehicles'),
        data: {
          'data': [
            {
              'id': 'vehicle-$page',
              'make': 'Toyota',
              'model': page == 1 ? 'Avanza' : 'Innova',
              'variant': 'G',
              'year': 2024,
              'mileage': 10000,
              'license_plate': 'L 1234 AB',
            },
          ],
          'meta': {
            'pagination': {
              'current_page': page,
              'last_page': 2,
            },
          },
        },
      );
    });

    final vehicles = await repository.listVehicles();

    expect(vehicles.map((item) => item.id), ['vehicle-1', 'vehicle-2']);
    expect(requestedPages, [1, 2]);
  });
}

Map<String, dynamic> _bookingJson(String id) => {
      'id': id,
      'reference_no': 'TS-$id',
      'status': 'awaiting_confirmation',
      'status_label': 'Menunggu konfirmasi',
      'fulfillment_type': 'workshop',
      'current_mileage': 10000,
      'complaint': 'Servis berkala',
      'contact_channel': 'whatsapp',
      'allowed_customer_actions': <String>[],
      'timeline': <Map<String, dynamic>>[],
    };

ToyotaServiceDraft _completeWorkshopDraft() => ToyotaServiceDraft(
      vehicle: const ToyotaServiceVehicle(
        id: 'vehicle-1',
        make: 'Toyota',
        model: 'Avanza',
        variant: 'G',
        year: 2024,
        mileage: 10000,
        licensePlate: 'L 1234 AB',
      ),
      serviceLocation: const ToyotaServiceLocation(
        id: 'location-1',
        name: 'Toyota Surabaya',
        address: 'Jl. Toyota 1',
        city: 'Surabaya',
      ),
      serviceType: const ToyotaServiceType(
        id: 'service-1',
        code: 'periodic-service',
        name: 'Servis berkala',
        description: 'Perawatan rutin',
        allowedFulfillments: [ToyotaServiceFulfillment.workshop],
      ),
      fulfillmentType: ToyotaServiceFulfillment.workshop,
      currentMileage: 10000,
      complaint: 'Servis berkala kendaraan',
      photos: const [
        ToyotaServiceDraftPhoto(assetId: 'asset-1', name: 'damage-1.jpg'),
        ToyotaServiceDraftPhoto(assetId: 'asset-2', name: 'damage-2.png'),
      ],
      primarySlot: const ToyotaServiceSlot(
        date: '2026-08-10',
        timeWindow: '09:00-11:00',
      ),
      alternativeSlot: const ToyotaServiceSlot(
        date: '2026-08-11',
        timeWindow: '13:00-15:00',
      ),
      serviceConsent: true,
      idempotencyKey: 'idempotency-key',
    );
