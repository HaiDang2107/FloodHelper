import { IsNumber, IsOptional, IsBoolean } from 'class-validator';

export class UpdateLocationDto {
  @IsNumber()
  curLongitude: number;

  @IsNumber()
  curLatitude: number;

  @IsOptional()
  @IsBoolean()
  publicMapMode?: boolean;
}
