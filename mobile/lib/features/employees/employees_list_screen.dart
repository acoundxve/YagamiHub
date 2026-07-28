import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'employee.dart';
import 'employees_providers.dart';

class EmployeesListScreen extends ConsumerWidget {
  const EmployeesListScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text('¿Seguro que quieres eliminar el acceso de "${employee.email}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(employeesControllerProvider.notifier).removeEmployee(employee.id);
    }
  }

  String _permissionsSummary(Employee employee) {
    final perms = <String>[
      if (employee.canManageProducts) 'Inventario',
      if (employee.canDeleteProducts) 'Eliminar productos',
      if (employee.canCreateInvoices) 'Facturar',
      if (employee.canViewReports) 'Reportes',
    ];
    return perms.isEmpty ? 'Sin permisos asignados' : perms.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(child: Text('Todavía no has agregado empleados.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(employeesControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: employees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  title: Text(employee.email),
                  subtitle: Text(_permissionsSummary(employee)),
                  onTap: () => context.push('/employees/${employee.id}', extra: employee),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, employee),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/employees/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
