import { IsString } from 'class-validator';

export class ResendVerificationCodeDto {
  @IsString()
  username: string;
}
