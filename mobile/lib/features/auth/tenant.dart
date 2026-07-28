class Tenant {
  Tenant({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.slug,
    required this.isPublished,
    required this.licenseStatus,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as String,
        businessName: json['businessName'] as String,
        businessType: json['businessType'] as String?,
        slug: json['slug'] as String,
        isPublished: json['isPublished'] as bool? ?? false,
        licenseStatus: json['licenseStatus'] as String,
      );

  final String id;
  final String businessName;
  final String? businessType;
  final String slug;
  final bool isPublished;
  final String licenseStatus;
}
