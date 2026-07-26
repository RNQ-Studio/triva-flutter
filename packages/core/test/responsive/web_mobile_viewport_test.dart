import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setViewport(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'desktop web uses a mobile viewport in ${brightness.name} theme',
      (tester) async {
        await setViewport(tester, const Size(1440, 900));
        final theme =
            brightness == Brightness.light ? AppTheme.light : AppTheme.dark;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.3),
              ),
              child: WebMobileViewport(
                enabled: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            home: const _ViewportProbe(),
          ),
        );

        expect(
          tester.getSize(find.byKey(const ValueKey('viewport-probe'))),
          const Size(Breakpoints.mobileContentMax, 900),
        );
        expect(find.text('480 x 900'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('compact web keeps the available viewport', (tester) async {
    await setViewport(tester, const Size(360, 690));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => WebMobileViewport(
          enabled: true,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const _ViewportProbe(),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('viewport-probe'))),
      const Size(360, 690),
    );
    expect(find.text('360 x 690'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ViewportProbe extends StatelessWidget {
  const _ViewportProbe();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox.expand(
      key: const ValueKey('viewport-probe'),
      child: Text('${size.width.round()} x ${size.height.round()}'),
    );
  }
}
