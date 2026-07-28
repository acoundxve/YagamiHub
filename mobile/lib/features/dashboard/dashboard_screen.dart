import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_providers.dart';
import '../account/account_menu_button.dart';
import '../auth/auth_providers.dart';
import '../auth/auth_user.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  IconData _themeModeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
        ThemeMode.system => Icons.brightness_auto,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tenant = authState.tenant;
    final themeMode = ref.watch(themeModeProvider);
    final isOwner = authState.me?.role == UserRole.owner;
    final permissions = authState.me?.permissions;

    final canSeeProducts = isOwner || (permissions?.canManageProducts ?? false);
    final canSeeInvoices = isOwner || (permissions?.canCreateInvoices ?? false);
    final canSeeReports = isOwner || (permissions?.canViewReports ?? false);

    final cards = [
      if (canSeeProducts)
        _DashboardCard(
          icon: Icons.inventory_2,
          title: 'Inventario',
          subtitle: 'Ver productos',
          onTap: () => context.push('/products'),
        ),
      if (canSeeInvoices)
        _DashboardCard(
          icon: Icons.receipt_long,
          title: 'Facturas',
          subtitle: 'Ver facturas',
          onTap: () => context.push('/invoices'),
        ),
      if (canSeeReports)
        _DashboardCard(
          icon: Icons.trending_up,
          title: 'Ganancias y pérdidas',
          subtitle: 'Ver desglose',
          onTap: () => context.push('/reports'),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant?.businessName ?? 'YagamiHub'),
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: Icon(_themeModeIcon(themeMode)),
            tooltip: 'Tema',
            initialValue: themeMode,
            onSelected: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(value: ThemeMode.system, child: Text('Tema del sistema')),
              PopupMenuItem(value: ThemeMode.light, child: Text('Claro')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
            ],
          ),
          AccountMenuButton(isOwner: isOwner),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: cards.isEmpty
            ? const Center(child: Text('Todavía no tienes acceso a ninguna sección. Habla con el dueño del negocio.'))
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: cards,
              ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
