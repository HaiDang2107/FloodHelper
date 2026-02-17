import { IsString, MinLength } from 'class-validator';
import { Purpose } from '../../common/enum/purpose.enum'; 

export class VerifyCodeDto {
  @IsString()
  username: string;

  @IsString()
  type: Purpose;

  @IsString()
  @MinLength(6)
  code: string;
}
