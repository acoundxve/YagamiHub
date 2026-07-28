import { IsInt, IsNumber, IsOptional, IsString, Min, MinLength } from 'class-validator';

export class CreateProductDto {
  @IsString()
  @MinLength(1)
  name!: string;

  @IsOptional()
  @IsString()
  sku?: string;

  @IsNumber()
  @Min(0)
  costPrice!: number;

  @IsNumber()
  @Min(0)
  salePrice!: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  stockQty?: number;
}
