import { IsIn, IsOptional } from 'class-validator';

export class QueryCampaignTransactionsDto {
  @IsOptional()
  @IsIn(['CREATED', 'VERIFYING', 'SUCCESS', 'FAILED', 'EXPIRED'])
  state?: 'CREATED' | 'VERIFYING' | 'SUCCESS' | 'FAILED' | 'EXPIRED';
}
