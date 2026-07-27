class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.avatarUrl,
    this.profileCompleted = false,
    this.serviceConsentAt,
    this.marketingConsent = false,
    this.roles = const [],
    this.permissions = const [],
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final bool profileCompleted;
  final DateTime? serviceConsentAt;
  final bool marketingConsent;
  final List<String> roles;
  final List<String> permissions;

  bool get isAdmin => roles.any(
        (role) =>
            role.toLowerCase() == 'admin' ||
            role.toLowerCase() == 'super-admin',
      );

  bool get canAccessAdminPanel =>
      canViewAnyServiceBookings ||
      canViewAnyBodyPaintEstimates ||
      canManageUsers;

  bool get canManageUsers =>
      _isSuperAdmin ||
      (permissions.contains('users.viewAny') &&
          permissions.contains('users.update'));

  bool get canViewAnyServiceBookings =>
      _isSuperAdmin || permissions.contains('service_bookings.viewAny');

  bool get canViewServiceBooking =>
      _isSuperAdmin || permissions.contains('service_bookings.view');

  bool get canManageServiceBookings {
    return _isSuperAdmin || permissions.contains('service_bookings.update');
  }

  bool get canViewAnyBodyPaintEstimates =>
      _isSuperAdmin || permissions.contains('bp_estimates.viewAny');

  bool get canViewBodyPaintEstimate =>
      _isSuperAdmin || permissions.contains('bp_estimates.view');

  bool get canManageBodyPaintEstimates =>
      _isSuperAdmin || permissions.contains('bp_estimates.update');

  bool get _isSuperAdmin =>
      roles.any((role) => role.toLowerCase() == 'super-admin');

  bool hasPermission(String permission) => permissions.contains(permission);
}
