import { IsOptional, IsString, IsBoolean } from 'class-validator';

export class SignoutDto {
  @IsOptional()
  @IsString()
  sessionId?: string;

  @IsOptional()
  @IsBoolean()
  logoutAll?: boolean;
}