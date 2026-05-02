import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export class QueryCampaignsByStateDto {
  @IsNotEmpty()
  @IsString()
  @IsIn([
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'SUSPENDED',
    'FINISHED',
  ])
  state: string;
}