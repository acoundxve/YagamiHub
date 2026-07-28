import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_storage.dart';
import 'auth_user.dart';
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

  Future<AuthUser> fetchMe() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<AuthUser> updateProfile({String? email, String? phone}) async {
    try {
      final response = await _apiClient.dio.patch('/auth/me', data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      });
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _apiClient.dio.patch('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
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

  Future<Tenant> updateBusiness({
    required String businessName,
    String? businessType,
    bool? isPublished,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/tenants/me', data: {
        'businessName': businessName,
        if (businessType != null) 'businessType': businessType,
        if (isPublished != null) 'isPublished': isPublished,
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
