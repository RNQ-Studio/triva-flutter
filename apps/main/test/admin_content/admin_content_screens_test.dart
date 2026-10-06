import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/admin_content/presentation/admin_content_paths.dart';
import 'package:triva_app/features/admin_content/presentation/admin_content_routes.dart';
import 'package:triva_app/features/info_popup/data/info_popup_repository.dart';
import 'package:triva_app/features/info_popup/domain/info_popup_models.dart';
import 'package:triva_app/features/info_popup/presentation/info_popup_controller.dart';
import 'package:triva_app/features/info_popup/presentation/info_popup_dialog.dart';
import 'package:triva_app/features/maintenance_estimate/data/service_package_admin_repository.dart';
import 'package:triva_app/features/maintenance_estimate/domain/maintenance_estimate_models.dart';
import 'package:triva_app/features/maintenance_estimate/presentation/maintenance_estimate_controller.dart';
import 'package:triva_app/features/partner_logo/data/partner_logo_repository.dart';
import 'package:triva_app/features/partner_logo/domain/partner_logo_models.dart';
import 'package:triva_app/features/partner_logo/presentation/partner_logo_controller.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_routes.dart';

class _AuthNotifier extends AuthNotifier {
  _AuthNotifier(this.user);

  final User user;

  @override
  AuthState build() => AuthAuthenticated(user);
}

User _user(List<String> permissions) => User(
      id: 'admin',
      name: 'Admin',
      email: 'admin@example.com',
      profileCompleted: true,
      demographicsCompleted: true,
      permissions: permissions,
    );

const _contentEditor = [
  'articles.viewAny',
  'articles.create',
  'articles.update',
  'articles.delete',
  'toyota_service_config.viewAny',
  'toyota_service_config.create',
  'toyota_service_config.update',
  'toyota_service_config.delete',
];

class _FakeInfoPopups implements InfoPopupRepository {
  _FakeInfoPopups(this.items);

  final List<InfoPopup> items;

  @override
  Future<List<InfoPopup>> listAll() async => items;

  @override
  Future<List<InfoPopup>> listRunning() async =>
      items.where((popup) => popup.isRunning).toList();

  @override
  Future<InfoPopup> create(
    InfoPopupInput input, {
    required List<int> imageBytes,
    required String imageName,
  }) =>
      throw UnimplementedError();

  @override
  Future<InfoPopup> update(
    String id,
    InfoPopupInput input, {
    List<int>? imageBytes,
    String? imageName,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}
}

class _FakePartnerLogos implements PartnerLogoRepository {
  _FakePartnerLogos(this.items);

  List<PartnerLogo> items;
  PartnerLogoInput? lastInput;
  List<int>? lastLogoBytes;

  @override
  Future<List<PartnerLogo>> listActive() async => items;

  @override
  Future<List<PartnerLogo>> listAll() async => items;

  @override
  Future<PartnerLogo> create(
    PartnerLogoInput input, {
    required List<int> logoBytes,
    required String logoName,
  }) =>
      throw UnimplementedError();

  @override
  Future<PartnerLogo> update(
    String id,
    PartnerLogoInput input, {
    List<int>? logoBytes,
    String? logoName,
  }) async {
    lastInput = input;
    lastLogoBytes = logoBytes;
    final updated = PartnerLogo(
      id: id,
      name: input.name.trim(),
      logoUrl: 'https://example.test/$id.png',
      linkUrl: input.linkUrl.trim().isEmpty ? null : input.linkUrl.trim(),
      sortOrder: input.sortOrder,
      isActive: input.isActive,
    );
    items = [
      for (final item in items)
        if (item.id == id) updated else item,
    ];
    return updated;
  }

  @override
  Future<void> delete(String id) async {}
}

class _FakeServicePackages implements ServicePackageAdminRepository {
  _FakeServicePackages(this.items, {this.rejectWith});

  final List<MaintenancePackage> items;
  final Object? rejectWith;
  ServicePackageInput? lastCreated;

  @override
  Future<List<MaintenancePackage>> listAll() async => items;

  @override
  Future<MaintenancePackage> create(ServicePackageInput input) async {
    lastCreated = input;
    final error = rejectWith;
    if (error != null) throw error;
    return MaintenancePackage.fromJson({'id': 'new', ...input.toJson()});
  }

  @override
  Future<MaintenancePackage> update(String id, ServicePackageInput input) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}
}

MaintenancePackage _package(
  String id, {
  String? model,
  required int km,
  int labor = 300000,
  int parts = 700000,
  bool active = true,
}) =>
    MaintenancePackage.fromJson({
      'id': id,
      'code': 'T-CARE',
      'name': 'Servis Berkala $km km',
      'vehicle_model': model,
      'km_interval': km,
      'labor_cost': labor,
      'parts_cost': parts,
      'total_cost': labor + parts,
      'is_active': active,
      'is_effective': active,
    });

