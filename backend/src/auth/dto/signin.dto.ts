import { IsString, IsOptional, MinLength } from 'class-validator';

export class SigninDto {
  @IsString()
  username: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsOptional()
  @IsString()
  deviceId?: string;
}