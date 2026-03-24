import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { RoleRequestService } from './role-request.service';
import { UserRole } from '../common/enum/userRole.enum';
import {
  CreateRoleRequestDto,
  ListRoleRequestsDto,
  RespondRoleRequestDto,
} from './dto';

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
export class RoleRequestController {
  constructor(private readonly roleRequestService: RoleRequestService) {}

  @Post('user/profile/role-requests')
  async createRoleRequest(
    @CurrentUser() user: any,
    @Body() dto: CreateRoleRequestDto,
  ) {
    await this.roleRequestService.createRequest(user.userId, dto);
    return {
      success: true,
      message: 'Role request submitted successfully',
    };
  }

  @Get('user/profile/role-requests')
  async listOwnRoleRequests(
    @CurrentUser() user: any,
    @Query() query: ListRoleRequestsDto,
  ) {
    const result = await this.roleRequestService.listForRequester(
      user.userId,
      query,
    );
    return {
      success: true,
      message: 'Role requests retrieved successfully',
      data: result,
    };
  }

  @Get('authority/role-requests')
  @Roles(UserRole.AUTHORITY)
  async listRoleRequests(
    @CurrentUser() user: any,
    @Query() query: ListRoleRequestsDto,
  ) {
    const result = await this.roleRequestService.listForAuthority(
      user.userId,
      query,
    );
    return {
      success: true,
      message: 'Role requests retrieved successfully',
      data: result.items,
      pagination: result.pagination,
    };
  }

  @Patch('authority/role-requests/:id/approve')
  @Roles(UserRole.AUTHORITY)
  async approveRoleRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
    @Body() dto: RespondRoleRequestDto,
  ) {
    const result = await this.roleRequestService.approve(
      user.userId,
      requestId,
      dto,
    );
    return {
      success: true,
      message: 'Role request approved successfully',
      data: result,
    };
  }

  @Patch('authority/role-requests/:id/reject')
  @Roles(UserRole.AUTHORITY)
  async rejectRoleRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
    @Body() dto: RespondRoleRequestDto,
  ) {
    const result = await this.roleRequestService.reject(
      user.userId,
      requestId,
      dto,
    );
    return {
      success: true,
      message: 'Role request rejected successfully',
      data: result,
    };
  }
}
