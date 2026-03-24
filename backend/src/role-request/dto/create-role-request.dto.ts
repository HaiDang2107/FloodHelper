import { IsIn, IsString } from 'class-validator';

export class CreateRoleRequestDto {
  @IsString()
  @IsIn(['BENEFACTOR', 'RESCUER'])
  type: string;
}
