import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../account/account_menu_button.dart';
import '../auth/auth_providers.dart';

class SuperAdminScreen extends ConsumerWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YagamiHub · Super usuario'),
        actions: const [AccountMenuButton(showBusinessOption: false)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings, size: 56),
              const SizedBox(height: 16),
              Text(
                'Bienvenido, ${me?.email ?? 'super usuario'}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'El panel para administrar negocios y licencias está próximamente.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
