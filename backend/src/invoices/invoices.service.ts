import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { InvoiceStatus } from '@prisma/client';
import { CreateInvoiceDto } from './dto/create-invoice.dto';

@Injectable()
export class InvoicesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(tenantId: string, dto: CreateInvoiceDto) {
    return this.prisma.$transaction(async (tx) => {
      const productIds = dto.items.map((item) => item.productId);
      const products = await tx.product.findMany({
        where: { id: { in: productIds }, tenantId },
      });

      if (products.length !== new Set(productIds).size) {
        throw new BadRequestException('Uno o más productos no existen en este negocio');
      }

      const productsById = new Map(products.map((product) => [product.id, product]));

      let total = 0;
      const itemsData = dto.items.map((item) => {
        const product = productsById.get(item.productId)!;
        if (product.stockQty < item.quantity) {
          throw new BadRequestException(`Stock insuficiente para "${product.name}"`);
        }
        const unitPrice = Number(product.salePrice);
        const subtotal = unitPrice * item.quantity;
        total += subtotal;
        return {
          productId: product.id,
          quantity: item.quantity,
          unitPrice,
          subtotal,
        };
      });

      const invoiceCount = await tx.invoice.count({ where: { tenantId } });
      const invoiceNumber = `INV-${String(invoiceCount + 1).padStart(5, '0')}`;

      const invoice = await tx.invoice.create({
        data: {
          tenantId,
          invoiceNumber,
          customerName: dto.customerName,
          status: InvoiceStatus.ISSUED,
          total,
          items: { create: itemsData },
        },
        include: { items: true },
      });

      for (const item of itemsData) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stockQty: { decrement: item.quantity } },
        });
      }

      return invoice;
    });
  }

  findAll(tenantId: string) {
    return this.prisma.invoice.findMany({
      where: { tenantId },
      include: { items: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
