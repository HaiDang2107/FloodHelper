import { IsNotEmpty, IsString, IsOptional } from 'class-validator';

export class SendFriendRequestDto {
  @IsNotEmpty()
  @IsString()
  email: string;

  @IsOptional()
  @IsString()
  note?: string;
}
