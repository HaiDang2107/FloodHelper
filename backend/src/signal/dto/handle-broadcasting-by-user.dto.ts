import { IsUUID } from 'class-validator';

export class HandleBroadcastingByUserDto {
  @IsUUID()
  userId: string;

  @IsUUID()
  handledBy: string;
}
