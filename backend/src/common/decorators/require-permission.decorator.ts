import { SetMetadata } from '@nestjs/common';
import type { EmployeePermissions } from '../../auth/jwt.strategy';

export const PERMISSION_KEY = 'permission';
export const RequirePermission = (permission: keyof EmployeePermissions) =>
  SetMetadata(PERMISSION_KEY, permission);
