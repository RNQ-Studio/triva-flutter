import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/otoxpert/domain/otoxpert_models.dart';
import 'package:triva_app/features/otoxpert/presentation/otoxpert_controller.dart';
import 'package:triva_app/features/otoxpert/presentation/screens/otoxpert_booking_screen.dart';
import 'package:triva_app/features/otoxpert/presentation/screens/otoxpert_intake_screen.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_paths.dart';

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

class _RestoredOtoxpertFlowController extends OtoxpertFlowController {
  @override
  Future<OtoxpertFlowState> build() async => const OtoxpertFlowState(
        draft: OtoxpertDraft(
          vehicle: _vehicle,
          currentMileage: 12000,
        ),
      );
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

  testWidgets('system back moves to the previous intake step before popping',
      (tester) async {
    final router = await _pumpIntakeRouter(tester);

    await _openIntakeAndAdvanceToService(tester);
    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 1);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Buka OtoXpert'), findsNothing);
    expect(find.text('Booking OtoXpert'), findsOneWidget);
    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Buka OtoXpert'), findsOneWidget);
    expect(find.byType(OtoxpertIntakeScreen), findsNothing);
    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });

  testWidgets('app bar back moves to the previous intake step before popping',
      (tester) async {
    final router = await _pumpIntakeRouter(tester);

    await _openIntakeAndAdvanceToService(tester);
    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 1);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Buka OtoXpert'), findsNothing);
    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 0);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Buka OtoXpert'), findsOneWidget);
    expect(find.byType(OtoxpertIntakeScreen), findsNothing);
    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });

  testWidgets('direct intake exposes back and falls back to home',
      (tester) async {
    final router = await _pumpIntakeRouter(tester);

    router.go('/otoxpert');
    await tester.pumpAndSettle();
    expect(find.byType(OtoxpertIntakeScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Buka OtoXpert'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(tester.takeException(), isNull);
  });

  testWidgets('add vehicle returns to OtoXpert and selects the saved vehicle',
      (tester) async {
    final router = await _pumpIntakeRouter(tester, vehicles: const []);

    await tester.tap(find.text('Buka OtoXpert'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah kendaraan'));
    await tester.pumpAndSettle();

    expect(find.text('Form kendaraan test'), findsOneWidget);
    await tester.tap(find.text('Simpan kendaraan test'));
    await tester.pumpAndSettle();

    expect(find.byType(OtoxpertIntakeScreen), findsOneWidget);
    expect(find.text('Honda Brio RS'), findsWidgets);
    expect(
      tester.widget<Stepper>(find.byType(Stepper)).currentStep,
      0,
    );
    expect(router.state.uri.path, '/otoxpert');
    expect(tester.takeException(), isNull);
  });

  testWidgets('restored draft resumes at its next incomplete step',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          otoxpertFlowProvider.overrideWith(
            _RestoredOtoxpertFlowController.new,
          ),
          otoxpertOptionsProvider.overrideWith((_) async => _options()),
          otoxpertWorkshopsProvider(_vehicle.id).overrideWith(
            (_) async => const [],
          ),
        ],
        child: _app(const OtoxpertIntakeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 1);
    expect(tester.takeException(), isNull);
  });

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

Future<GoRouter> _pumpIntakeRouter(
  WidgetTester tester, {
  List<ToyotaServiceVehicle> vehicles = const [_vehicle],
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final availableVehicles = vehicles.toList();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => context.push('/otoxpert'),
              child: const Text('Buka OtoXpert'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/otoxpert',
        builder: (context, state) => const OtoxpertIntakeScreen(),
      ),
      GoRoute(
        path: toyotaServiceAddVehiclePath,
        builder: (context, state) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () {
                availableVehicles.add(_vehicle);
                context.pop(_vehicle);
              },
              child: const Text('Simpan kendaraan test'),
            ),
          ),
          appBar: AppBar(title: const Text('Form kendaraan test')),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        otoxpertFlowProvider.overrideWith(_FakeOtoxpertFlowController.new),
        otoxpertOptionsProvider.overrideWith((_) async => _options()),
        otoxpertVehiclesProvider.overrideWith(
          (_) async => availableVehicles,
        ),
        otoxpertWorkshopsProvider('vehicle-1').overrideWith(
          (_) async => const [],
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

const _vehicle = ToyotaServiceVehicle(
  id: 'vehicle-1',
  make: 'Honda',
  model: 'Brio',
  variant: 'RS',
  year: 2024,
  mileage: 12000,
  licensePlate: 'L 1234 AB',
);

Future<void> _openIntakeAndAdvanceToService(WidgetTester tester) async {
  await tester.tap(find.text('Buka OtoXpert'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Honda Brio RS'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.widgetWithText(FilledButton, 'Lanjut').hitTestable(),
  );
  await tester.pumpAndSettle();
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
