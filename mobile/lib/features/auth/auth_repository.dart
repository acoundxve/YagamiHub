import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_storage.dart';
import 'tenant.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> register({
    required String businessName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'businessName': businessName,
        'email': email,
        'password': password,
      });
      await _tokenStorage.saveToken(response.data['accessToken'] as String);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _tokenStorage.saveToken(response.data['accessToken'] as String);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Tenant> fetchMyTenant() async {
    try {
      final response = await _apiClient.dio.get('/tenants/me');
      return Tenant.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Tenant> updateBusinessName(String businessName) async {
    try {
      final response = await _apiClient.dio.patch('/tenants/me', data: {
        'businessName': businessName,
      });
      return Tenant.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<bool> hasStoredToken() async {
    final token = await _tokenStorage.readToken();
    return token != null;
  }

  Future<void> logout() => _tokenStorage.clearToken();
}
