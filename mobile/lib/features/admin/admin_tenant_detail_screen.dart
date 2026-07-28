import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
