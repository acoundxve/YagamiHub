import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { InvoiceStatus } from '@prisma/client';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async profitLoss(tenantId: string) {
    const [products, items] = await Promise.all([
      this.prisma.product.findMany({ where: { tenantId } }),
      this.prisma.invoiceItem.findMany({
        where: { invoice: { tenantId, status: { not: InvoiceStatus.VOID } } },
        select: { productId: true, quantity: true, subtotal: true },
      }),
    ]);

    const soldByProduct = new Map<string, { unitsSold: number; revenue: number }>();
    for (const item of items) {
      const entry = soldByProduct.get(item.productId) ?? { unitsSold: 0, revenue: 0 };
      entry.unitsSold += item.quantity;
      entry.revenue += Number(item.subtotal);
      soldByProduct.set(item.productId, entry);
    }

    const productReports = products.map((product) => {
      const sold = soldByProduct.get(product.id) ?? { unitsSold: 0, revenue: 0 };
      const costPrice = Number(product.costPrice);
      const invested = costPrice * (sold.unitsSold + product.stockQty);
      const costOfGoodsSold = costPrice * sold.unitsSold;
      const profit = sold.revenue - costOfGoodsSold;

      return {
        productId: product.id,
        name: product.name,
        stockQty: product.stockQty,
        unitsSold: sold.unitsSold,
        costPrice,
        salePrice: Number(product.salePrice),
        invested,
        revenue: sold.revenue,
        profit,
      };
    });

    const totals = productReports.reduce(
      (acc, p) => ({
        invested: acc.invested + p.invested,
        revenue: acc.revenue + p.revenue,
        profit: acc.profit + p.profit,
      }),
      { invested: 0, revenue: 0, profit: 0 },
    );

    return { products: productReports, totals };
  }
}
