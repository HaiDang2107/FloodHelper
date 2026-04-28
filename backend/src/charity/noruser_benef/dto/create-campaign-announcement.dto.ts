import { IsNotEmpty, IsString } from 'class-validator';

export class CreateCampaignAnnouncementDto {
  @IsNotEmpty()
  @IsString()
  caption!: string;
}
