import { IsString, MinLength } from 'class-validator';

export class ResetEmployeePasswordDto {
  @IsString()
  @MinLength(8)
  newPassword!: string;
}
