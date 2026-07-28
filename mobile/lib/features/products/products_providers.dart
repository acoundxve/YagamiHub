import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import 'product.dart';
import 'products_repository.dart';

final productsRepositoryProvider = Provider(
  (ref) => ProductsRepository(ref.watch(apiClientProvider)),
);

class ProductsController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.read(productsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(productsRepositoryProvider).list());
  }

  Future<void> createProduct({
    required String name,
    String? sku,
    required double costPrice,
    required double salePrice,
    required int stockQty,
  }) async {
    await ref.read(productsRepositoryProvider).create(
          name: name,
          sku: sku,
          costPrice: costPrice,
          salePrice: salePrice,
          stockQty: stockQty,
        );
    await refresh();
  }

  Future<void> updateProduct(
    String id, {
    required String name,
    String? sku,
    required double costPrice,
    required double salePrice,
    required int stockQty,
  }) async {
    await ref.read(productsRepositoryProvider).update(
          id,
          name: name,
          sku: sku,
          costPrice: costPrice,
          salePrice: salePrice,
          stockQty: stockQty,
        );
    await refresh();
  }

  Future<void> deleteProduct(String id) async {
    await ref.read(productsRepositoryProvider).delete(id);
    await refresh();
  }
}

final productsControllerProvider = AsyncNotifierProvider<ProductsController, List<Product>>(
  ProductsController.new,
);
