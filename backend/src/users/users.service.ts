import { ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { AdminUpdateUserDto } from './dto/admin-update-user.dto';

const SALT_ROUNDS = 10;
const SAFE_SELECT = {
  id: true,
  email: true,
  phone: true,
  role: true,
  tenantId: true,
  createdAt: true,
  tenant: { select: { id: true, businessName: true } },
};

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      select: SAFE_SELECT,
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id }, select: SAFE_SELECT });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    return user;
  }

  async update(id: string, dto: AdminUpdateUserDto, requestingUserId: string) {
    await this.findOne(id);

    if (dto.role && id === requestingUserId) {
      throw new ForbiddenException('No puedes cambiar tu propio rol');
    }

    if (dto.email) {
      const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existing && existing.id !== id) {
        throw new ConflictException('Ya existe una cuenta con ese correo');
      }
    }

    return this.prisma.user.update({
      where: { id },
      data: { email: dto.email, phone: dto.phone, role: dto.role },
      select: SAFE_SELECT,
    });
  }

  async resetPassword(id: string, newPassword: string) {
    await this.findOne(id);
    const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
    await this.prisma.user.update({ where: { id }, data: { passwordHash } });
  }
}
