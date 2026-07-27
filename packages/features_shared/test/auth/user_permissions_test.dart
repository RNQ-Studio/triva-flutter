import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin tab visibility exactly matches viewAny panel access', () {
    User userWith(List<String> permissions) => User(
          id: 'user',
          name: 'User',
          email: 'user@example.com',
          profileCompleted: true,
          permissions: permissions,
        );

    expect(
      userWith(const ['service_bookings.viewAny']).canAccessAdminPanel,
      isTrue,
    );
    expect(
      userWith(const ['service_bookings.view']).canAccessAdminPanel,
      isFalse,
    );
    expect(
      userWith(const ['service_bookings.update']).canAccessAdminPanel,
      isFalse,
    );
  });
}
