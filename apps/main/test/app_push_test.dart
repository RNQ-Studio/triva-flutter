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

  test('appraisal completion notification opens the result directly', () {
    expect(
      notificationTarget(const {
        'type': 'appraisal_result_ready',
        'appraisal_id': 'appraisal-123',
        'route': '/appraisals/appraisal-123/result',
      }),
      '/appraisals/appraisal-123/result',
    );
  });

  test('failed appraisal notification opens progress and rejects unsafe IDs',
      () {
    expect(
      notificationTarget(const {
        'type': 'appraisal_processing_failed',
        'appraisal_id': 'appraisal-123',
      }),
      '/appraisals/appraisal-123',
    );
    expect(
      notificationTarget(const {
        'type': 'appraisal_result_ready',
        'appraisal_id': '../admin',
        'route': '/appraisals/../admin',
      }),
      isNull,
    );
  });
}
