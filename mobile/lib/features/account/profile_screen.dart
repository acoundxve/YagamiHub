import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSavingProfile = false;
  String? _profileError;
  String? _profileSuccess;

  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSavingPassword = false;
  String? _passwordError;
  String? _passwordSuccess;

  @override
  void initState() {
    super.initState();
    final me = ref.read(authControllerProvider).me;
    _emailController = TextEditingController(text: me?.email ?? '');
    _phoneController = TextEditingController(text: me?.phone ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() {
      _isSavingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      setState(() => _profileSuccess = 'Datos actualizados');
    } catch (error) {
      setState(() => _profileError = error.toString());
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() {
      _isSavingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _passwordSuccess = 'Contraseña actualizada');
    } catch (error) {
      setState(() => _passwordError = error.toString());
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Datos de la cuenta', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Form(
                  key: _profileFormKey,
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
                      if (_profileError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_profileError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      if (_profileSuccess != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_profileSuccess!, style: const TextStyle(color: Colors.green)),
                        ),
                      FilledButton(
                        onPressed: _isSavingProfile ? null : _saveProfile,
                        child: _isSavingProfile
                            ? const SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Guardar datos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 16),
                Text('Cambiar contraseña', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Contraseña actual'),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                        validator: (value) =>
                            value == null || value.length < 8 ? 'Mínimo 8 caracteres' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña'),
                        validator: (value) =>
                            value != _newPasswordController.text ? 'Las contraseñas no coinciden' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_passwordError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      if (_passwordSuccess != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_passwordSuccess!, style: const TextStyle(color: Colors.green)),
                        ),
                      FilledButton(
                        onPressed: _isSavingPassword ? null : _savePassword,
                        child: _isSavingPassword
                            ? const SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Cambiar contraseña'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
