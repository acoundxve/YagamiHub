import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'product.dart';
import 'products_providers.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(productsControllerProvider.notifier).deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Todavía no tienes productos en tu inventario.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(productsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.sku != null ? 'SKU: ${product.sku} · ' : ''}'
                    'Costo: \$${product.costPrice.toStringAsFixed(2)} · '
                    'Venta: \$${product.salePrice.toStringAsFixed(2)} · '
                    'Stock: ${product.stockQty}',
                  ),
                  onTap: () => context.push('/products/${product.id}/edit', extra: product),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, product),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
