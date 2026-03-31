import { IsBoolean, IsInt, IsOptional, IsString, IsUUID, MaxLength, Min } from 'class-validator';

export class CreateSignalDto {
  @IsOptional()
  @IsUUID()
  createdBy?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  trappedCount?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  childrenNum?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  elderlyNum?: number;

  @IsOptional()
  @IsBoolean()
  hasFood?: boolean;

  @IsOptional()
  @IsBoolean()
  hasWater?: boolean;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  note?: string;
}
