import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'invoices_providers.dart';

class InvoicesListScreen extends ConsumerWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Facturas')),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('Todavía no has emitido facturas.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(invoicesControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return ListTile(
                  title: Text('${invoice.invoiceNumber} · ${invoice.customerName}'),
                  subtitle: Text(
                    '${invoice.items.length} producto(s) · '
                    '${invoice.issueDate.day}/${invoice.issueDate.month}/${invoice.issueDate.year}',
                  ),
                  trailing: Text(
                    '\$${invoice.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/invoices/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
