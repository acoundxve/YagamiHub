import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'public_business.dart';

class PublicRepository {
  PublicRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PublicBusiness> fetchBySlug(String slug) async {
    try {
      final response = await _apiClient.dio.get('/public/$slug');
      return PublicBusiness.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
