import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LicenseStatus, Role } from '@prisma/client';

const OWNER_SELECT = { id: true, email: true, phone: true, role: true, createdAt: true };

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

  async updateMine(tenantId: string, data: { businessName: string; businessType?: string; isPublished?: boolean }) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data,
    });
  }

  findAll() {
    return this.prisma.tenant.findMany({
      orderBy: { createdAt: 'desc' },
      include: { users: { where: { role: Role.OWNER }, select: OWNER_SELECT } },
    });
  }

  async findOneWithUsers(tenantId: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      include: { users: { where: { role: Role.OWNER }, select: OWNER_SELECT } },
    });
    if (!tenant) {
      throw new NotFoundException('Negocio no encontrado');
    }
    return tenant;
  }

  async adminUpdate(tenantId: string, data: { businessName?: string; businessType?: string }) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data,
    });
  }

  async setBackground(tenantId: string, backgroundImageUrl: string) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: { backgroundImageUrl },
    });
  }

  async updateLicense(tenantId: string, licenseStatus: LicenseStatus) {
    await this.findMine(tenantId);
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: { licenseStatus },
    });
  }
}
