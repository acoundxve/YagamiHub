import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import 'employee.dart';
import 'employees_repository.dart';

final employeesRepositoryProvider = Provider(
  (ref) => EmployeesRepository(ref.watch(apiClientProvider)),
);

class EmployeesController extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() {
    return ref.read(employeesRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(employeesRepositoryProvider).list());
  }

  Future<void> createEmployee({
    required String email,
    required String password,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    await ref.read(employeesRepositoryProvider).create(
          email: email,
          password: password,
          phone: phone,
          canManageProducts: canManageProducts,
          canDeleteProducts: canDeleteProducts,
          canCreateInvoices: canCreateInvoices,
          canViewReports: canViewReports,
        );
    await refresh();
  }

  Future<void> updateEmployee(
    String id, {
    required String email,
    String? phone,
    required bool canManageProducts,
    required bool canDeleteProducts,
    required bool canCreateInvoices,
    required bool canViewReports,
  }) async {
    await ref.read(employeesRepositoryProvider).update(
          id,
          email: email,
          phone: phone,
          canManageProducts: canManageProducts,
          canDeleteProducts: canDeleteProducts,
          canCreateInvoices: canCreateInvoices,
          canViewReports: canViewReports,
        );
    await refresh();
  }

  Future<void> resetPassword(String id, String newPassword) {
    return ref.read(employeesRepositoryProvider).resetPassword(id, newPassword);
  }

  Future<void> removeEmployee(String id) async {
    await ref.read(employeesRepositoryProvider).remove(id);
    await refresh();
  }
}

final employeesControllerProvider = AsyncNotifierProvider<EmployeesController, List<Employee>>(
  EmployeesController.new,
);
