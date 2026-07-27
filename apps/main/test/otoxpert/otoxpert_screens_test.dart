import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/otoxpert/domain/otoxpert_models.dart';
import 'package:triva_app/features/otoxpert/presentation/otoxpert_controller.dart';
import 'package:triva_app/features/otoxpert/presentation/screens/otoxpert_booking_screen.dart';
import 'package:triva_app/features/otoxpert/presentation/screens/otoxpert_intake_screen.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';

class _FakeOtoxpertFlowController extends OtoxpertFlowController {
  @override
  Future<OtoxpertFlowState> build() async =>
      const OtoxpertFlowState(draft: OtoxpertDraft());

  @override
  Future<void> selectVehicle(ToyotaServiceVehicle vehicle) async {
    state = AsyncData(
      OtoxpertFlowState(
        draft: OtoxpertDraft(
          vehicle: vehicle,
          currentMileage: vehicle.mileage,
        ),
      ),
    );
  }
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'intake vehicle step is usable in ${brightness.name} theme',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              otoxpertFlowProvider.overrideWith(
                _FakeOtoxpertFlowController.new,
              ),
              otoxpertOptionsProvider.overrideWith((_) async => _options()),
              otoxpertVehiclesProvider.overrideWith(
                (_) async => const [
                  ToyotaServiceVehicle(
                    id: 'vehicle-1',
                    make: 'Honda',
                    model: 'Brio',
                    variant: 'RS',
                    year: 2024,
                    mileage: 12000,
                    licensePlate: 'L 1234 AB',
                  ),
                ],
              ),
            ],
            child: _app(
              const OtoxpertIntakeScreen(),
              brightness: brightness,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Booking OtoXpert'), findsOneWidget);
        expect(find.text('Honda Brio RS'), findsOneWidget);
        expect(find.text('Kendaraan'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('booking detail exposes alternative lifecycle actions',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final booking = OtoxpertBooking(
      id: 'booking-1',
      referenceNo: 'OX-001',
      status: 'alternative_proposed',
      statusLabel: 'Jadwal alternatif diajukan',
      currentMileage: 12000,
      complaint: 'Mesin terdengar kasar.',
      symptomCodes: const ['noise'],
      allowedCustomerActions: const [
        'accept_alternative',
        'reject_alternative',
      ],
      timeline: const [
        ToyotaServiceTimelineItem(
          status: 'alternative_proposed',
          title: 'Jadwal alternatif diajukan',
        ),
      ],
      isConfirmed: false,
      submittedAt: DateTime(2026, 7, 27),
      proposedSlot: const ToyotaServiceSlot(
        date: '2026-08-03',
        timeWindow: '13:00-15:00',
      ),
      proposalReason: 'Kapasitas penuh.',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          otoxpertBookingProvider('booking-1').overrideWith(
            (_) async => booking,
          ),
        ],
        child: _app(const OtoxpertBookingScreen(bookingId: 'booking-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terima jadwal alternatif'), findsOneWidget);
    expect(find.text('Tolak dan pilih jadwal lain'), findsOneWidget);
    expect(find.text('Kapasitas penuh.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(
  Widget home, {
  Brightness brightness = Brightness.light,
}) =>
    MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

OtoxpertOptions _options() => const OtoxpertOptions(
      notice: 'Jadwal menunggu konfirmasi.',
      partnerConsentVersion: 'otoxpert-data-sharing-v1',
      symptoms: [
        OtoxpertOption(value: 'noise', label: 'Suara tidak normal'),
      ],
      contactChannels: [
        OtoxpertOption(value: 'whatsapp', label: 'WhatsApp'),
      ],
      maxPhotos: 5,
    );
