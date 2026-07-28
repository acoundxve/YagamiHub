import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../products/product.dart';
import '../products/products_providers.dart';
import 'invoices_providers.dart';
import 'invoices_repository.dart';

class _LineItem {
  _LineItem() : quantityController = TextEditingController(text: '1');

  Product? product;
  final TextEditingController quantityController;
}

class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final List<_LineItem> _lineItems = [_LineItem()];
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _customerController.dispose();
    for (final item in _lineItems) {
      item.quantityController.dispose();
    }
    super.dispose();
  }

  double get _total {
    var total = 0.0;
    for (final item in _lineItems) {
      final quantity = int.tryParse(item.quantityController.text) ?? 0;
      if (item.product != null) {
        total += item.product!.salePrice * quantity;
      }
    }
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final items = _lineItems
        .where((item) => item.product != null)
        .map((item) => InvoiceItemInput(
              productId: item.product!.id,
              quantity: int.parse(item.quantityController.text),
            ))
        .toList();

    if (items.isEmpty) {
      setState(() => _errorMessage = 'Agrega al menos un producto');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref.read(invoicesControllerProvider.notifier).createInvoice(
            customerName: _customerController.text.trim(),
            items: items,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva factura')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _customerController,
                    decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 24),
                  Text('Productos', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  productsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(error.toString()),
                    data: (products) {
                      if (products.isEmpty) {
                        return const Text('Primero agrega productos a tu inventario.');
                      }
                      return Column(
                        children: [
                          for (final item in _lineItems) _buildLineItemRow(item, products),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _lineItems.add(_LineItem())),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar producto'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: \$${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Crear factura'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineItemRow(_LineItem item, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<Product>(
              value: item.product,
              decoration: const InputDecoration(labelText: 'Producto'),
              items: products
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (stock: ${p.stockQty})', overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => item.product = value),
              validator: (value) => value == null ? 'Elige un producto' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: item.quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final quantity = int.tryParse(value ?? '');
                if (quantity == null || quantity < 1) return 'Inválido';
                if (item.product != null && quantity > item.product!.stockQty) return 'Sin stock';
                return null;
              },
            ),
          ),
          if (_lineItems.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => _lineItems.remove(item)),
            ),
        ],
      ),
    );
  }
}
