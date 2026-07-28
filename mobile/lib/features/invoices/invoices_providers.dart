import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../products/products_providers.dart';
import 'invoice.dart';
import 'invoices_repository.dart';

final invoicesRepositoryProvider = Provider(
  (ref) => InvoicesRepository(ref.watch(apiClientProvider)),
);

class InvoicesController extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() {
    return ref.read(invoicesRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(invoicesRepositoryProvider).list());
  }

  Future<void> createInvoice({
    required String customerName,
    required List<InvoiceItemInput> items,
  }) async {
    await ref.read(invoicesRepositoryProvider).create(customerName: customerName, items: items);
    await refresh();
    // Emitir una factura cambia el stock, así que el inventario cacheado queda desactualizado.
    await ref.read(productsControllerProvider.notifier).refresh();
  }
}

final invoicesControllerProvider = AsyncNotifierProvider<InvoicesController, List<Invoice>>(
  InvoicesController.new,
);
