class Product {
  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.costPrice,
    required this.salePrice,
    required this.stockQty,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String?,
        costPrice: double.parse(json['costPrice'].toString()),
        salePrice: double.parse(json['salePrice'].toString()),
        stockQty: json['stockQty'] as int,
      );

  final String id;
  final String name;
  final String? sku;
  final double costPrice;
  final double salePrice;
  final int stockQty;
}
