import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/app.dart';

void main() {
  test('auth-time push sync absorbs token lookup failure', () async {
    var registered = false;

    await expectLater(
      syncPushTokenSafely(
        getToken: () async => throw StateError('APNS token not ready'),
        register: (_) async => registered = true,
      ),
      completes,
    );

    expect(registered, isFalse);
  });
}
