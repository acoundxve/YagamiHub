import { IsBoolean, IsEmail, IsOptional, IsString } from 'class-validator';

export class UpdateEmployeeDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsBoolean()
  canManageProducts?: boolean;

  @IsOptional()
  @IsBoolean()
  canDeleteProducts?: boolean;

  @IsOptional()
  @IsBoolean()
  canCreateInvoices?: boolean;

  @IsOptional()
  @IsBoolean()
  canViewReports?: boolean;
}
