enum UserRole { owner, superAdmin, employee }

UserRole userRoleFromJson(String value) => switch (value) {
      'SUPER_ADMIN' => UserRole.superAdmin,
      'EMPLOYEE' => UserRole.employee,
      _ => UserRole.owner,
    };

class EmployeePermissions {
  EmployeePermissions({
    required this.canManageProducts,
    required this.canDeleteProducts,
    required this.canCreateInvoices,
    required this.canViewReports,
  });

  factory EmployeePermissions.fromJson(Map<String, dynamic> json) => EmployeePermissions(
        canManageProducts: json['canManageProducts'] as bool? ?? false,
        canDeleteProducts: json['canDeleteProducts'] as bool? ?? false,
        canCreateInvoices: json['canCreateInvoices'] as bool? ?? false,
        canViewReports: json['canViewReports'] as bool? ?? false,
      );

  final bool canManageProducts;
  final bool canDeleteProducts;
  final bool canCreateInvoices;
  final bool canViewReports;
}

class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.tenantId,
    required this.permissions,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        role: userRoleFromJson(json['role'] as String),
        tenantId: json['tenantId'] as String?,
        permissions: json['role'] == 'EMPLOYEE' ? EmployeePermissions.fromJson(json) : null,
      );

  final String id;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final String? tenantId;
  final EmployeePermissions? permissions;
}
