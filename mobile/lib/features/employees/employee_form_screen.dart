import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employee.dart';
import 'employees_providers.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key, this.existingEmployee});

  final Employee? existingEmployee;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();

  late bool _canManageProducts;
  late bool _canDeleteProducts;
  late bool _canCreateInvoices;
  late bool _canViewReports;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  final _resetPasswordController = TextEditingController();
  bool _isResettingPassword = false;
  String? _resetError;
  String? _resetSuccess;

  bool get _isEditing => widget.existingEmployee != null;

  @override
  void initState() {
    super.initState();
    final employee = widget.existingEmployee;
    _emailController = TextEditingController(text: employee?.email ?? '');
    _phoneController = TextEditingController(text: employee?.phone ?? '');
    _canManageProducts = employee?.canManageProducts ?? false;
    _canDeleteProducts = employee?.canDeleteProducts ?? false;
    _canCreateInvoices = employee?.canCreateInvoices ?? false;
    _canViewReports = employee?.canViewReports ?? false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _resetPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final controller = ref.read(employeesControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateEmployee(
          widget.existingEmployee!.id,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          canManageProducts: _canManageProducts,
          canDeleteProducts: _canDeleteProducts,
          canCreateInvoices: _canCreateInvoices,
          canViewReports: _canViewReports,
        );
        if (!mounted) return;
        setState(() => _successMessage = 'Empleado actualizado');
      } else {
        await controller.createEmployee(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          canManageProducts: _canManageProducts,
          canDeleteProducts: _canDeleteProducts,
          canCreateInvoices: _canCreateInvoices,
          canViewReports: _canViewReports,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_resetPasswordController.text.length < 8) {
      setState(() => _resetError = 'Mínimo 8 caracteres');
      return;
    }
    setState(() {
      _isResettingPassword = true;
      _resetError = null;
      _resetSuccess = null;
    });
    try {
      await ref
          .read(employeesControllerProvider.notifier)
          .resetPassword(widget.existingEmployee!.id, _resetPasswordController.text);
      _resetPasswordController.clear();
      setState(() => _resetSuccess = 'Contraseña restablecida');
    } catch (error) {
      setState(() => _resetError = error.toString());
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar empleado' : 'Nuevo empleado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                      ),
                      if (!_isEditing) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Contraseña inicial'),
                          validator: (value) =>
                              value == null || value.length < 8 ? 'Mínimo 8 caracteres' : null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Permisos', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'Elige a qué partes de la app tendrá acceso este empleado.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Gestionar inventario'),
                        subtitle: const Text('Ver, crear y editar productos'),
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
                        title: const Text('Facturar (ventas rápidas)'),
                        subtitle: const Text('Crear y ver facturas'),
                        value: _canCreateInvoices,
                        onChanged: (value) => setState(() => _canCreateInvoices = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ver ganancias y pérdidas'),
                        value: _canViewReports,
                        onChanged: (value) => setState(() => _canViewReports = value),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null) ...[
                        Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        const SizedBox(height: 16),
                      ],
                      if (_successMessage != null) ...[
                        Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                        const SizedBox(height: 16),
                      ],
                      FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_isEditing ? 'Guardar cambios' : 'Crear empleado'),
                      ),
                    ],
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Restablecer contraseña', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _resetPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                  ),
                  const SizedBox(height: 16),
                  if (_resetError != null) ...[
                    Text(_resetError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                  ],
                  if (_resetSuccess != null) ...[
                    Text(_resetSuccess!, style: const TextStyle(color: Colors.green)),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _isResettingPassword ? null : _resetPassword,
                    child: _isResettingPassword
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Restablecer contraseña'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
