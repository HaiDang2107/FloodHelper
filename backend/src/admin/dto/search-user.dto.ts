import { IsEmail, IsNotEmpty } from 'class-validator';

export class SearchUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;
}
