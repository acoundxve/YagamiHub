import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LicenseStatus } from '@prisma/client';

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService) {}

  async findMine(tenantId: string) {
    const tenant = await this.prisma.tenant.findUnique({ where: { id: tenantId } });
    if (!tenant) {
      throw new NotFoundException('Negocio no encontrado');
    }
    return tenant;
  }

  async updateMine(tenantId: string, businessName: string) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: { businessName },
    });
  }

  findAll() {
    return this.prisma.tenant.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async updateLicense(tenantId: string, licenseStatus: LicenseStatus) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: { licenseStatus },
    });
  }
}
