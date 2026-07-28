import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { slugify } from './slugify';
import { JwtPayload } from './jwt.strategy';

const SALT_ROUNDS = 10;

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

    return this.buildAuthResponse(user.id, user.email, user.role, tenant.id);
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

    return this.buildAuthResponse(user.id, user.email, user.role, user.tenantId);
  }

  private buildAuthResponse(userId: string, email: string, role: Role, tenantId: string | null) {
    const payload: JwtPayload = { sub: userId, email, role, tenantId };
    return {
      accessToken: this.jwtService.sign(payload),
      user: { id: userId, email, role, tenantId },
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
