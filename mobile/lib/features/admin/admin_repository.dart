import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../employees/employee.dart';
import 'admin_tenant.dart';
import 'admin_user.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminTenant>> fetchTenants() async {
    try {
      final response = await _apiClient.dio.get('/tenants');
      return (response.data as List).map((e) => AdminTenant.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<AdminTenant> updateTenant(String id, {String? businessName, String? businessType}) async {
    try {
      final response = await _apiClient.dio.patch('/tenants/$id', data: {
        if (businessName != null) 'businessName': businessName,
        if (businessType != null) 'businessType': businessType,
      });
      return AdminTenant.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> updateTenantLicense(String id, String licenseStatus) async {
    try {
      await _apiClient.dio.patch('/tenants/$id/license', data: {'licenseStatus': licenseStatus});
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<List<AdminUser>> fetchUsers() async {
    try {
      final response = await _apiClient.dio.get('/users');
      return (response.data as List).map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<AdminUser> updateUser(String id, {String? email, String? phone, String? role}) async {
    try {
      final response = await _apiClient.dio.patch('/users/$id', data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
      });
      return AdminUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> resetUserPassword(String id, String newPassword) async {
    try {
      await _apiClient.dio.patch('/users/$id/reset-password', data: {'newPassword': newPassword});
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<List<Employee>> fetchTenantEmployees(String tenantId) async {
    try {
      final response = await _apiClient.dio.get('/tenants/$tenantId/employees');
      return (response.data as List).map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<Employee> updateTenantEmployee(
    String tenantId,
    String employeeId, {
    required String email,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/tenants/$tenantId/employees/$employeeId', data: {
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

  Future<void> resetTenantEmployeePassword(String tenantId, String employeeId, String newPassword) async {
    try {
      await _apiClient.dio
          .patch('/tenants/$tenantId/employees/$employeeId/reset-password', data: {'newPassword': newPassword});
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }

  Future<void> removeTenantEmployee(String tenantId, String employeeId) async {
    try {
      await _apiClient.dio.delete('/tenants/$tenantId/employees/$employeeId');
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
