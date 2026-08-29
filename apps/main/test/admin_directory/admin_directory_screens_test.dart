import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/admin_directory/data/admin_directory_repository.dart';
import 'package:triva_app/features/admin_directory/domain/admin_directory_models.dart';
import 'package:triva_app/features/admin_directory/presentation/admin_appraisal_screens.dart';
import 'package:triva_app/features/admin_directory/presentation/admin_credit_simulation_screens.dart';
import 'package:triva_app/features/admin_directory/presentation/admin_directory_controller.dart';
import 'package:triva_app/features/admin_directory/presentation/admin_user_directory_screen.dart';

class _MockRepository extends Mock implements AdminDirectoryRepository {}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(() => repository.appraisalStatuses()).thenAnswer(
      (_) async => const [
        AdminStatusOption(value: 'submitted', label: 'Permintaan diterima'),
      ],
    );
    when(() => repository.creditSimulationStatuses()).thenAnswer(
      (_) async => const [
        AdminStatusOption(value: 'saved', label: 'Tersimpan'),
      ],
    );
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view
      ..physicalSize = const Size(390, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDirectoryRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('user directory lists customers with their key data',
      (tester) async {
    when(
      () => repository.listUsers(
        search: any(named: 'search'),
        gender: any(named: 'gender'),
        hasDemographics: any(named: 'hasDemographics'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => AdminPage(
          items: [_user()],
          currentPage: 1,
          lastPage: 1,
        ));

    await pump(tester, const AdminUserDirectoryScreen());

    expect(find.text('Daftar pengguna'), findsOneWidget);
    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('siti@example.com'), findsOneWidget);
    expect(
      find.textContaining('+628111111111 · Bandung · Perempuan'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('user directory filters by gender', (tester) async {
    when(
      () => repository.listUsers(
        search: any(named: 'search'),
        gender: any(named: 'gender'),
        hasDemographics: any(named: 'hasDemographics'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => AdminPage(
          items: [_user()],
          currentPage: 1,
          lastPage: 1,
        ));

    await pump(tester, const AdminUserDirectoryScreen());
    // Label yang sama juga muncul pada baris daftar, jadi chip-nya dipilih
    // lewat tipenya.
    final chip = find.widgetWithText(ChoiceChip, 'Perempuan');
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    verify(
      () => repository.listUsers(
        search: '',
        gender: 'female',
        page: 1,
      ),
    ).called(1);
  });

  testWidgets('user detail shows demographics, consent, and activity',
      (tester) async {
    when(() => repository.getUser('7')).thenAnswer((_) async => _user());

    await pump(tester, const AdminUserDetailScreen(userId: '7'));

    expect(find.text('Detail pengguna'), findsOneWidget);
    expect(find.text('Demografi'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('30 tahun'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appraisal list shows reference, customer, and status',
      (tester) async {
    when(
      () => repository.listAppraisals(
        search: any(named: 'search'),
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => AdminPage(
          items: [_appraisal()],
          currentPage: 1,
          lastPage: 1,
        ));

    await pump(tester, const AdminAppraisalQueueScreen());

    expect(find.text('Daftar appraisal'), findsOneWidget);
    expect(find.text('Toyota Avanza G 2019'), findsOneWidget);
    expect(find.text('TIA-20260829-00000001'), findsOneWidget);
    expect(
      find.textContaining('Siti Rahma · Permintaan diterima'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('appraisal detail shows valuation and vehicle condition',
      (tester) async {
    when(() => repository.getAppraisal('appraisal-1'))
        .thenAnswer((_) async => _appraisal());

    await pump(
      tester,
      const AdminAppraisalDetailScreen(appraisalId: 'appraisal-1'),
    );

    expect(find.text('Detail appraisal'), findsOneWidget);
    expect(find.text('Taksiran'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Kondisi kendaraan'), findsOneWidget);
    expect(find.text('Status pajak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('credit simulation list summarises the installment',
      (tester) async {
    when(
      () => repository.listCreditSimulations(
        search: any(named: 'search'),
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => AdminPage(
          items: [_simulation()],
          currentPage: 1,
          lastPage: 1,
        ));

    await pump(tester, const AdminCreditSimulationQueueScreen());

    expect(find.text('Daftar simulasi kredit'), findsOneWidget);
    expect(find.text('Program Flat 5 Tahun'), findsOneWidget);
    expect(find.textContaining('per bulan · 60 bulan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('credit simulation detail lists the full breakdown',
      (tester) async {
    when(() => repository.getCreditSimulation('sim-1'))
        .thenAnswer((_) async => _simulation());

    await pump(
      tester,
      const AdminCreditSimulationDetailScreen(simulationId: 'sim-1'),
    );

    expect(find.text('Detail simulasi kredit'), findsOneWidget);
    expect(find.text('Rincian simulasi'), findsOneWidget);
    expect(find.text('Angsuran per bulan'), findsOneWidget);
    expect(find.text('Total pembayaran'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty list explains that nothing matches', (tester) async {
    when(
      () => repository.listAppraisals(
        search: any(named: 'search'),
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const AdminPage<AdminAppraisalRecord>(
        items: [],
        currentPage: 1,
        lastPage: 1,
      ),
    );

    await pump(tester, const AdminAppraisalQueueScreen());

    expect(find.text('Belum ada appraisal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

AdminUserRecord _user() => AdminUserRecord.fromJson({
      'id': 7,
      'name': 'Siti Rahma',
      'email': 'siti@example.com',
      'phone': '+628111111111',
      'city': 'Bandung',
      'gender': 'female',
      'gender_label': 'Perempuan',
      'birth_date': '1996-05-04',
      'age': 30,
      'is_active': true,
      'is_admin': false,
      'roles': <String>[],
      'marketing_consent': true,
      'demographics_completed': true,
      'created_at': '2026-01-05T03:00:00Z',
      'last_active_at': '2026-08-28T03:00:00Z',
      'activity': {
        'appraisals': 2,
        'toyota_service_bookings': 1,
        'otoxpert_bookings': 0,
        'credit_simulations': 3,
        'body_paint_estimates': 0,
        'vehicles': 1,
        'devices': 1,
      },
      'devices': [
        {
          'id': 'device-1',
          'platform': 'android',
          'device_name': 'Pixel 8',
          'app_version': '1.2.0',
          'app_build': '17',
          'last_active_at': '2026-08-28T03:00:00Z',
        },
      ],
    });

AdminAppraisalRecord _appraisal() => AdminAppraisalRecord.fromJson({
      'id': 'appraisal-1',
      'reference_no': 'TIA-20260829-00000001',
      'status': 'submitted',
      'status_label': 'Permintaan diterima',
      'vehicle': {
        'make': 'Toyota',
        'model': 'Avanza',
        'variant': 'G',
        'year': 2019
      },
      'condition': {
        'tax_status': 'hidup',
        'flood_history': 'tidak',
      },
      'customer': {
        'id': 7,
        'name': 'Siti Rahma',
        'email': 'siti@example.com',
        'phone': '+628111111111',
        'city': 'Bandung',
      },
      'expected_price': 150000000,
      'result': {
        'trade_in_estimate': {'low': 140000000, 'high': 160000000},
      },
      'submitted_at': '2026-08-28T03:00:00Z',
      'updated_at': '2026-08-29T03:00:00Z',
      'timeline': [
        {
          'occurred_at': '2026-08-28T03:00:00Z',
          'status': 'submitted',
          'title': 'Permintaan diterima',
        },
      ],
    });

AdminCreditSimulationRecord _simulation() =>
    AdminCreditSimulationRecord.fromJson({
      'id': 'sim-1',
      'reference_no': 'SK-260829-ABCDEFGH',
      'status': 'saved',
      'status_label': 'Tersimpan',
      'program': {'program_name': 'Program Flat 5 Tahun'},
      'customer': {
        'id': 7,
        'name': 'Siti Rahma',
        'email': 'siti@example.com',
        'phone': '+628111111111',
        'city': 'Bandung',
      },
      'totals': {
        'otr_price': 320000000,
        'total_down_payment': 80000000,
        'principal': 240000000,
        'tenor_months': 60,
        'monthly_installment': 5050000,
        'initial_payment': 81500000,
        'total_payment': 384500000,
        'trade_in_value': 0,
      },
      'saved_at': '2026-08-29T03:00:00Z',
    });
