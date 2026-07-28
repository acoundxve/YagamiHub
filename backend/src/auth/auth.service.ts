import { ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { Role, type Tenant, type User } from '@prisma/client';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { slugify } from './slugify';
import { EmployeePermissions, JwtPayload } from './jwt.strategy';

const SALT_ROUNDS = 10;
const ME_SELECT = {
  id: true,
  email: true,
  phone: true,
  avatarUrl: true,
  role: true,
  tenantId: true,
  canManageProducts: true,
  canDeleteProducts: true,
  canCreateInvoices: true,
  canViewReports: true,
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) {
      throw new ConflictException('Ya existe una cuenta con ese correo');
    }

    const slug = await this.generateUniqueSlug(dto.businessName);
    const passwordHash = await bcrypt.hash(dto.password, SALT_ROUNDS);

    const { user, tenant } = await this.prisma.$transaction(async (tx) => {
      const tenant = await tx.tenant.create({
        data: {
          businessName: dto.businessName,
          slug,
        },
      });

      const user = await tx.user.create({
        data: {
          email: dto.email,
          passwordHash,
          role: Role.OWNER,
          tenantId: tenant.id,
        },
      });

      return { user, tenant };
    });

    return this.buildAuthResponse(user, tenant.id);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const passwordMatches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordMatches) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    return this.buildAuthResponse(user, user.tenantId);
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId }, select: ME_SELECT });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    if (dto.email) {
      const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existing && existing.id !== userId) {
        throw new ConflictException('Ya existe una cuenta con ese correo');
      }
    }

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { email: dto.email, phone: dto.phone },
      select: ME_SELECT,
    });
    return user;
  }

  async setAvatar(userId: string, avatarUrl: string, alsoSetBusinessBackground: boolean) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl },
      select: ME_SELECT,
    });

    let tenant: Tenant | null = null;
    if (alsoSetBusinessBackground && user.role === Role.OWNER && user.tenantId) {
      tenant = await this.prisma.tenant.update({
        where: { id: user.tenantId },
        data: { backgroundImageUrl: avatarUrl },
      });
    }

    return { user, tenant };
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const passwordMatches = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!passwordMatches) {
      throw new UnauthorizedException('La contraseña actual no es correcta');
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, SALT_ROUNDS);
    await this.prisma.user.update({ where: { id: userId }, data: { passwordHash } });
  }

  private buildAuthResponse(user: User, tenantId: string | null) {
    const permissions: EmployeePermissions | undefined =
      user.role === Role.EMPLOYEE
        ? {
            canManageProducts: user.canManageProducts,
            canDeleteProducts: user.canDeleteProducts,
            canCreateInvoices: user.canCreateInvoices,
            canViewReports: user.canViewReports,
          }
        : undefined;

    const payload: JwtPayload = { sub: user.id, email: user.email, role: user.role, tenantId, permissions };
    return {
      accessToken: this.jwtService.sign(payload),
      user: { id: user.id, email: user.email, role: user.role, tenantId },
    };
  }

  private async generateUniqueSlug(businessName: string): Promise<string> {
    const base = slugify(businessName) || 'negocio';
    let candidate = base;
    let suffix = 1;

    while (await this.prisma.tenant.findUnique({ where: { slug: candidate } })) {
      suffix += 1;
      candidate = `${base}-${suffix}`;
    }

    return candidate;
  }
}
