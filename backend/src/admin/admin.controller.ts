import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  Query,
  Param,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';

import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../common/enum/userRole.enum';
import { UpdateUserDto } from '../user/dto/update-user.dto';
import { CreateAuthorityDto, UpdateAuthorityDto, SearchUserDto } from './dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('profile')
  async getProfile(@CurrentUser() user: any) {
    const data = await this.adminService.getProfile(user.userId);
    return { success: true, message: 'Profile retrieved', data };
  }

  @Patch('profile')
  async updateProfile(
    @CurrentUser() user: any,
    @Body() dto: UpdateUserDto,
  ) {
    const data = await this.adminService.updateProfile(user.userId, dto);
    return { success: true, message: 'Profile updated', data };
  }

  @Get('users/search')
  async searchUserByEmail(@Query() query: SearchUserDto) {
    const data = await this.adminService.searchUserByEmail(query.email);
    return { success: true, message: 'User retrieved', data };
  }

  @Get('users/:userId')
  async getUserById(@Param('userId', ParseUUIDPipe) userId: string) {
    const data = await this.adminService.getUserById(userId);
    return { success: true, message: 'User retrieved', data };
  }

  @Post('authorities')
  async createAuthority(
    @CurrentUser() user: any,
    @Body() dto: CreateAuthorityDto,
  ) {
    const data = await this.adminService.createAuthority(user.accountId, dto);
    return { success: true, message: 'Authority created', data };
  }

  @Patch('authorities/:userId')
  async updateAuthority(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Body() dto: UpdateAuthorityDto,
  ) {
    const data = await this.adminService.updateAuthority(userId, dto);
    return { success: true, message: 'Authority updated', data };
  }

  @Patch('users/:userId/ban')
  async banAccount(@Param('userId', ParseUUIDPipe) userId: string) {
    const data = await this.adminService.banAccount(userId);
    return { success: true, message: 'Account banned', data };
  }

  @Patch('users/:userId/unban')
  async unbanAccount(@Param('userId', ParseUUIDPipe) userId: string) {
    const data = await this.adminService.unbanAccount(userId);
    return { success: true, message: 'Account unbanned', data };
  }
}
