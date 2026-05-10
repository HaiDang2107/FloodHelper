import { PartialType } from '@nestjs/mapped-types';
import { IsBoolean, IsOptional } from 'class-validator';

import { UpdateUserDto } from '../../user/dto/update-user.dto';

export class UpdateAuthorityDto extends PartialType(UpdateUserDto) {
  @IsOptional()
  @IsBoolean()
  isAuthority?: boolean;
}
