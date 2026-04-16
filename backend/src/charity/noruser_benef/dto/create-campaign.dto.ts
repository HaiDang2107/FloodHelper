import { IsDateString, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateCampaignDto {
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
  startedDonationAt!: string;

  @IsDateString()
  finishedDonationAt!: string;

  @IsDateString()
  startedDistributionAt!: string;

  @IsDateString()
  finishedDistributionAt!: string;
}
