import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Crashlytics methods are safe no-ops on web',
    () async {
      expect(kIsWeb, isTrue);

      await expectLater(CrashlyticsService.init(), completes);
      await expectLater(
        CrashlyticsService.recordError(
          StateError('web test error'),
          StackTrace.current,
        ),
        completes,
      );
      await expectLater(
        CrashlyticsService.setUserIdentifier('web-test-user'),
        completes,
      );
      expect(
        () => CrashlyticsService.log('web test log'),
        returnsNormally,
      );
    },
    skip: !kIsWeb,
  );
}
