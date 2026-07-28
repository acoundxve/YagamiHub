import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_providers.dart';
import 'license_status.dart';

class AdminTenantsListScreen extends ConsumerWidget {
  const AdminTenantsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(adminTenantsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Negocios y licencias')),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (tenants) {
          if (tenants.isEmpty) {
            return const Center(child: Text('Todavía no hay negocios registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminTenantsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: tenants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                final ownerEmail = tenant.owners.isNotEmpty ? tenant.owners.first.email : 'sin dueño';
                return ListTile(
                  title: Text(tenant.businessName),
                  subtitle: Text('${tenant.businessType ?? 'Sin tipo'} · $ownerEmail'),
                  trailing: LicenseStatusChip(status: tenant.licenseStatus),
                  onTap: () => context.push('/admin/tenants/${tenant.id}', extra: tenant),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
