import { IsBoolean } from 'class-validator';

export class UpdateShowCampaignLocationsDto {
  @IsBoolean()
  showCharityCampaignLocations: boolean;
}
