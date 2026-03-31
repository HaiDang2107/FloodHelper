import { IsEnum, IsOptional, IsUUID } from 'class-validator';
import { SignalState } from '../../common/enum/signalState.enum';

export class ChangeSignalStateDto {
  @IsEnum(SignalState)
  state: SignalState;

  @IsOptional()
  @IsUUID()
  handledBy?: string;

  @IsOptional()
  @IsUUID()
  updatedBy?: string;
}
