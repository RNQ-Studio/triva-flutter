import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/screens/toyota_service_intake_screens.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';

class _FakeFlowController extends ToyotaServiceFlowController {
  _FakeFlowController(
    this.initialDraft, {
    this.failFirstUpload = false,
    this.uploadGate,
  });

  final ToyotaServiceDraft initialDraft;
  final bool failFirstUpload;
  final Completer<void>? uploadGate;
  var uploadCalls = 0;
  ToyotaServiceDraft get draft => state.value!.draft;

  @override
  Future<ToyotaServiceFlowState> build() async =>
      ToyotaServiceFlowState(draft: initialDraft);

  @override
  Future<void> savePhoto(
    XFile photo, {
    void Function(int sent, int total)? onProgress,
  }) async {
    uploadCalls += 1;
    onProgress?.call(1, 2);
    await uploadGate?.future;
    if (failFirstUpload && uploadCalls == 1) {
      throw StateError('offline');
    }
    onProgress?.call(2, 2);
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          photos: [
            ...current.draft.photos,
            ToyotaServiceDraftPhoto(
              assetId: 'asset-$uploadCalls',
              name: photo.name,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> removePhoto(String assetId) async {
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          photos: current.draft.photos
              .where((item) => item.assetId != assetId)
              .toList(growable: false),
        ),
      ),
    );
  }

  @override
  Future<void> saveThsAddress({
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          thsAddress: address,
          thsCity: city,
          thsLatitude: latitude,
          thsLongitude: longitude,
          thsLocationNotes: notes,
        ),
      ),
    );
  }

  @override
  Future<void> saveDetails({
    required int currentMileage,
    required String complaint,
  }) async {
    final current = state.value!;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          currentMileage: currentMileage,
          complaint: complaint,
        ),
      ),
    );
  }
}

class _FakePhotoPicker implements ToyotaServicePhotoPicker {
  @override
  Future<List<XFile>> pickImages({required int limit}) async => [
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          path: 'damage.jpg',
          name: 'damage.jpg',
          mimeType: 'image/jpeg',
        ),
      ];
}

void main() {
  testWidgets('failed photo keeps per-file retry and succeeds on retry',
      (tester) async {
    await _useTallSurface(tester);
    final flow = _FakeFlowController(
      const ToyotaServiceDraft(
        currentMileage: 10000,
        complaint: 'Servis berkala',
      ),
      failFirstUpload: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyotaServiceFlowProvider.overrideWith(() => flow),
          toyotaServiceOptionsProvider.overrideWith(
            (_) async => _options(),
          ),
          toyotaServicePhotoPickerProvider.overrideWithValue(
            _FakePhotoPicker(),
          ),
        ],
        child: _app(const ToyotaServiceDetailsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah foto'));
    await tester.pumpAndSettle();

    expect(
      find.text('Foto gagal diunggah. Periksa koneksi lalu coba lagi.'),
      findsOneWidget,
    );
    expect(_chooseScheduleButton(tester).onPressed, isNull);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(flow.uploadCalls, 2);
    expect(
      find.byKey(const ValueKey('supporting-photo-asset-2')),
      findsOneWidget,
    );
    expect(
      find.text('Foto gagal diunggah. Periksa koneksi lalu coba lagi.'),
      findsNothing,
    );
    expect(_chooseScheduleButton(tester).onPressed, isNotNull);
  });

  testWidgets('pending photo blocks continue until upload completes',
      (tester) async {
    await _useTallSurface(tester);
    final uploadGate = Completer<void>();
    final flow = _FakeFlowController(
      const ToyotaServiceDraft(
        currentMileage: 10000,
        complaint: 'Servis berkala',
      ),
      uploadGate: uploadGate,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyotaServiceFlowProvider.overrideWith(() => flow),
          toyotaServiceOptionsProvider.overrideWith((_) async => _options()),
          toyotaServicePhotoPickerProvider.overrideWithValue(
            _FakePhotoPicker(),
          ),
        ],
        child: _app(const ToyotaServiceDetailsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(_chooseScheduleButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Tambah foto'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_chooseScheduleButton(tester).onPressed, isNull);

    uploadGate.complete();
    await tester.pumpAndSettle();

    expect(_chooseScheduleButton(tester).onPressed, isNotNull);
    expect(
      find.byKey(const ValueKey('supporting-photo-asset-1')),
      findsOneWidget,
    );
  });

  testWidgets('failed photo can be removed before continuing', (tester) async {
    await _useTallSurface(tester);
    final flow = _FakeFlowController(
      const ToyotaServiceDraft(
        currentMileage: 10000,
        complaint: 'Servis berkala',
      ),
      failFirstUpload: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyotaServiceFlowProvider.overrideWith(() => flow),
          toyotaServiceOptionsProvider.overrideWith((_) async => _options()),
          toyotaServicePhotoPickerProvider.overrideWithValue(
            _FakePhotoPicker(),
          ),
        ],
        child: _app(const ToyotaServiceDetailsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah foto'));
    await tester.pumpAndSettle();
    expect(_chooseScheduleButton(tester).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('pending-supporting-photo-0-damage.jpg')),
      findsNothing,
    );
    expect(_chooseScheduleButton(tester).onPressed, isNotNull);
  });

  testWidgets('manual coordinate fallback is reachable from THS address',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final options = _options(ths: true);
    final flow = _FakeFlowController(
      ToyotaServiceDraft(
        serviceLocation: options.locations.single,
        serviceType: options.serviceTypes.single,
        fulfillmentType: ToyotaServiceFulfillment.ths,
        thsAddress: 'Jalan Toyota nomor 10',
        thsCity: 'Surabaya',
        thsLatitude: -7.27,
        thsLongitude: 112.76,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyotaServiceFlowProvider.overrideWith(() => flow),
          toyotaServiceOptionsProvider.overrideWith((_) async => options),
        ],
        child: _app(const ToyotaServiceAddressScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const ValueKey('ths-manual-pin')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('ths-manual-pin')));
    await tester.pumpAndSettle();

    expect(find.text('Atur koordinat lokasi'), findsWidgets);
    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
    await tester.tap(find.text('Simpan pin'));
    await tester.pumpAndSettle();

    expect(flow.draft.thsLatitude, -7.27);
    expect(flow.draft.thsLongitude, 112.76);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

FilledButton _chooseScheduleButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Pilih jadwal'),
    );

Future<void> _useTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

ToyotaServiceOptions _options({bool ths = false}) {
  const location = ToyotaServiceLocation(
    id: 'location-1',
    name: 'Toyota Surabaya',
    address: 'Jl. Toyota 1',
    city: 'Surabaya',
    supportsWorkshop: true,
    supportsThs: true,
  );
  const service = ToyotaServiceType(
    id: 'service-1',
    code: 'periodic',
    name: 'Servis berkala',
    description: 'Perawatan rutin',
    allowedFulfillments: [
      ToyotaServiceFulfillment.workshop,
      ToyotaServiceFulfillment.ths,
    ],
  );
  return ToyotaServiceOptions(
    timezone: 'Asia/Jakarta',
    contactChannels: const ['whatsapp'],
    locations: const [location],
    serviceTypes: const [service],
    thsCoverage: ths
        ? const [
            ToyotaServiceCoverage(
              city: 'Surabaya',
              isActive: true,
              serviceLocationId: 'location-1',
              bounds: {
                'latitude_min': -7.4,
                'latitude_max': -7.1,
                'longitude_min': 112.6,
                'longitude_max': 112.9,
              },
            ),
          ]
        : const [],
  );
}
