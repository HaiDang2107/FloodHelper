import {
  IsDateString,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class UpdateCampaignDto {
  @IsNotEmpty()
  @IsString()
  campaignName!: string;

  @IsNotEmpty()
  @IsString()
  purpose!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  destinationProvinceCode?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  destinationWardCode?: number;

  @IsOptional()
  @IsString()
  destinationDetail?: string;

  @IsOptional()
  @IsString()
  destination?: string;

  @IsNotEmpty()
  @IsString()
  charityObject!: string;

  @IsNotEmpty()
  @IsString()
  bankAccountNumber!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  bankId?: number;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  bankName!: string;

  @IsOptional()
  @IsString()
  bankAccountName?: string;

  @IsOptional()
  @IsString()
  bankStatementFileUrl?: string;

  @IsDateString()
  startedDonationAt!: string;

  @IsDateString()
  finishedDonationAt!: string;

  @IsDateString()
  startedDistributionAt!: string;

  @IsDateString()
  finishedDistributionAt!: string;
}
