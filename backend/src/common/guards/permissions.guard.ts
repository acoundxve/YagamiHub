import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { PERMISSION_KEY } from '../decorators/require-permission.decorator';
import type { AuthenticatedUser, EmployeePermissions } from '../../auth/jwt.strategy';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const permission = this.reflector.getAllAndOverride<keyof EmployeePermissions | undefined>(
      PERMISSION_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!permission) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;

    if (user.role === Role.OWNER) {
      return true;
    }
    if (user.role === Role.EMPLOYEE) {
      return user.permissions?.[permission] === true;
    }
    return false;
  }
}
