import { IsOptional, IsString, MaxLength } from 'class-validator';

export class RespondCampaignDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  noteByAuthority?: string;
}
