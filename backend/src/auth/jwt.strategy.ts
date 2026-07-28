import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Role } from '@prisma/client';

export interface EmployeePermissions {
  canManageProducts: boolean;
  canDeleteProducts: boolean;
  canCreateInvoices: boolean;
  canViewReports: boolean;
}

export interface JwtPayload {
  sub: string;
  email: string;
  role: Role;
  tenantId: string | null;
  permissions?: EmployeePermissions;
}

export interface AuthenticatedUser {
  userId: string;
  email: string;
  role: Role;
  tenantId: string | null;
  permissions?: EmployeePermissions;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.getOrThrow<string>('JWT_SECRET'),
    });
  }

  validate(payload: JwtPayload): AuthenticatedUser {
    return {
      userId: payload.sub,
      email: payload.email,
      role: payload.role,
      tenantId: payload.tenantId,
      permissions: payload.permissions,
    };
  }
}
