import { IsNotEmpty, IsString } from 'class-validator';

export class QueryCampaignsByStateDto {
  @IsNotEmpty()
  @IsString()
  state: string;
}