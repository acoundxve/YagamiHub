import { IsOptional, IsString, MinLength } from 'class-validator';

export class UpdateTenantDto {
  @IsString()
  @MinLength(2)
  businessName!: string;

  @IsOptional()
  @IsString()
  businessType?: string;
}
