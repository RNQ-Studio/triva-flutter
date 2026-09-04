import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/maintenance_estimate/presentation/maintenance_estimate_paths.dart';
import 'package:triva_app/features/otoxpert/presentation/otoxpert_paths.dart';
import 'package:triva_app/features/otoxpert/presentation/screens/otoxpert_menu_screen.dart';
import 'package:triva_app/features/vehicle_benefit/presentation/vehicle_benefit_paths.dart';
import 'package:triva_app/features/visit_analytics/data/menu_usage_reporter.dart';
import 'package:triva_app/features/visit_analytics/presentation/visit_analytics_controller.dart';

void main() {
  testWidgets('OtoXpert menu offers booking, frame check and cost simulation',
      (tester) async {
    final visited = <String>[];
    final router = GoRouter(
      initialLocation: otoxpertPath,
      routes: [
        GoRoute(
          path: otoxpertPath,
          builder: (_, __) => const OtoxpertMenuScreen(),
        ),
        for (final path in [
          otoxpertBookingIntakePath,
          vehicleBenefitCheckPath,
          maintenanceEstimatePath,
        ])
          GoRoute(
            path: path,
            builder: (_, state) {
              visited.add(state.uri.path);
              return Scaffold(body: Text('at $path'));
            },
          ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          menuUsageReporterProvider.overrideWithValue(
            MenuUsageReporter(
              Dio(),
              source: null,
              appInfo: () async => (version: '', build: ''),
            ),
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

    expect(find.text('OtoXpert'), findsOneWidget);
    expect(find.text('Booking OtoXpert'), findsOneWidget);
    expect(find.text('Cek No. Rangka'), findsOneWidget);
    expect(find.text('Simulasi biaya servis'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('otoxpert-menu-benefit')));
    await tester.pumpAndSettle();
    expect(visited, [vehicleBenefitCheckPath]);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('otoxpert-menu-maintenance')));
    await tester.pumpAndSettle();
    expect(visited.last, maintenanceEstimatePath);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('otoxpert-menu-booking')));
    await tester.pumpAndSettle();
    expect(visited.last, otoxpertBookingIntakePath);
    expect(tester.takeException(), isNull);
  });
}
