enum UserRole { owner, superAdmin }

UserRole userRoleFromJson(String value) => switch (value) {
      'SUPER_ADMIN' => UserRole.superAdmin,
      _ => UserRole.owner,
    };

class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.tenantId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: userRoleFromJson(json['role'] as String),
        tenantId: json['tenantId'] as String?,
      );

  final String id;
  final String email;
  final String? phone;
  final UserRole role;
  final String? tenantId;
}
