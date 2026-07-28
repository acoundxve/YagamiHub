import { IsBoolean, IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

export class CreateEmployeeDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

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
