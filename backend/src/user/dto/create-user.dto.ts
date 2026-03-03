import { IsString, IsOptional, IsDateString, IsArray, IsBoolean, IsNumber } from 'class-validator';

export class CreateUserDto {
  @IsString()
  name: string;

  @IsString()
  phoneNumber: string;

  @IsOptional()
  @IsString()
  displayName?: string;

  @IsOptional()
  @IsDateString()
  dob?: string;

  @IsOptional()
  @IsString()
  village?: string;

  @IsOptional()
  @IsString()
  district?: string;

  @IsOptional()
  @IsString()
  country?: string;

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
