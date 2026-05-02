import {
  IsString,
  IsOptional,
  IsDateString,
  IsPhoneNumber,
  IsArray,
  MinLength,
  MaxLength,
  IsInt,
  Min,
} from 'class-validator';

export class SignupDto {
  // User information
  @IsString()
  @MinLength(2)
  @MaxLength(255)
  fullname: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  nickname?: string;

  @IsOptional()
  @IsPhoneNumber('VN') // Assuming Vietnamese phone numbers
  phoneNumber: string;

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
  @IsString()
  jobPosition?: string;

  // Account information
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  username: string;

  @IsString()
  @MinLength(6)
  password: string;
}
