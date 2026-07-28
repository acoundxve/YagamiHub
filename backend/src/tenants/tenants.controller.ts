import { Body, Controller, Get, Param, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { Role } from '@prisma/client';
import { TenantsService } from './tenants.service';
import { UpdateTenantDto } from './dto/update-tenant.dto';
import { AdminUpdateTenantDto } from './dto/admin-update-tenant.dto';
import { UpdateLicenseDto } from './dto/update-license.dto';

@Controller('tenants')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TenantsController {
  constructor(private readonly tenantsService: TenantsService) {}

  @Get('me')
  @Roles(Role.OWNER, Role.EMPLOYEE)
  getMine(@CurrentUser() user: AuthenticatedUser) {
    return this.tenantsService.findMine(user.tenantId as string);
  }

  @Patch('me')
  @Roles(Role.OWNER)
  updateMine(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateTenantDto) {
    return this.tenantsService.updateMine(user.tenantId as string, dto);
  }

  @Get()
  @Roles(Role.SUPER_ADMIN)
  findAll() {
    return this.tenantsService.findAll();
  }

  @Get(':id')
  @Roles(Role.SUPER_ADMIN)
  findOne(@Param('id') id: string) {
    return this.tenantsService.findOneWithUsers(id);
  }

  @Patch(':id')
  @Roles(Role.SUPER_ADMIN)
  adminUpdate(@Param('id') id: string, @Body() dto: AdminUpdateTenantDto) {
    return this.tenantsService.adminUpdate(id, dto);
  }

  @Patch(':id/license')
  @Roles(Role.SUPER_ADMIN)
  updateLicense(@Param('id') id: string, @Body() dto: UpdateLicenseDto) {
    return this.tenantsService.updateLicense(id, dto.licenseStatus);
  }
}
