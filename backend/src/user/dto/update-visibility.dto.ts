import { IsIn, IsString } from 'class-validator';

export class UpdateVisibilityDto {
  @IsString()
  @IsIn(['PUBLIC', 'JUST_FRIEND', 'NO_ONE'])
  visibility: 'PUBLIC' | 'JUST_FRIEND' | 'NO_ONE';
}
