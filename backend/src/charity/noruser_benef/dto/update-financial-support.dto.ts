import { IsDateString, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class UpdateFinancialSupportDto {
  @IsOptional()
  @IsString()
  householdName?: string;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  amount?: number;

  @IsOptional()
  @IsDateString()
  allocatedAt?: string;
}