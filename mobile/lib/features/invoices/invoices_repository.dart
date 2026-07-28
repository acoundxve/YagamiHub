import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'invoice.dart';

class InvoiceItemInput {
  InvoiceItemInput({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}

class InvoicesRepository {
  InvoicesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Invoice>> list() async {
    try {
      final response = await _apiClient.dio.get('/invoices');
      return (response.data as List).map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Invoice> create({
    required String customerName,
    required List<InvoiceItemInput> items,
  }) async {
    try {
      final response = await _apiClient.dio.post('/invoices', data: {
        'customerName': customerName,
        'items': items.map((e) => e.toJson()).toList(),
      });
      return Invoice.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
