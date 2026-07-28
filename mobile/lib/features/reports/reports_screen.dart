import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profit_loss_report.dart';
import 'reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(profitLossControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ganancias y pérdidas')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (report) {
          if (report.products.isEmpty) {
            return const Center(child: Text('Agrega productos y factura para ver este reporte.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(profitLossControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TotalsRow(totals: report.totals),
                const SizedBox(height: 24),
                Text('Por producto', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...report.products.map((product) => _ProductProfitLossTile(product: product)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.totals});

  final ProfitLossTotals totals;

  @override
  Widget build(BuildContext context) {
    final isProfit = totals.profit >= 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        final cards = [
          _TotalCard(label: 'Invertido', value: totals.invested, color: null),
          _TotalCard(label: 'Recuperado', value: totals.revenue, color: null),
          _TotalCard(
            label: isProfit ? 'Ganancia' : 'Pérdida',
            value: totals.profit,
            color: isProfit ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        ];
        if (isNarrow) {
          return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)]);
        }
        return Row(children: [for (final c in cards) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))]);
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductProfitLossTile extends StatelessWidget {
  const _ProductProfitLossTile({required this.product});

  final ProductProfitLoss product;

  @override
  Widget build(BuildContext context) {
    final isProfit = product.profit >= 0;
    final profitColor = isProfit ? Colors.green : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(product.name, style: Theme.of(context).textTheme.titleMedium)),
                Text(
                  '${isProfit ? '+' : ''}\$${product.profit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: profitColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Vendidas: ${product.unitsSold} · Stock: ${product.stockQty} · '
              'Invertido: \$${product.invested.toStringAsFixed(2)} · '
              'Recuperado: \$${product.revenue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
