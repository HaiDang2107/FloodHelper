import { IsUUID } from 'class-validator';

export class StopBroadcastingByUserDto {
  @IsUUID()
  createdBy: string;
}
