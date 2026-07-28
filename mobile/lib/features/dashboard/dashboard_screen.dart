import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _editBusinessName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre del negocio'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      await ref.read(authControllerProvider.notifier).updateBusinessName(newName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tenant = authState.tenant;

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant?.businessName ?? 'YagamiHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Cambiar nombre del negocio',
            onPressed: tenant == null ? null : () => _editBusinessName(context, ref, tenant.businessName),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: const [
            _PlaceholderCard(icon: Icons.inventory_2, title: 'Inventario', subtitle: 'Próximamente'),
            _PlaceholderCard(icon: Icons.receipt_long, title: 'Facturas', subtitle: 'Próximamente'),
            _PlaceholderCard(icon: Icons.trending_up, title: 'Ganancias', subtitle: 'Próximamente'),
            _PlaceholderCard(icon: Icons.trending_down, title: 'Pérdidas', subtitle: 'Próximamente'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
