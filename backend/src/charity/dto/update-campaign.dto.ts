import { IsDateString, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateCampaignDto {
  @IsNotEmpty()
  @IsString()
  campaignName!: string;

  @IsNotEmpty()
  @IsString()
  purpose!: string;

  @IsNotEmpty()
  @IsString()
  destination!: string;

  @IsNotEmpty()
  @IsString()
  charityObject!: string;

  @IsNotEmpty()
  @IsString()
  bankAccountNumber!: string;

  @IsNotEmpty()
  @IsString()
  bankName!: string;

  @IsOptional()
  @IsString()
  bankAccountName?: string;

  @IsOptional()
  @IsString()
  bankStatementFileUrl?: string;

  @IsDateString()
  startDonationAt!: string;

  @IsDateString()
  finishDonationAt!: string;

  @IsDateString()
  startDistributionAt!: string;

  @IsDateString()
  finishDistributionAt!: string;
}
