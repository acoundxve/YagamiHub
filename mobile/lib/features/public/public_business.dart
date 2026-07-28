class PublicBusiness {
  PublicBusiness({
    required this.businessName,
    required this.businessType,
    required this.slug,
    required this.backgroundImageUrl,
  });

  factory PublicBusiness.fromJson(Map<String, dynamic> json) => PublicBusiness(
        businessName: json['businessName'] as String,
        businessType: json['businessType'] as String?,
        slug: json['slug'] as String,
        backgroundImageUrl: json['backgroundImageUrl'] as String?,
      );

  final String businessName;
  final String? businessType;
  final String slug;
  final String? backgroundImageUrl;
}
