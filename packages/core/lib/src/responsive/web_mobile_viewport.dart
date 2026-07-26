import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Keeps the web app on a phone-sized canvas when the browser is desktop-wide.
class WebMobileViewport extends StatelessWidget {
  const WebMobileViewport({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (!enabled || mediaQuery.size.width < Breakpoints.mobile) {
      return child;
    }

    final theme = Theme.of(context);
    final mobileSize = Size(
      Breakpoints.mobileContentMax,
      mediaQuery.size.height,
    );

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: mobileSize.width,
          height: mobileSize.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border.symmetric(
                vertical: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: ClipRect(
              child: MediaQuery(
                data: mediaQuery.copyWith(size: mobileSize),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
