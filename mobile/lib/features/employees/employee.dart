class Employee {
  Employee({
    required this.id,
    required this.email,
    required this.phone,
    required this.canManageProducts,
    required this.canDeleteProducts,
    required this.canCreateInvoices,
    required this.canViewReports,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        canManageProducts: json['canManageProducts'] as bool? ?? false,
        canDeleteProducts: json['canDeleteProducts'] as bool? ?? false,
        canCreateInvoices: json['canCreateInvoices'] as bool? ?? false,
        canViewReports: json['canViewReports'] as bool? ?? false,
      );

  final String id;
  final String email;
  final String? phone;
  final bool canManageProducts;
  final bool canDeleteProducts;
  final bool canCreateInvoices;
  final bool canViewReports;
}
