import { IsNotEmpty, IsString, IsOptional } from 'class-validator';

export class SendFriendRequestDto {
  @IsNotEmpty()
  @IsString()
  receiverId: string;

  @IsOptional()
  @IsString()
  note?: string;
}
