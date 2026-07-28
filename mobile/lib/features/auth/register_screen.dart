import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(authControllerProvider.notifier).register(
          businessName: _businessNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Registra tu negocio', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                    validator: (value) => value == null || value.length < 2 ? 'Ingresa el nombre de tu negocio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa tu correo' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (value) =>
                        value == null || value.length < 8 ? 'Mínimo 8 caracteres' : null,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Crear negocio'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
