import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
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
  late bool _isPublished;
  bool _isSaving = false;
  bool _isTogglingPublish = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final tenant = ref.read(authControllerProvider).tenant;
    _nameController = TextEditingController(text: tenant?.businessName ?? '');
    _typeController = TextEditingController(text: tenant?.businessType ?? '');
    _isPublished = tenant?.isPublished ?? false;
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

  Future<void> _togglePublished(bool value) async {
    setState(() {
      _isTogglingPublish = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateBusiness(
            businessName: _nameController.text.trim(),
            businessType: _typeController.text.trim(),
            isPublished: value,
          );
      setState(() => _isPublished = value);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isTogglingPublish = false);
    }
  }

  Future<void> _pickAndUploadBusinessImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _isUploadingImage = true;
      _errorMessage = null;
    });

    try {
      final bytes = await picked.readAsBytes();
      await ref
          .read(authControllerProvider.notifier)
          .uploadBusinessBackground(bytes: bytes, filename: picked.name);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  String _publicUrl(String slug) {
    final origin = Uri.base.origin;
    return '$origin/#/n/$slug';
  }

  @override
  Widget build(BuildContext context) {
    final tenant = ref.watch(authControllerProvider).tenant;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar negocio')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Imagen del negocio', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Se usa como fondo de pantalla de la app para ti y tus empleados.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: _isUploadingImage ? null : _pickAndUploadBusinessImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        image: resolveMediaUrl(tenant?.backgroundImageUrl) != null
                            ? DecorationImage(
                                image: NetworkImage(resolveMediaUrl(tenant!.backgroundImageUrl)!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _isUploadingImage
                          ? const Center(child: CircularProgressIndicator())
                          : resolveMediaUrl(tenant?.backgroundImageUrl) == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(height: 8),
                                    Text('Toca para agregar una imagen',
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('Sitio público', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Publica una página pública sencilla con el nombre de tu negocio.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publicar sitio'),
                  value: _isPublished,
                  onChanged: _isTogglingPublish ? null : _togglePublished,
                ),
                if (_isPublished && tenant != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _publicUrl(tenant.slug),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copiar enlace',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _publicUrl(tenant.slug)));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enlace copiado')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Form(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
