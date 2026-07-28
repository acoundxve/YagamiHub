import { Type } from 'class-transformer';
import { ArrayMinSize, IsArray, IsInt, IsString, Min, MinLength, ValidateNested } from 'class-validator';

class InvoiceItemInputDto {
  @IsString()
  productId!: string;

  @IsInt()
  @Min(1)
  quantity!: number;
}

export class CreateInvoiceDto {
  @IsString()
  @MinLength(1)
  customerName!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => InvoiceItemInputDto)
  items!: InvoiceItemInputDto[];
}
