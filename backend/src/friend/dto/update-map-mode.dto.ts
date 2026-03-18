import { IsArray, IsBoolean, IsString } from 'class-validator';

// Update mapmode cho 2 lần riêng biệt (see me và freeze)
export class UpdateMapModeDto {
  @IsArray()
  @IsString({ each: true })
  friendIds: string[];

  @IsBoolean()
  mapMode: boolean;
}
