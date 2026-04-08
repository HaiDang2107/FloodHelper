import {
  Body,
  BadRequestException,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enum/userRole.enum';
import { CharityService } from './charity.service';
import {
  CreateCampaignDto,
  QueryCampaignsByStateDto,
  UpdateCampaignDto,
} from './dto';

@Controller('charity/campaigns')
@UseGuards(JwtAuthGuard)
export class CharityController {
  constructor(private readonly charityService: CharityService) {}

  @Get('existing')
  async getExistingCampaigns(@Query() query: QueryCampaignsByStateDto) {
    if (!query.state) {
      throw new BadRequestException('state is required');
    }

    const data = await this.charityService.listExistingCampaignsByState(
      query.state,
    );

    return {
      success: true,
      message: 'Existing campaigns retrieved successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Get('mine')
  async getMyCampaigns(
    @CurrentUser() user: any,
    @Query() query: QueryCampaignsByStateDto,
  ) {
    if (!query.state) {
      throw new BadRequestException('state is required');
    }

    const data = await this.charityService.listMyCampaignsByState(
      user.userId,
      query.state,
    );

    return {
      success: true,
      message: 'My campaigns retrieved successfully',
      data,
    };
  }

  @Get(':campaignId')
  async getCampaignDetail(@Param('campaignId') campaignId: string) {
    const data = await this.charityService.getCampaignDetail(campaignId);

    return {
      success: true,
      message: 'Campaign detail retrieved successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post()
  async createCampaign(
    @CurrentUser() user: any,
    @Body() body: CreateCampaignDto,
  ) {
    const data = await this.charityService.createCampaign(user.userId, body);

    return {
      success: true,
      message: 'Campaign draft created successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Put(':campaignId')
  async updateCampaign(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: UpdateCampaignDto,
  ) {
    const data = await this.charityService.updateCampaign(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Campaign updated successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post(':campaignId/send-request')
  async sendCampaignRequest(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
  ) {
    const data = await this.charityService.sendCampaignRequest(
      user.userId,
      campaignId,
    );

    return {
      success: true,
      message: 'Campaign request sent successfully',
      data,
    };
  }
}