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
}
