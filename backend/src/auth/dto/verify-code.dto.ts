import { IsString, MinLength } from 'class-validator';

export class VerifyCodeDto {
  @IsString()
  username: string;

  @IsString()
  @MinLength(6)
  code: string;
}
