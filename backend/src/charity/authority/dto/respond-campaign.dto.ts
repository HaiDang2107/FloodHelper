import { IsOptional, IsString, MaxLength } from 'class-validator';

export class RespondCampaignDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  noteForResponse?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  noteForSuspension?: string;
}
