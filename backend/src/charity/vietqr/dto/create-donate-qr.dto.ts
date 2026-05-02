import { Transform } from 'class-transformer';
import { IsNotEmpty, Matches } from 'class-validator';

export class CreateDonateQrDto {
  @Transform(({ value }) => (value == null ? '' : String(value).trim()))
  @IsNotEmpty()
  @Matches(/^\d+$/)
  amount!: string;
  // Campaign Id sử dụng query parameter
}
