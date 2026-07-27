import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/screens/toyota_service_booking_screens.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';
import 'package:triva_app/features/toyota_service/presentation/widgets/toyota_service_widgets.dart';

void main() {
  testWidgets('accept alternative does not wait for new availability slots',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final booking = ToyotaServiceBooking(
      id: 'booking-1',
      referenceNo: 'TS-001',
      status: 'alternative_proposed',
      statusLabel: 'Alternatif diajukan',
      fulfillmentType: ToyotaServiceFulfillment.workshop,
      currentMileage: 10000,
      complaint: 'Servis berkala',
      contactChannel: 'whatsapp',
      allowedCustomerActions: const ['accept_alternative'],
      timeline: const [],
      isConfirmed: false,
      proposedSlot: const ToyotaServiceSlot(
        date: '2026-08-10',
        timeWindow: '09:00-11:00',
      ),
      proposedPicName: 'Sari Proposal',
      proposedArrivalInstructions: 'Masuk melalui gate timur',
      serviceAdvisorName: 'Sari Active',
      serviceAdvisorPhone: '081300000000',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyotaServiceBookingDetailProvider('booking-1').overrideWith(
            (_) async => booking,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ToyotaServiceBookingDetailScreen(
            bookingId: 'booking-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(
      FilledButton,
      'Terima jadwal alternatif',
    );
    expect(buttonFinder, findsOneWidget);
    expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNotNull);
    expect(find.text('Sari Proposal'), findsOneWidget);
    expect(find.text('Masuk melalui gate timur'), findsOneWidget);
    expect(find.text('Sari Active'), findsOneWidget);
    expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timeline exposes actor and reason only in admin mode',
      (tester) async {
    const item = ToyotaServiceTimelineItem(
      status: 'confirmed',
      title: 'Confirmed',
      actorName: 'Ramadhan',
      actorType: 'admin',
      reasonCode: 'customer_preference',
      internalNote: 'Internal audit note',
    );
    Future<void> pump(bool admin) => tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BookingTimeline(
                items: const [item],
                showAdminDetails: admin,
              ),
            ),
          ),
        );

    await pump(false);
    expect(find.textContaining('Ramadhan'), findsNothing);
    expect(find.textContaining('customer_preference'), findsNothing);

    await pump(true);
    expect(find.textContaining('Ramadhan'), findsOneWidget);
    expect(find.textContaining('customer_preference'), findsOneWidget);
    expect(find.textContaining('Internal audit note'), findsOneWidget);
  });
}
