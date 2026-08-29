/// Gender pelanggan sebagaimana disimpan backend.
enum Gender {
  male('male'),
  female('female'),
  undisclosed('undisclosed');

  const Gender(this.apiValue);

  final String apiValue;

  static Gender? fromApiValue(String? value) {
    if (value == null) return null;
    for (final gender in values) {
      if (gender.apiValue == value) return gender;
    }
    return null;
  }
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.gender,
    this.birthDate,
    this.avatarUrl,
    this.profileCompleted = false,
    this.demographicsCompleted = false,
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
  final Gender? gender;
  final DateTime? birthDate;
  final String? avatarUrl;
  final bool profileCompleted;

  /// Gender dan tanggal lahir sudah terisi.
  ///
  /// Dipisahkan dari [profileCompleted] karena backend sengaja tidak
  /// memperketat flag lama demi pemasangan aplikasi versi sebelumnya.
  final bool demographicsCompleted;
  final DateTime? serviceConsentAt;
  final bool marketingConsent;
  final List<String> roles;
  final List<String> permissions;

  /// Semua isian wajib pra-pemakaian sudah terisi.
  bool get hasCompleteProfile => profileCompleted && demographicsCompleted;

  /// Umur dalam tahun penuh, atau null bila tanggal lahir belum diisi.
  int? age({DateTime? now}) {
    final birth = birthDate;
    if (birth == null) return null;
    final reference = now ?? DateTime.now();
    var years = reference.year - birth.year;
    final hadBirthday = reference.month > birth.month ||
        (reference.month == birth.month && reference.day >= birth.day);
    if (!hadBirthday) years -= 1;
    return years < 0 ? null : years;
  }

  bool get isAdmin => roles.any(
        (role) =>
            role.toLowerCase() == 'admin' ||
            role.toLowerCase() == 'super-admin',
      );

  bool get canAccessAdminPanel =>
      canViewAnyServiceBookings ||
      canViewAnyBodyPaintEstimates ||
      canManageUsers ||
      canViewVisitAnalytics;

  bool get canViewVisitAnalytics =>
      _isSuperAdmin || permissions.contains('analytics.viewAny');

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
