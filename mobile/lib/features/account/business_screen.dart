import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';

class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final tenant = ref.read(authControllerProvider).tenant;
    _nameController = TextEditingController(text: tenant?.businessName ?? '');
    _typeController = TextEditingController(text: tenant?.businessType ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
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
      await ref.read(authControllerProvider.notifier).updateBusiness(
            businessName: _nameController.text.trim(),
            businessType: _typeController.text.trim(),
          );
      setState(() => _successMessage = 'Negocio actualizado');
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar negocio')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                    validator: (value) => value == null || value.length < 2 ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de negocio',
                      hintText: 'Ej. Panadería, Ferretería, Restaurante',
                    ),
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
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar cambios'),
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
