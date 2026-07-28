class ProductProfitLoss {
  ProductProfitLoss({
    required this.productId,
    required this.name,
    required this.stockQty,
    required this.unitsSold,
    required this.costPrice,
    required this.salePrice,
    required this.invested,
    required this.revenue,
    required this.profit,
  });

  factory ProductProfitLoss.fromJson(Map<String, dynamic> json) => ProductProfitLoss(
        productId: json['productId'] as String,
        name: json['name'] as String,
        stockQty: json['stockQty'] as int,
        unitsSold: json['unitsSold'] as int,
        costPrice: double.parse(json['costPrice'].toString()),
        salePrice: double.parse(json['salePrice'].toString()),
        invested: double.parse(json['invested'].toString()),
        revenue: double.parse(json['revenue'].toString()),
        profit: double.parse(json['profit'].toString()),
      );

  final String productId;
  final String name;
  final int stockQty;
  final int unitsSold;
  final double costPrice;
  final double salePrice;
  final double invested;
  final double revenue;
  final double profit;
}

class ProfitLossTotals {
  ProfitLossTotals({required this.invested, required this.revenue, required this.profit});

  factory ProfitLossTotals.fromJson(Map<String, dynamic> json) => ProfitLossTotals(
        invested: double.parse(json['invested'].toString()),
        revenue: double.parse(json['revenue'].toString()),
        profit: double.parse(json['profit'].toString()),
      );

  final double invested;
  final double revenue;
  final double profit;
}

class ProfitLossReport {
  ProfitLossReport({required this.products, required this.totals});

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) => ProfitLossReport(
        products: (json['products'] as List)
            .map((e) => ProductProfitLoss.fromJson(e as Map<String, dynamic>))
            .toList(),
        totals: ProfitLossTotals.fromJson(json['totals'] as Map<String, dynamic>),
      );

  final List<ProductProfitLoss> products;
  final ProfitLossTotals totals;
}
