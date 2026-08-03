import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triva_app/features/appraisal/presentation/widgets/appraisal_flow_scaffold.dart';
import 'package:triva_app/features/toyota_service/presentation/widgets/toyota_service_widgets.dart';

void main() {
  testWidgets('direct appraisal step uses its logical fallback on system back',
      (tester) async {
    final router = _router(
      initialLocation: '/step',
      step: const AppraisalFlowScaffold(
        step: 2,
        title: 'Kondisi',
        description: 'Isi kondisi kendaraan',
        body: SizedBox.shrink(),
        primaryLabel: 'Lanjut',
        onPrimary: null,
        fallbackLocation: '/previous',
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();
    expect(find.text('Kondisi'), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Langkah sebelumnya'), findsOneWidget);
  });

  testWidgets('direct Toyota step uses its logical fallback from app bar',
      (tester) async {
    final router = _router(
      initialLocation: '/step',
      step: const ToyotaServiceFlowScaffold(
        step: 2,
        title: 'Jadwal',
        description: 'Pilih jadwal servis',
        body: SizedBox.shrink(),
        primaryLabel: 'Lanjut',
        onPrimary: null,
        fallbackLocation: '/previous',
      ),
    );
    addTearDown(router.dispose);

    await _pump(tester, router);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Langkah sebelumnya'), findsOneWidget);
  });

  testWidgets('real route history takes priority over a logical fallback',
      (tester) async {
    final router = _router(
      step: const AppraisalFlowScaffold(
        step: 1,
        title: 'Identitas',
        description: 'Isi identitas kendaraan',
        body: SizedBox.shrink(),
        primaryLabel: 'Lanjut',
        onPrimary: null,
        fallbackLocation: '/previous',
      ),
    );
    addTearDown(router.dispose);

    await _pump(tester, router);
    unawaited(router.push<void>('/step'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Langkah sebelumnya'), findsNothing);
  });

  testWidgets('busy flow cannot leave while its request is in flight',
      (tester) async {
    final router = _router(
      initialLocation: '/step',
      step: const AppraisalFlowScaffold(
        step: 4,
        title: 'Review',
        description: 'Sedang mengirim appraisal',
        body: SizedBox.shrink(),
        primaryLabel: 'Kirim',
        primaryBusy: true,
        onPrimary: null,
        fallbackLocation: '/previous',
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pump();

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Langkah sebelumnya'), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });
}

GoRouter _router({required Widget step, String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Beranda')),
        ),
      ),
      GoRoute(
        path: '/previous',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Langkah sebelumnya')),
        ),
      ),
      GoRoute(path: '/step', builder: (_, __) => step),
    ],
  );
}

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light,
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();
}
