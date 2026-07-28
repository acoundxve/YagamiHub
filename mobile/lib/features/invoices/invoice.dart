class InvoiceItem {
  InvoiceItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        quantity: json['quantity'] as int,
        unitPrice: double.parse(json['unitPrice'].toString()),
        subtotal: double.parse(json['subtotal'].toString()),
      );

  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
}

class Invoice {
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.status,
    required this.issueDate,
    required this.total,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        customerName: json['customerName'] as String,
        status: json['status'] as String,
        issueDate: DateTime.parse(json['issueDate'] as String),
        total: double.parse(json['total'].toString()),
        items: (json['items'] as List? ?? [])
            .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String invoiceNumber;
  final String customerName;
  final String status;
  final DateTime issueDate;
  final double total;
  final List<InvoiceItem> items;
}
