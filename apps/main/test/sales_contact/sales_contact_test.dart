import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/sales_contact/data/sales_contact_repository.dart';
import 'package:triva_app/features/sales_contact/domain/sales_contact_models.dart';
import 'package:triva_app/features/sales_contact/presentation/sales_contact_picker.dart';

void main() {
  test('repository parses contacts and drops those without WhatsApp', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'data': [
                {
                  'id': 's1',
                  'name': 'Sari SPV',
                  'role': 'spv',
                  'role_label': 'Supervisor (SPV)',
                  'whatsapp_number': '6281300001111',
                  'photo_url': null,
                },
                {
                  'id': 's2',
                  'name': 'Budi Sales',
                  'role': 'sales',
                  'role_label': 'Sales',
                  'whatsapp_number': '6281234567890',
                  'photo_url': 'https://cdn.test/budi.jpg',
                },
                {'id': 's3', 'name': 'Tanpa nomor', 'role': 'sales'},
              ],
            },
          ),
        ),
      ),
    );

    final directory = await SalesContactRepository(dio: dio).list();

    expect(directory.contacts, hasLength(2));
    expect(directory.supervisors.single.name, 'Sari SPV');
    expect(directory.sales.single.hasPhoto, isTrue);
    expect(directory.defaultSupervisor?.id, 's1');
  });

  test('default supervisor falls back to the first sales', () {
    const directory = SalesDirectory([
      SalesContact(
        id: 'a',
        name: 'Andi',
        role: 'sales',
        whatsappNumber: '628',
      ),
    ]);
    expect(directory.defaultSupervisor?.id, 'a');
    expect(const SalesDirectory([]).defaultSupervisor, isNull);
  });

  testWidgets('picker lists sales and offers the supervisor fallback',
      (tester) async {
    const directory = SalesDirectory([
      SalesContact(
        id: 's1',
        name: 'Sari SPV',
        role: 'spv',
        roleLabel: 'Supervisor (SPV)',
        whatsappNumber: '6281300001111',
      ),
      SalesContact(
        id: 's2',
        name: 'Budi Sales',
        role: 'sales',
        roleLabel: 'Sales',
        whatsappNumber: '6281234567890',
      ),
    ]);
    SalesContact? chosen;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                chosen = await showSalesContactPicker(
                  context,
                  directory: directory,
                );
              },
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    expect(find.text('Hubungi sales'), findsOneWidget);
    expect(find.text('Budi Sales'), findsOneWidget);
    expect(find.text('Belum ada sales'), findsOneWidget);
    expect(find.textContaining('Sari SPV'), findsOneWidget);
    // SPV tidak tampil sebagai pilihan sales biasa.
    expect(find.byKey(const ValueKey('sales-contact-s1')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('sales-contact-none')));
    await tester.pumpAndSettle();
    expect(chosen?.id, 's1');
    expect(tester.takeException(), isNull);
  });
}
