import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/otoxpert/data/otoxpert_repository.dart';
import 'package:triva_app/features/otoxpert/domain/otoxpert_models.dart';
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
  late OtoxpertRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = OtoxpertRepository(
      dio: dio,
      storage: _MemoryStorage(),
      userId: 'customer-1',
    );
  });

  test('submit sends consent, protected assets, and idempotency key', () async {
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
        requestOptions: RequestOptions(path: 'v1/otoxpert/bookings'),
        data: {'data': _bookingJson('booking-1')},
      );
    });

    await repository.submit(
      _completeDraft(),
      'otoxpert-data-sharing-v1',
    );

    expect(payload?['partner_consent'], isTrue);
    expect(
      payload?['partner_consent_version'],
      'otoxpert-data-sharing-v1',
    );
    expect(payload?['symptom_codes'], ['noise']);
    expect(payload?['photo_asset_ids'], ['asset-1']);
    expect(options?.headers?['Idempotency-Key'], 'idem-1');
  });

  test('booking pagination collects all pages', () async {
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
        requestOptions: RequestOptions(path: 'v1/otoxpert/bookings'),
        data: {
          'data': [_bookingJson('booking-$page')],
          'meta': {
            'pagination': {'current_page': page, 'last_page': 2},
          },
        },
      );
    });

    final bookings = await repository.listBookings();

    expect(bookings.map((item) => item.id), ['booking-1', 'booking-2']);
    expect(pages, [1, 2]);
  });

  test('draft storage is isolated per signed-in customer', () async {
    final storage = _MemoryStorage();
    final first = OtoxpertRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-a',
    );
    final second = OtoxpertRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-b',
    );
    await first.saveDraft(
      const OtoxpertDraft(complaint: 'Private complaint A'),
    );

    expect((await first.loadDraft()).complaint, 'Private complaint A');
    expect((await second.loadDraft()).complaint, isEmpty);
  });
}

OtoxpertDraft _completeDraft() => const OtoxpertDraft(
      vehicle: ToyotaServiceVehicle(
        id: 'vehicle-1',
        make: 'Honda',
        model: 'Brio',
        variant: 'RS',
        year: 2024,
        mileage: 12000,
        licensePlate: 'L 1234 AB',
      ),
      workshop: OtoxpertWorkshop(
        id: 'workshop-1',
        name: 'OtoXpert Rungkut',
        address: 'Surabaya',
        city: 'Surabaya',
        timezone: 'Asia/Jakarta',
        supportsPickupDelivery: false,
        confirmationSlaMinutes: 30,
      ),
      service: OtoxpertService(
        id: 'service-1',
        code: 'oil',
        name: 'Ganti oli',
        description: '',
        leadTimeDays: 1,
      ),
      currentMileage: 12000,
      complaint: 'Mesin terdengar kasar.',
      symptomCodes: ['noise'],
      photos: [ToyotaServiceDraftPhoto(assetId: 'asset-1', name: 'noise.jpg')],
      primarySlot: ToyotaServiceSlot(
        date: '2026-08-01',
        timeWindow: '08:00-10:00',
      ),
      alternativeSlot: ToyotaServiceSlot(
        date: '2026-08-02',
        timeWindow: '10:00-12:00',
      ),
      partnerConsent: true,
      idempotencyKey: 'idem-1',
    );

Map<String, dynamic> _bookingJson(String id) => {
      'id': id,
      'reference_no': 'OX-001',
      'status': 'awaiting_confirmation',
      'status_label': 'Menunggu konfirmasi',
      'current_mileage': 12000,
      'complaint': 'Mesin terdengar kasar.',
      'symptom_codes': ['noise'],
      'allowed_customer_actions': ['cancel'],
      'timeline': <Map<String, dynamic>>[],
      'is_confirmed': false,
      'submitted_at': '2026-07-27T01:00:00Z',
    };
