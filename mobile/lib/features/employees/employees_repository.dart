import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'employee.dart';

class EmployeesRepository {
  EmployeesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Employee>> list() async {
    try {
      final response = await _apiClient.dio.get('/employees');
      return (response.data as List).map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Employee> create({
    required String email,
    required String password,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    try {
      final response = await _apiClient.dio.post('/employees', data: {
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'canManageProducts': canManageProducts,
        'canDeleteProducts': canDeleteProducts,
        'canCreateInvoices': canCreateInvoices,
        'canViewReports': canViewReports,
      });
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Employee> update(
    String id, {
    required String email,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/employees/$id', data: {
        'email': email,
        'phone': phone,
        'canManageProducts': canManageProducts,
        'canDeleteProducts': canDeleteProducts,
        'canCreateInvoices': canCreateInvoices,
        'canViewReports': canViewReports,
      });
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> resetPassword(String id, String newPassword) async {
    try {
      await _apiClient.dio.patch('/employees/$id/reset-password', data: {'newPassword': newPassword});
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> remove(String id) async {
    try {
      await _apiClient.dio.delete('/employees/$id');
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
