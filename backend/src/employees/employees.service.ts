import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';

const SALT_ROUNDS = 10;
const EMPLOYEE_SELECT = {
  id: true,
  email: true,
  phone: true,
  role: true,
  tenantId: true,
  canManageProducts: true,
  canDeleteProducts: true,
  canCreateInvoices: true,
  canViewReports: true,
  createdAt: true,
};

@Injectable()
export class EmployeesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(tenantId: string) {
    return this.prisma.user.findMany({
      where: { tenantId, role: Role.EMPLOYEE },
      orderBy: { createdAt: 'desc' },
      select: EMPLOYEE_SELECT,
    });
  }

  async findOne(tenantId: string, id: string) {
    const employee = await this.prisma.user.findFirst({
      where: { id, tenantId, role: Role.EMPLOYEE },
      select: EMPLOYEE_SELECT,
    });
    if (!employee) {
      throw new NotFoundException('Empleado no encontrado');
    }
    return employee;
  }

  async create(tenantId: string, dto: CreateEmployeeDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException('Ya existe una cuenta con ese correo');
    }

    const passwordHash = await bcrypt.hash(dto.password, SALT_ROUNDS);

    return this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        passwordHash,
        role: Role.EMPLOYEE,
        tenantId,
        canManageProducts: dto.canManageProducts ?? false,
        canDeleteProducts: dto.canDeleteProducts ?? false,
        canCreateInvoices: dto.canCreateInvoices ?? false,
        canViewReports: dto.canViewReports ?? false,
      },
      select: EMPLOYEE_SELECT,
    });
  }

  async update(tenantId: string, id: string, dto: UpdateEmployeeDto) {
    await this.findOne(tenantId, id);

    if (dto.email) {
      const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existing && existing.id !== id) {
        throw new ConflictException('Ya existe una cuenta con ese correo');
      }
    }

    return this.prisma.user.update({
      where: { id },
      data: {
        email: dto.email,
        phone: dto.phone,
        canManageProducts: dto.canManageProducts,
        canDeleteProducts: dto.canDeleteProducts,
        canCreateInvoices: dto.canCreateInvoices,
        canViewReports: dto.canViewReports,
      },
      select: EMPLOYEE_SELECT,
    });
  }

  async resetPassword(tenantId: string, id: string, newPassword: string) {
    await this.findOne(tenantId, id);
    const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
    await this.prisma.user.update({ where: { id }, data: { passwordHash } });
  }

  async remove(tenantId: string, id: string) {
    await this.findOne(tenantId, id);
    await this.prisma.user.delete({ where: { id } });
  }
}