Future<void> _pumpRouter(
  WidgetTester tester, {
  required String initialLocation,
  List<String> permissions = _contentEditor,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPanelScreen()),
      ...adminContentRoutes,
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey(permissions.join(',')),
      overrides: [
        authProvider.overrideWith(() => _AuthNotifier(_user(permissions))),
        ...overrides,
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
}

void main() {
  testWidgets('Admin Panel lists the content menus only with permission',
      (tester) async {
    await _pumpRouter(tester, initialLocation: '/admin');

    expect(find.text('Popup informasi'), findsOneWidget);
    expect(find.text('Mitra resmi'), findsOneWidget);
    expect(find.text('Paket servis T-Care'), findsOneWidget);

    await _pumpRouter(
      tester,
      initialLocation: '/admin',
      permissions: const ['service_bookings.viewAny'],
    );

    expect(find.text('Popup informasi'), findsNothing);
    expect(find.text('Paket servis T-Care'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('info pop-up list shows status and previews running slides',
      (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final repository = _FakeInfoPopups([
      const InfoPopup(
        id: 'live',
        title: 'Promo servis',
        imageUrl: 'https://example.test/live.jpg',
        buttonLabel: 'Booking sekarang',
        buttonUrl: 'https://auto2000.co.id',
        sortOrder: 1,
        intervalHours: 6,
      ),
      InfoPopup(
        id: 'later',
        title: 'Pameran',
        imageUrl: 'https://example.test/later.jpg',
        sortOrder: 2,
        isRunning: false,
        startsOn: today.add(const Duration(days: 3)),
      ),
      const InfoPopup(
        id: 'off',
        title: 'Lama',
        imageUrl: 'https://example.test/off.jpg',
        sortOrder: 3,
        isActive: false,
        isRunning: false,
      ),
    ]);
    await _pumpRouter(
      tester,
      initialLocation: adminInfoPopupsPath,
      overrides: [infoPopupRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Urutan 1 · setiap 6 jam'), findsOneWidget);
    expect(find.text('Tayang'), findsOneWidget);
    expect(find.text('Terjadwal'), findsOneWidget);
    expect(find.text('Nonaktif'), findsOneWidget);

    await tester.tap(find.byTooltip('Pratinjau popup'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<InfoPopupDialog>(find.byType(InfoPopupDialog));
    expect(dialog.popups.map((popup) => popup.id), ['live']);
    expect(find.text('Booking sekarang'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new info pop-up requires an image, a title, and a full button',
      (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: adminInfoPopupNewPath,
      overrides: [
        infoPopupRepositoryProvider.overrideWithValue(_FakeInfoPopups([])),
      ],
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Label tombol'),
      'Lihat promo',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Gambar wajib dipilih.'), findsOneWidget);
    expect(find.text('Kolom ini wajib diisi.'), findsOneWidget);
    expect(
      find.text(
          'Isi label dan tautan tombol sekaligus, atau kosongkan keduanya.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan tombol'),
      'auto2000.co.id',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masukkan tautan lengkap yang diawali http:// atau https://.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing a partner keeps the logo and returns to the list',
      (tester) async {
    final repository = _FakePartnerLogos(const [
      PartnerLogo(
        id: 'acc',
        name: 'ACC',
        logoUrl: 'https://example.test/acc.png',
        sortOrder: 4,
      ),
    ]);
    await _pumpRouter(
      tester,
      initialLocation: adminPartnerLogosPath,
      overrides: [partnerLogoRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Tanpa tautan'), findsOneWidget);
    await tester.tap(find.text('ACC'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan saat diketuk'),
      'https://www.acc.co.id',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(repository.lastInput?.linkUrl, 'https://www.acc.co.id');
    expect(repository.lastInput?.sortOrder, 4);
    expect(repository.lastLogoBytes, isNull);
    expect(find.text('Perubahan tersimpan.'), findsOneWidget);
    expect(find.text('https://www.acc.co.id'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('service packages group general packages before each model',
      (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: adminServicePackagesPath,
      overrides: [
        servicePackageAdminRepositoryProvider.overrideWithValue(
          _FakeServicePackages([
            _package('a40', model: 'Avanza', km: 40000),
            _package('g10', km: 10000),
            _package('a10', model: 'Avanza', km: 10000, active: false),
          ]),
        ),
      ],
    );

    final allModels = tester.getTopLeft(find.text('Semua model')).dy;
    final avanza = tester.getTopLeft(find.text('Avanza')).dy;
    expect(allModels, lessThan(avanza));
    expect(find.text('10.000 km'), findsNWidgets(2));
    expect(find.text('Jasa Rp 300.000 · Part Rp 700.000'), findsNWidgets(3));
    expect(find.text('Rp 1.000.000'), findsNWidgets(3));
    expect(find.text('Nonaktif'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new service package sends budgets and shows server errors',
      (tester) async {
    final repository = _FakeServicePackages(
      const [],
      rejectWith: DioException(
        requestOptions:
            RequestOptions(path: 'v1/admin/toyota-service/packages'),
        error: const ServerException(
          'Data tidak valid.',
          statusCode: 422,
          validationErrors: {
            'km_interval': [
              'Paket untuk model ini pada kelipatan km tersebut sudah ada.',
            ],
          },
        ),
      ),
    );
    await _pumpRouter(
      tester,
      initialLocation: adminServicePackageNewPath,
      overrides: [
        servicePackageAdminRepositoryProvider.overrideWithValue(repository),
      ],
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Model kendaraan'),
      'Avanza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kelipatan kilometer'),
      '10000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Budget jasa'),
      '350000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Budget part'),
      '650000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cakupan pekerjaan'),
      'Ganti oli mesin\n\nFilter oli',
    );
    await tester.pump();

    expect(find.text('10.000'), findsOneWidget);
    expect(find.text('Total budget Rp 1.000.000'), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final sent = repository.lastCreated!.toJson();
    expect(sent['vehicle_model'], 'Avanza');
    expect(sent['km_interval'], 10000);
    expect(sent['labor_cost'], 350000);
    expect(sent['parts_cost'], 650000);
    expect(sent['name'], isNull);
    expect(sent['includes'], ['Ganti oli mesin', 'Filter oli']);
    expect(
      find.text('Paket untuk model ini pada kelipatan km tersebut sudah ada.'),
      findsOneWidget,
    );
    // Gagal simpan tetap di form supaya isian tidak hilang.
    expect(find.text('Paket baru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
