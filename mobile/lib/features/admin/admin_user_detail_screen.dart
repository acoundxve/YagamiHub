import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import 'admin_providers.dart';
import 'admin_user.dart';

const _roleOptions = ['OWNER', 'SUPER_ADMIN'];

String _roleLabel(String role) => role == 'SUPER_ADMIN' ? 'Super usuario' : 'Dueño de negocio';

class AdminUserDetailScreen extends ConsumerStatefulWidget {
  const AdminUserDetailScreen({super.key, required this.user});

  final AdminUser user;

  @override
  ConsumerState<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends ConsumerState<AdminUserDetailScreen> {
  final _detailsFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String _role;
  bool _isSavingDetails = false;
  String? _detailsError;
  String? _detailsSuccess;

  final _passwordController = TextEditingController();
  bool _isResettingPassword = false;
  String? _passwordError;
  String? _passwordSuccess;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _role = widget.user.role;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_detailsFormKey.currentState!.validate()) return;
    setState(() {
      _isSavingDetails = true;
      _detailsError = null;
      _detailsSuccess = null;
    });
    try {
      await ref.read(adminUsersControllerProvider.notifier).updateUser(
            widget.user.id,
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _role,
          );
      setState(() => _detailsSuccess = 'Usuario actualizado');
    } catch (error) {
      setState(() => _detailsError = error.toString());
    } finally {
      if (mounted) setState(() => _isSavingDetails = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.length < 8) {
      setState(() => _passwordError = 'Mínimo 8 caracteres');
      return;
    }
    setState(() {
      _isResettingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });
    try {
      await ref
          .read(adminUsersControllerProvider.notifier)
          .resetPassword(widget.user.id, _passwordController.text);
      _passwordController.clear();
      setState(() => _passwordSuccess = 'Contraseña restablecida');
    } catch (error) {
      setState(() => _passwordError = error.toString());
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelf = ref.watch(authControllerProvider).me?.id == widget.user.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.user.email)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _detailsFormKey,
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
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(labelText: 'Rol'),
                        items: _roleOptions
                            .map((role) => DropdownMenuItem(value: role, child: Text(_roleLabel(role))))
                            .toList(),
                        onChanged: isSelf ? null : (value) => setState(() => _role = value!),
                      ),
                      if (isSelf)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'No puedes cambiar tu propio rol',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_detailsError != null) ...[
                        Text(_detailsError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        const SizedBox(height: 16),
                      ],
                      if (_detailsSuccess != null) ...[
                        Text(_detailsSuccess!, style: const TextStyle(color: Colors.green)),
                        const SizedBox(height: 16),
                      ],
                      FilledButton(
                        onPressed: _isSavingDetails ? null : _saveDetails,
                        child: _isSavingDetails
                            ? const SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Guardar cambios'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 16),
                Text('Restablecer contraseña', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Como super usuario puedes fijar una nueva contraseña sin conocer la actual.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                ),
                const SizedBox(height: 16),
                if (_passwordError != null) ...[
                  Text(_passwordError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                ],
                if (_passwordSuccess != null) ...[
                  Text(_passwordSuccess!, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 16),
                ],
                FilledButton(
                  onPressed: _isResettingPassword ? null : _resetPassword,
                  child: _isResettingPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Restablecer contraseña'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
