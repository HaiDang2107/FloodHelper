import { IsOptional, IsString, MaxLength } from 'class-validator';

export class RespondRoleRequestDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
