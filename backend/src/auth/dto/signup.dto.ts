import {
  IsString,
  IsOptional,
  IsDateString,
  IsPhoneNumber,
  IsArray,
  MinLength,
  MaxLength,
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
