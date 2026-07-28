import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product.dart';
import 'products_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.existingProduct});

  final Product? existingProduct;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _costController;
  late final TextEditingController _saleController;
  late final TextEditingController _stockController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _costController = TextEditingController(text: product?.costPrice.toString() ?? '');
    _saleController = TextEditingController(text: product?.salePrice.toString() ?? '');
    _stockController = TextEditingController(text: product?.stockQty.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _saleController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(productsControllerProvider.notifier);
      final params = (
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        costPrice: double.parse(_costController.text),
        salePrice: double.parse(_saleController.text),
        stockQty: int.parse(_stockController.text),
      );

      if (_isEditing) {
        await controller.updateProduct(
          widget.existingProduct!.id,
          name: params.name,
          sku: params.sku,
          costPrice: params.costPrice,
          salePrice: params.salePrice,
          stockQty: params.stockQty,
        );
      } else {
        await controller.createProduct(
          name: params.name,
          sku: params.sku,
          costPrice: params.costPrice,
          salePrice: params.salePrice,
          stockQty: params.stockQty,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    return double.tryParse(value) == null ? 'Ingresa un número válido' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del producto'),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(labelText: 'SKU (opcional)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(labelText: 'Costo de compra'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _requiredNumber,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _saleController,
                    decoration: const InputDecoration(labelText: 'Precio de venta'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _requiredNumber,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Cantidad en stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null ? 'Ingresa un número entero' : null,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
