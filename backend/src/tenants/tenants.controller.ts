import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
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
import { imageUploadOptions } from '../common/upload/image-upload.options';

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

  @Post('me/background')
  @Roles(Role.OWNER)
  @UseInterceptors(FileInterceptor('file', imageUploadOptions('backgrounds')))
  uploadBackground(@CurrentUser() user: AuthenticatedUser, @UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No se recibió ningún archivo');
    }
    const backgroundImageUrl = `/uploads/backgrounds/${file.filename}`;
    return this.tenantsService.setBackground(user.tenantId as string, backgroundImageUrl);
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
