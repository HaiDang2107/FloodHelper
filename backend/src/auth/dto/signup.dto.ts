import { IsString, IsOptional, IsDateString, IsPhoneNumber, IsArray, MinLength, MaxLength } from 'class-validator';

export class SignupDto {
  // User information
  @IsString()
  @MinLength(2)
  @MaxLength(255)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  displayName?: string;

  @IsPhoneNumber('VN') // Assuming Vietnamese phone numbers
  phoneNumber: string;

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