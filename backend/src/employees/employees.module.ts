import { Module } from '@nestjs/common';
import { EmployeesController } from './employees.controller';
import { AdminEmployeesController } from './admin-employees.controller';
import { EmployeesService } from './employees.service';

@Module({
  controllers: [EmployeesController, AdminEmployeesController],
  providers: [EmployeesService],
})
export class EmployeesModule {}
