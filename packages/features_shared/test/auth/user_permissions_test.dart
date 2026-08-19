import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin capabilities and role identity remain distinct', () {
    User userWith(
      List<String> permissions, {
      List<String> roles = const [],
    }) =>
        User(
          id: 'user',
          name: 'User',
          email: 'user@example.com',
          profileCompleted: true,
          permissions: permissions,
          roles: roles,
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
    expect(
      userWith(const ['analytics.viewAny']).canAccessAdminPanel,
      isTrue,
    );
    expect(
      userWith(const ['analytics.viewAny']).canViewVisitAnalytics,
      isTrue,
    );
    expect(
      userWith(
        const ['users.viewAny', 'users.update'],
        roles: const ['admin'],
      ).canManageUsers,
      isTrue,
    );
    expect(
      userWith(const ['users.viewAny'], roles: const ['staff']).canManageUsers,
      isFalse,
    );
    expect(
      userWith(const [], roles: const ['admin']).isAdmin,
      isTrue,
    );
    expect(
      userWith(const [], roles: const ['staff']).isAdmin,
      isFalse,
    );
  });
}
