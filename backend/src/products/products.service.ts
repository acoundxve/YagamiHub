import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  create(tenantId: string, dto: CreateProductDto) {
    return this.prisma.product.create({
      data: { ...dto, tenantId },
    });
  }

  findAll(tenantId: string) {
    return this.prisma.product.findMany({
      where: { tenantId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(tenantId: string, id: string) {
    const product = await this.prisma.product.findUnique({ where: { id } });
    if (!product) {
      throw new NotFoundException('Producto no encontrado');
    }
    if (product.tenantId !== tenantId) {
      throw new ForbiddenException();
    }
    return product;
  }

  async update(tenantId: string, id: string, dto: UpdateProductDto) {
    await this.findOne(tenantId, id);
    return this.prisma.product.update({ where: { id }, data: dto });
  }

  async remove(tenantId: string, id: string) {
    await this.findOne(tenantId, id);
    await this.prisma.product.delete({ where: { id } });
  }
}
