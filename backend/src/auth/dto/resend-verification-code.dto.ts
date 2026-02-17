import { IsString } from 'class-validator';
import { Purpose } from '../../common/enum/purpose.enum';

export class ResendVerificationCodeDto {
  @IsString()
  username: string;

  @IsString()
  type: Purpose;
}
