import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import {
  IsOptional,
  IsString,
  IsDateString,
  IsBoolean,
  IsNumber,
  IsIn,
  IsInt,
  Min,
} from 'class-validator';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  @IsOptional()
  @IsString()
  nickname?: string;

  @IsOptional()
  @IsString()
  fullname?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsDateString()
  dob?: string;

  @IsOptional()
  @IsString()
  placeOfOrigin?: string;

  @IsOptional()
  @IsString()
  placeOfResidence?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  originProvinceCode?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  originWardCode?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  residenceProvinceCode?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  residenceWardCode?: number;

  @IsOptional()
  @IsDateString()
  dateOfIssue?: string;

  @IsOptional()
  @IsDateString()
  dateOfExpire?: string;

  @IsOptional()
  @IsNumber()
  curLongitude?: number;

  @IsOptional()
  @IsNumber()
  curLatitude?: number;

  @IsOptional()
  @IsString()
  @IsIn(['PUBLIC', 'JUST_FRIEND', 'NO_ONE'])
  visibilityMode?: string;

  @IsOptional()
  @IsBoolean()
  showCharityCampaignLocations?: boolean;

  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @IsOptional()
  @IsString()
  citizenId?: string;

  @IsOptional()
  @IsString()
  citizenIdCardImg?: string;

  @IsOptional()
  @IsString()
  jobPosition?: string;
}
