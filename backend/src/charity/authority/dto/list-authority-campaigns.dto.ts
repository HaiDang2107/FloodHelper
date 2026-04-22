import { Type } from 'class-transformer';
import { IsDateString, IsIn, IsInt, IsOptional, Max, Min } from 'class-validator';

export class ListAuthorityCampaignsDto {
  @IsOptional()
  @IsDateString()
  beforeRequestedAt?: string;

  @IsOptional()
  @IsIn([
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'FINISHED',
    'SUSPENDED',
  ])
  state?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
