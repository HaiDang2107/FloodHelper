import { Body, Controller, Get, Param, Patch, Query, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enum/userRole.enum';
import { CharityService } from './charity.service';
import { ListAuthorityCampaignsDto, RespondCampaignDto } from './dto';

@Controller('authority/campaigns')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.AUTHORITY)
export class AuthorityCharityController {
  constructor(private readonly charityService: CharityService) {}

  @Get()
  async listCampaignsForAuthority(
    @CurrentUser() user: any,
    @Query() query: ListAuthorityCampaignsDto,
  ) {
    const result = await this.charityService.listCampaignsForAuthority(
      user.userId,
      query,
    );

    return {
      success: true,
      message: 'Campaign requests retrieved successfully',
      data: result.items,
      pagination: result.pagination,
    };
  }

  @Get(':campaignId')
  async getAuthorityCampaignDetail(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
  ) {
    const data = await this.charityService.getCampaignDetailForAuthority(
      user.userId,
      campaignId,
    );

    return {
      success: true,
      message: 'Campaign detail retrieved successfully',
      data,
    };
  }

  @Patch(':campaignId/approve')
  async approveCampaign(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: RespondCampaignDto,
  ) {
    const data = await this.charityService.approveCampaignForAuthority(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Campaign approved successfully',
      data,
    };
  }

  @Patch(':campaignId/reject')
  async rejectCampaign(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: RespondCampaignDto,
  ) {
    const data = await this.charityService.rejectCampaignForAuthority(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Campaign rejected successfully',
      data,
    };
  }
}
