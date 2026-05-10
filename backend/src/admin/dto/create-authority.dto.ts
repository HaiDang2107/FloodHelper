import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsDateString,
  IsInt,
  Min,
  IsEmail,
} from 'class-validator';

export class CreateAuthorityDto {
  @IsString()
  @IsNotEmpty()
  fullname: string;

  @IsString()
  @IsNotEmpty()
  phoneNumber: string;

  @IsEmail()
  username: string;

  @IsString()
  @IsNotEmpty()
  password: string;

  @IsOptional()
  @IsString()
  nickname?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsDateString()
  dob?: string;

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

  @IsInt()
  @Min(1)
  residenceWardCode: number;

  @IsOptional()
  @IsDateString()
  dateOfIssue?: string;

  @IsOptional()
  @IsDateString()
  dateOfExpire?: string;

  @IsOptional()
  @IsString()
  citizenId?: string;

  @IsOptional()
  @IsString()
  occupation?: string;
}
