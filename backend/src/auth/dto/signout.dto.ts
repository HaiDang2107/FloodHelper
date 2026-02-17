import { IsOptional, IsString, IsBoolean } from 'class-validator';

export class SignoutDto {
  @IsOptional()
  @IsBoolean()
  logoutAll?: boolean;
}