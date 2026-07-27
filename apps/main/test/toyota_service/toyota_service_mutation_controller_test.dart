import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/toyota_service/data/toyota_service_repository.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';

class _MockToyotaServiceRepository extends Mock
    implements ToyotaServiceRepository {}

void main() {
  test('customer mutation conflict refreshes detail and list source of truth',
      () async {
    final repository = _MockToyotaServiceRepository();
    var listCalls = 0;
    var detailCalls = 0;
    when(repository.listBookings).thenAnswer((_) async {
      listCalls += 1;
      return const [_booking];
    });
    when(() => repository.getBooking(_booking.id)).thenAnswer((_) async {
      detailCalls += 1;
      return _booking;
    });
    when(() => repository.acceptAlternative(_booking.id))
        .thenThrow(_conflict());

    final container = ProviderContainer(
      overrides: [
        toyotaServiceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(toyotaServiceBookingsProvider, (_, __) {});
    container.listen(
      toyotaServiceBookingDetailProvider(_booking.id),
      (_, __) {},
    );

    await Future.wait([
      container.read(toyotaServiceBookingsProvider.future),
      container.read(
        toyotaServiceBookingDetailProvider(_booking.id).future,
      ),
    ]);
    expect((listCalls, detailCalls), (1, 1));

    await container.read(toyotaServiceMutationProvider.future);
    final result = await container
        .read(toyotaServiceMutationProvider.notifier)
        .acceptAlternative(_booking.id);
    expect(result, isNull);

    await Future.wait([
      container.read(toyotaServiceBookingsProvider.future),
      container.read(
        toyotaServiceBookingDetailProvider(_booking.id).future,
      ),
    ]);
    expect((listCalls, detailCalls), (2, 2));
  });

  test('admin mutation conflict refreshes admin detail and queue', () async {
    final repository = _MockToyotaServiceRepository();
    const query = AdminToyotaServiceQuery(
      status: 'requested',
      sort: 'due_asc',
    );
    var listCalls = 0;
    var detailCalls = 0;
    when(
      () => repository.listAdminBookings(
        status: query.status,
        search: query.search,
        serviceTypeId: query.serviceTypeId,
        serviceLocationId: query.serviceLocationId,
        fulfillmentType: query.fulfillmentType,
        date: query.date,
        advisorId: query.advisorId,
        slaOverdue: query.slaOverdue,
        sort: query.sort,
      ),
    ).thenAnswer((_) async {
      listCalls += 1;
      return const [_booking];
    });
    when(() => repository.getAdminBooking(_booking.id)).thenAnswer((_) async {
      detailCalls += 1;
      return _booking;
    });
    when(
      () => repository.performAdminAction(
        _booking.id,
        action: 'confirm',
      ),
    ).thenThrow(_conflict());

    final container = ProviderContainer(
      overrides: [
        toyotaServiceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(
      adminToyotaServiceFilteredBookingsProvider(query),
      (_, __) {},
    );
    container.listen(
      adminToyotaServiceBookingDetailProvider(_booking.id),
      (_, __) {},
    );

    await Future.wait([
      container.read(adminToyotaServiceFilteredBookingsProvider(query).future),
      container.read(
        adminToyotaServiceBookingDetailProvider(_booking.id).future,
      ),
    ]);
    expect((listCalls, detailCalls), (1, 1));

    await container.read(toyotaServiceMutationProvider.future);
    final result = await container
        .read(toyotaServiceMutationProvider.notifier)
        .adminAction(
          _booking.id,
          action: 'confirm',
        );
    expect(result, isNull);

    await Future.wait([
      container.read(adminToyotaServiceFilteredBookingsProvider(query).future),
      container.read(
        adminToyotaServiceBookingDetailProvider(_booking.id).future,
      ),
    ]);
    expect((listCalls, detailCalls), (2, 2));
  });
}

const _booking = ToyotaServiceBooking(
  id: 'booking-1',
  referenceNo: 'TS-001',
  status: 'requested',
  statusLabel: 'Requested',
  fulfillmentType: ToyotaServiceFulfillment.workshop,
  currentMileage: 12000,
  complaint: 'Servis berkala',
  contactChannel: 'whatsapp',
  allowedCustomerActions: ['accept_alternative'],
  timeline: [],
  isConfirmed: false,
);

DioException _conflict() {
  final request = RequestOptions(path: 'v1/toyota-service/bookings/booking-1');
  return DioException(
    requestOptions: request,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: 409,
      data: const {'message': 'Proposal expired'},
    ),
  );
}
