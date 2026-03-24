import {
  IsString,
  IsOptional,
  IsDateString,
  IsArray,
  IsBoolean,
  IsNumber,
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  fullname: string;

  @IsString()
  phoneNumber: string;

  @IsOptional()
  @IsString()
  nickname?: string;

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
  @IsDateString()
  dateOfIssue?: string;

  @IsOptional()
  @IsDateString()
  dateOfExpire?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  role?: string[];

  @IsOptional()
  @IsNumber()
  curLongitude?: number;

  @IsOptional()
  @IsNumber()
  curLatitude?: number;

  @IsOptional()
  @IsBoolean()
  publicMapMode?: boolean;

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
