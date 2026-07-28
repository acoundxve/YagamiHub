class TenantOwner {
  TenantOwner({required this.id, required this.email, required this.phone, required this.role});

  factory TenantOwner.fromJson(Map<String, dynamic> json) => TenantOwner(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String,
      );

  final String id;
  final String email;
  final String? phone;
  final String role;
}

class AdminTenant {
  AdminTenant({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.slug,
    required this.licenseStatus,
    required this.owners,
  });

  factory AdminTenant.fromJson(Map<String, dynamic> json) => AdminTenant(
        id: json['id'] as String,
        businessName: json['businessName'] as String,
        businessType: json['businessType'] as String?,
        slug: json['slug'] as String,
        licenseStatus: json['licenseStatus'] as String,
        owners: (json['users'] as List? ?? [])
            .map((e) => TenantOwner.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String businessName;
  final String? businessType;
  final String slug;
  final String licenseStatus;
  final List<TenantOwner> owners;
}
