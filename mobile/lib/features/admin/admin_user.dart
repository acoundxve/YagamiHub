class AdminUserTenant {
  AdminUserTenant({required this.id, required this.businessName});

  factory AdminUserTenant.fromJson(Map<String, dynamic> json) =>
      AdminUserTenant(id: json['id'] as String, businessName: json['businessName'] as String);

  final String id;
  final String businessName;
}

class AdminUser {
  AdminUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.tenant,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String,
        tenant: json['tenant'] == null
            ? null
            : AdminUserTenant.fromJson(json['tenant'] as Map<String, dynamic>),
      );

  final String id;
  final String email;
  final String? phone;
  final String role;
  final AdminUserTenant? tenant;
}
