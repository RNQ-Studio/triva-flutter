import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.city,
    super.avatarUrl,
    super.profileCompleted,
    super.serviceConsentAt,
    super.marketingConsent,
    super.roles,
    super.permissions,
    this.token,
    this.refreshToken,
  });

  final String? token;
  final String? refreshToken;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        city: json['city'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        profileCompleted: json['profile_completed'] as bool? ?? false,
        serviceConsentAt: json['service_consent_at'] == null
            ? null
            : DateTime.tryParse(json['service_consent_at'].toString()),
        marketingConsent: json['marketing_consent'] as bool? ?? false,
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        permissions: (json['permissions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        token: json['token'] as String?,
        refreshToken: json['refresh_token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'profile_completed': profileCompleted,
        if (serviceConsentAt != null)
          'service_consent_at': serviceConsentAt!.toIso8601String(),
        'marketing_consent': marketingConsent,
        'roles': roles,
        'permissions': permissions,
        if (token != null) 'token': token,
        if (refreshToken != null) 'refresh_token': refreshToken,
      };
}
