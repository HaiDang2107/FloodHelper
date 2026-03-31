import { IsEnum, IsOptional, IsUUID } from 'class-validator';
import { SignalState } from '../../common/enum/signalState.enum';

export class QuerySignalsDto {
  @IsOptional()
  @IsUUID()
  createdBy?: string;

  @IsOptional()
  @IsUUID()
  handledBy?: string;

  @IsOptional()
  @IsEnum(SignalState)
  state?: SignalState;
}
