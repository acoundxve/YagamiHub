import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../auth/jwt.strategy';
import { Role } from '@prisma/client';
import { InvoicesService } from './invoices.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';

@Controller('invoices')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.OWNER)
export class InvoicesController {
  constructor(private readonly invoicesService: InvoicesService) {}

  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateInvoiceDto) {
    return this.invoicesService.create(user.tenantId as string, dto);
  }

  @Get()
  findAll(@CurrentUser() user: AuthenticatedUser) {
    return this.invoicesService.findAll(user.tenantId as string);
  }
}
