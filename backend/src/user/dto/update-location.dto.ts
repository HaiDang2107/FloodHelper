import { IsNumber } from 'class-validator';

export class UpdateLocationDto {
  @IsNumber()
  curLongitude: number;

  @IsNumber()
  curLatitude: number;
}
