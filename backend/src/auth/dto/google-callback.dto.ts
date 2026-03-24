import { IsString, IsOptional } from 'class-validator';

export class GoogleCallbackDto {
  @IsString()
  code: string;

  @IsString()
  state: string;

  @IsOptional()
  @IsString()
  deviceId?: string;
}
