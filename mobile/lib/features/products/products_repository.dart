import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'product.dart';

class ProductsRepository {
  ProductsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> list() async {
    try {
      final response = await _apiClient.dio.get('/products');
      return (response.data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Product> create({
    required String name,
    String? sku,
    required double costPrice,
    required double salePrice,
    required int stockQty,
  }) async {
    try {
      final response = await _apiClient.dio.post('/products', data: {
        'name': name,
        if (sku != null && sku.isNotEmpty) 'sku': sku,
        'costPrice': costPrice,
        'salePrice': salePrice,
        'stockQty': stockQty,
      });
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Product> update(
    String id, {
    required String name,
    String? sku,
    required double costPrice,
    required double salePrice,
    required int stockQty,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/products/$id', data: {
        'name': name,
        'sku': sku,
        'costPrice': costPrice,
        'salePrice': salePrice,
        'stockQty': stockQty,
      });
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiClient.dio.delete('/products/$id');
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
