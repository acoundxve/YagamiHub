import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { Role } from '@prisma/client';
import { ReportsService } from './reports.service';

@Controller('reports')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.OWNER)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('profit-loss')
  profitLoss(@CurrentUser() user: AuthenticatedUser) {
    return this.reportsService.profitLoss(user.tenantId as string);
  }
}
