import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/domain/appraisal_models.dart';
import 'package:triva_app/features/appraisal/presentation/appraisal_controller.dart';
import 'package:triva_app/features/appraisal/presentation/screens/appraisal_activity_screen.dart';
import 'package:triva_app/features/toyota_service/domain/toyota_service_models.dart';
import 'package:triva_app/features/toyota_service/presentation/toyota_service_controller.dart';
import 'package:triva_app/features/otoxpert/presentation/otoxpert_controller.dart';

void main() {
  testWidgets('keeps booking activity visible when appraisal source fails',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appraisalsProvider.overrideWith(
            (_) async => throw StateError('appraisal offline'),
          ),
          toyotaServiceBookingsProvider.overrideWith(
            (_) async => [_booking('booking-1', DateTime(2026, 7, 27))],
          ),
          otoxpertBookingsProvider.overrideWith((_) async => const []),
        ],
        child: _testApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('activity-appraisals-error')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('activity-booking-booking-1')),
      findsOneWidget,
    );
    expect(find.text('TS-booking-1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sorts mixed appraisal and booking activity by newest first',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appraisalsProvider.overrideWith(
            (_) async => [
              _appraisal('appraisal-old', DateTime(2026, 7, 25)),
              _appraisal('appraisal-new', DateTime(2026, 7, 27)),
            ],
          ),
          toyotaServiceBookingsProvider.overrideWith(
            (_) async => [_booking('booking-middle', DateTime(2026, 7, 26))],
          ),
          otoxpertBookingsProvider.overrideWith((_) async => const []),
        ],
        child: _testApp(),
      ),
    );
    await tester.pumpAndSettle();

    final newTop = tester
        .getTopLeft(
          find.byKey(const ValueKey('activity-appraisal-appraisal-new')),
        )
        .dy;
    final middleTop = tester
        .getTopLeft(
          find.byKey(const ValueKey('activity-booking-booking-middle')),
        )
        .dy;
    final oldTop = tester
        .getTopLeft(
          find.byKey(const ValueKey('activity-appraisal-appraisal-old')),
        )
        .dy;

    expect(newTop, lessThan(middleTop));
    expect(middleTop, lessThan(oldTop));
  });
}

Widget _testApp() => MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppraisalActivityScreen(),
    );

AppraisalData _appraisal(String id, DateTime submittedAt) => AppraisalData(
      id: id,
      referenceNo: 'AP-$id',
      status: 'submitted',
      statusLabel: 'Dikirim',
      submittedAt: submittedAt,
    );

ToyotaServiceBooking _booking(String id, DateTime updatedAt) =>
    ToyotaServiceBooking(
      id: id,
      referenceNo: 'TS-$id',
      status: 'awaiting_confirmation',
      statusLabel: 'Menunggu konfirmasi',
      fulfillmentType: ToyotaServiceFulfillment.workshop,
      currentMileage: 10000,
      complaint: 'Servis berkala',
      contactChannel: 'whatsapp',
      allowedCustomerActions: const [],
      timeline: const [],
      isConfirmed: false,
      updatedAt: updatedAt,
    );
