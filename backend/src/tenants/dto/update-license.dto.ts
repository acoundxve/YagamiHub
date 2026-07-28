import { IsEnum } from 'class-validator';
import { LicenseStatus } from '@prisma/client';

export class UpdateLicenseDto {
  @IsEnum(LicenseStatus)
  licenseStatus!: LicenseStatus;
}
