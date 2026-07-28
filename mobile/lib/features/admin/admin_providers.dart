import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../employees/employee.dart';
import 'admin_repository.dart';
import 'admin_tenant.dart';
import 'admin_user.dart';

final adminRepositoryProvider = Provider(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

class AdminTenantsController extends AsyncNotifier<List<AdminTenant>> {
  @override
  Future<List<AdminTenant>> build() {
    return ref.read(adminRepositoryProvider).fetchTenants();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).fetchTenants());
  }

  Future<void> updateTenant(String id, {String? businessName, String? businessType}) async {
    await ref.read(adminRepositoryProvider).updateTenant(id, businessName: businessName, businessType: businessType);
    await refresh();
  }

  Future<void> updateLicense(String id, String licenseStatus) async {
    await ref.read(adminRepositoryProvider).updateTenantLicense(id, licenseStatus);
    await refresh();
  }
}

final adminTenantsControllerProvider = AsyncNotifierProvider<AdminTenantsController, List<AdminTenant>>(
  AdminTenantsController.new,
);

class AdminUsersController extends AsyncNotifier<List<AdminUser>> {
  @override
  Future<List<AdminUser>> build() {
    return ref.read(adminRepositoryProvider).fetchUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).fetchUsers());
  }

  Future<void> updateUser(String id, {String? email, String? phone, String? role}) async {
    await ref.read(adminRepositoryProvider).updateUser(id, email: email, phone: phone, role: role);
    await refresh();
  }

  Future<void> resetPassword(String id, String newPassword) {
    return ref.read(adminRepositoryProvider).resetUserPassword(id, newPassword);
  }
}

final adminUsersControllerProvider = AsyncNotifierProvider<AdminUsersController, List<AdminUser>>(
  AdminUsersController.new,
);

class AdminTenantEmployeesController extends FamilyAsyncNotifier<List<Employee>, String> {
  @override
  Future<List<Employee>> build(String arg) {
    return ref.read(adminRepositoryProvider).fetchTenantEmployees(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).fetchTenantEmployees(arg));
  }

  Future<void> updateEmployee(
    String employeeId, {
    required String email,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    await ref.read(adminRepositoryProvider).updateTenantEmployee(
          arg,
          employeeId,
          email: email,
          phone: phone,
          canManageProducts: canManageProducts,
          canDeleteProducts: canDeleteProducts,
          canCreateInvoices: canCreateInvoices,
          canViewReports: canViewReports,
        );
    await refresh();
  }

  Future<void> resetPassword(String employeeId, String newPassword) {
    return ref.read(adminRepositoryProvider).resetTenantEmployeePassword(arg, employeeId, newPassword);
  }

  Future<void> removeEmployee(String employeeId) async {
    await ref.read(adminRepositoryProvider).removeTenantEmployee(arg, employeeId);
    await refresh();
  }
}

final adminTenantEmployeesControllerProvider =
    AsyncNotifierProvider.family<AdminTenantEmployeesController, List<Employee>, String>(
  AdminTenantEmployeesController.new,
);
