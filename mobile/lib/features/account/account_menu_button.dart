import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_providers.dart';

enum _AccountMenuAction { editProfile, editBusiness, employees, logout }

class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key, this.isOwner = false});

  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_AccountMenuAction>(
      icon: const Icon(Icons.account_circle),
      tooltip: 'Cuenta',
      onSelected: (action) async {
        switch (action) {
          case _AccountMenuAction.editProfile:
            context.push('/profile');
          case _AccountMenuAction.editBusiness:
            context.push('/business');
          case _AccountMenuAction.employees:
            context.push('/employees');
          case _AccountMenuAction.logout:
            await ref.read(authControllerProvider.notifier).logout();
            if (context.mounted) context.go('/login');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _AccountMenuAction.editProfile,
          child: ListTile(leading: Icon(Icons.person_outline), title: Text('Editar perfil')),
        ),
        if (isOwner) ...[
          const PopupMenuItem(
            value: _AccountMenuAction.editBusiness,
            child: ListTile(leading: Icon(Icons.storefront_outlined), title: Text('Editar negocio')),
          ),
          const PopupMenuItem(
            value: _AccountMenuAction.employees,
            child: ListTile(leading: Icon(Icons.badge_outlined), title: Text('Agregar empleado')),
          ),
        ],
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _AccountMenuAction.logout,
          child: ListTile(leading: Icon(Icons.logout), title: Text('Cerrar sesión')),
        ),
      ],
    );
  }
}
