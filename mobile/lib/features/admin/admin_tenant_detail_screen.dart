import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../employees/employee.dart';
import 'admin_providers.dart';
import 'admin_tenant.dart';
import 'license_status.dart';

class AdminTenantDetailScreen extends ConsumerStatefulWidget {
  const AdminTenantDetailScreen({super.key, required this.tenant});

  final AdminTenant tenant;

  @override
  ConsumerState<AdminTenantDetailScreen> createState() => _AdminTenantDetailScreenState();
}

class _AdminTenantDetailScreenState extends ConsumerState<AdminTenantDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late String _licenseStatus;
  bool _isSavingDetails = false;
  bool _isSavingLicense = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant.businessName);
    _typeController = TextEditingController(text: widget.tenant.businessType ?? '');
    _licenseStatus = widget.tenant.licenseStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    setState(() {
      _isSavingDetails = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await ref.read(adminTenantsControllerProvider.notifier).updateTenant(
            widget.tenant.id,
            businessName: _nameController.text.trim(),
            businessType: _typeController.text.trim(),
          );
      setState(() => _successMessage = 'Negocio actualizado');
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSavingDetails = false);
    }
  }

  Future<void> _changeLicense(String status) async {
    setState(() {
      _isSavingLicense = true;
      _errorMessage = null;
    });
    try {
      await ref.read(adminTenantsControllerProvider.notifier).updateLicense(widget.tenant.id, status);
      setState(() => _licenseStatus = status);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSavingLicense = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tenant.businessName)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Licencia', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final status in licenseStatusOptions)
                      ChoiceChip(
                        label: Text(licenseStatusLabel(status)),
                        selected: _licenseStatus == status,
                        onSelected: _isSavingLicense ? null : (_) => _changeLicense(status),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Datos del negocio', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Tipo de negocio'),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                ],
                if (_successMessage != null) ...[
                  Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 16),
                ],
                FilledButton(
                  onPressed: _isSavingDetails ? null : _saveDetails,
                  child: _isSavingDetails
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Guardar cambios'),
                ),
                const SizedBox(height: 32),
                if (widget.tenant.owners.isNotEmpty) ...[
                  Text('Dueño', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final owner in widget.tenant.owners)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(owner.email),
                      subtitle: Text(owner.phone ?? 'Sin teléfono'),
                    ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('Empleados', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _TenantEmployeesSection(tenantId: widget.tenant.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TenantEmployeesSection extends ConsumerWidget {
  const _TenantEmployeesSection({required this.tenantId});

  final String tenantId;

  String _permissionsSummary(Employee employee) {
    final perms = <String>[
      if (employee.canManageProducts) 'Inventario',
      if (employee.canDeleteProducts) 'Eliminar productos',
      if (employee.canCreateInvoices) 'Facturar',
      if (employee.canViewReports) 'Reportes',
    ];
    return perms.isEmpty ? 'Sin permisos asignados' : perms.join(' · ');
  }

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
      await ref.read(adminTenantEmployeesControllerProvider(tenantId).notifier).removeEmployee(employee.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(adminTenantEmployeesControllerProvider(tenantId));

    return employeesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
      data: (employees) {
        if (employees.isEmpty) {
          return const Text('Este negocio todavía no tiene empleados.');
        }
        return Column(
          children: [
            for (final employee in employees)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: Text(employee.email),
                subtitle: Text(_permissionsSummary(employee)),
                onTap: () => _showEditEmployeeDialog(context, ref, tenantId, employee),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, employee),
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> _showEditEmployeeDialog(
  BuildContext context,
  WidgetRef ref,
  String tenantId,
  Employee employee,
) {
  return showDialog(
    context: context,
    builder: (context) => _AdminEmployeeEditDialog(tenantId: tenantId, employee: employee),
  );
}

class _AdminEmployeeEditDialog extends ConsumerStatefulWidget {
  const _AdminEmployeeEditDialog({required this.tenantId, required this.employee});

  final String tenantId;
  final Employee employee;

  @override
  ConsumerState<_AdminEmployeeEditDialog> createState() => _AdminEmployeeEditDialogState();
}

class _AdminEmployeeEditDialogState extends ConsumerState<_AdminEmployeeEditDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late bool _canManageProducts;
  late bool _canDeleteProducts;
  late bool _canCreateInvoices;
  late bool _canViewReports;
  final _resetPasswordController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.employee.email);
    _phoneController = TextEditingController(text: widget.employee.phone ?? '');
    _canManageProducts = widget.employee.canManageProducts;
    _canDeleteProducts = widget.employee.canDeleteProducts;
    _canCreateInvoices = widget.employee.canCreateInvoices;
    _canViewReports = widget.employee.canViewReports;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _resetPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await ref.read(adminTenantEmployeesControllerProvider(widget.tenantId).notifier).updateEmployee(
            widget.employee.id,
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            canManageProducts: _canManageProducts,
            canDeleteProducts: _canDeleteProducts,
            canCreateInvoices: _canCreateInvoices,
            canViewReports: _canViewReports,
          );
      setState(() => _successMessage = 'Empleado actualizado');
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_resetPasswordController.text.length < 8) {
      setState(() => _errorMessage = 'Mínimo 8 caracteres');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await ref
          .read(adminTenantEmployeesControllerProvider(widget.tenantId).notifier)
          .resetPassword(widget.employee.id, _resetPasswordController.text);
      _resetPasswordController.clear();
      setState(() => _successMessage = 'Contraseña restablecida');
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.employee.email),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Gestionar inventario'),
                value: _canManageProducts,
                onChanged: (value) => setState(() => _canManageProducts = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Eliminar productos'),
                value: _canDeleteProducts,
                onChanged: (value) => setState(() => _canDeleteProducts = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Facturar'),
                value: _canCreateInvoices,
                onChanged: (value) => setState(() => _canCreateInvoices = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ver reportes'),
                value: _canViewReports,
                onChanged: (value) => setState(() => _canViewReports = value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text('Restablecer contraseña', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _resetPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSaving ? null : _resetPassword,
                child: const Text('Restablecer contraseña'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                Text(_successMessage!, style: const TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
      ],
    );
  }
}
