import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { EmployeesService } from './employees.service';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import { ResetEmployeePasswordDto } from './dto/reset-employee-password.dto';

@Controller('tenants/:tenantId/employees')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.SUPER_ADMIN)
export class AdminEmployeesController {
  constructor(private readonly employeesService: EmployeesService) {}

  @Get()
  findAll(@Param('tenantId') tenantId: string) {
    return this.employeesService.findAll(tenantId);
  }

  @Post()
  create(@Param('tenantId') tenantId: string, @Body() dto: CreateEmployeeDto) {
    return this.employeesService.create(tenantId, dto);
  }

  @Patch(':id')
  update(
    @Param('tenantId') tenantId: string,
    @Param('id') id: string,
    @Body() dto: UpdateEmployeeDto,
  ) {
    return this.employeesService.update(tenantId, id, dto);
  }

  @Patch(':id/reset-password')
  resetPassword(
    @Param('tenantId') tenantId: string,
    @Param('id') id: string,
    @Body() dto: ResetEmployeePasswordDto,
  ) {
    return this.employeesService.resetPassword(tenantId, id, dto.newPassword);
  }

  @Delete(':id')
  remove(@Param('tenantId') tenantId: string, @Param('id') id: string) {
    return this.employeesService.remove(tenantId, id);
  }
}
