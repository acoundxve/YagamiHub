class PublicBusiness {
  PublicBusiness({required this.businessName, required this.businessType, required this.slug});

  factory PublicBusiness.fromJson(Map<String, dynamic> json) => PublicBusiness(
        businessName: json['businessName'] as String,
        businessType: json['businessType'] as String?,
        slug: json['slug'] as String,
      );

  final String businessName;
  final String? businessType;
  final String slug;
}
