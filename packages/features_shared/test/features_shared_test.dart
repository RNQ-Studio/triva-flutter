import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('holds id, name, email', () {
      const user = User(id: '1', name: 'Alice', email: 'alice@example.com');
      expect(user.id, '1');
      expect(user.name, 'Alice');
      expect(user.email, 'alice@example.com');
    });
  });

  test('Body Paint notification keeps its estimate deep-link identity', () {
    final notification = AppNotification(
      id: 'notification-1',
      title: 'Estimasi siap',
      body: 'BP-001 siap dilihat.',
      createdAt: DateTime(2026, 7, 28),
      type: 'body_paint_estimate',
      data: const {'body_paint_estimate_id': 'estimate-1'},
    );

    expect(notification.bodyPaintEstimateId, 'estimate-1');
    expect(notification.toyotaServiceBookingId, isNull);
  });

  test('Appraisal completion notification resolves its result deep link', () {
    final notification = AppNotification(
      id: 'notification-2',
      title: 'Hasil appraisal tersedia',
      body: 'TIA-001 siap dilihat.',
      createdAt: DateTime(2026, 7, 30),
      type: 'appraisal_result_ready',
      data: const {'appraisal_id': 'appraisal-1'},
    );

    expect(notification.appraisalId, 'appraisal-1');
    expect(notification.appraisalRoute, '/appraisals/appraisal-1/result');
    expect(notification.bodyPaintEstimateId, isNull);
  });
}
