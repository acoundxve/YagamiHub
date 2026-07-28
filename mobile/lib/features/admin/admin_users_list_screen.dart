import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_providers.dart';

class AdminUsersListScreen extends ConsumerWidget {
  const AdminUsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Todavía no hay usuarios registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminUsersControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                final isSuperAdmin = user.role == 'SUPER_ADMIN';
                return ListTile(
                  leading: Icon(isSuperAdmin ? Icons.admin_panel_settings : Icons.person_outline),
                  title: Text(user.email),
                  subtitle: Text(
                    isSuperAdmin ? 'Super usuario' : (user.tenant?.businessName ?? 'Sin negocio'),
                  ),
                  onTap: () => context.push('/admin/users/${user.id}', extra: user),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
