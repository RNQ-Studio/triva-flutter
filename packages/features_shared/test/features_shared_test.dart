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
}
