class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.roles,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        isAdmin: json['is_admin'] as bool? ?? false,
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String email;
  final bool isActive;
  final bool isAdmin;
  final List<String> roles;
}

class AdminUserPage {
  const AdminUserPage({
    required this.users,
    required this.currentPage,
    required this.lastPage,
  });

  final List<AdminUser> users;
  final int currentPage;
  final int lastPage;
}
