import { Transform } from 'class-transformer';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class TransactionSyncDto {
  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  transactionid!: string;

  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  transactiontime!: string;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  referencenumber?: string | null;

  @Transform(({ value, obj }) => {
    if (value != null) {
      return String(value).trim();
    }
    if (obj?.referencenumer != null) {
      return String(obj.referencenumer).trim();
    }
    return null;
  })
  @IsOptional()
  @IsString()
  referencenumer?: string | null;

  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  amount!: string;

  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  content!: string;

  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  bankaccount!: string;

  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsString()
  @IsNotEmpty()
  orderId!: string;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  sign?: string | null;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  terminalCode?: string | null;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  urlLink?: string | null;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  serviceCode?: string | null;

  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @IsOptional()
  @IsString()
  subTerminalCode?: string | null;
}
