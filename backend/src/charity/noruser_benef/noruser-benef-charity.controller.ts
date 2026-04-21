import {
  Body,
  BadRequestException,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Roles } from '../../auth/decorators/roles.decorator';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { UserRole } from '../../common/enum/userRole.enum';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { QueryCampaignTransactionsDto } from './dto/query-campaign-transactions.dto';
import { QueryCampaignsByStateDto } from './dto/query-campaigns-by-state.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
import { CreateDonateQrDto } from '../vietqr/dto';
import {
  CreateFinancialSupportDto,
  CreateSupplyDto,
  UpdateFinancialSupportDto,
  UpdateSupplyDto,
  UpdateCampaignLocationDto,
} from './dto';
import { NoruserBenefAllocationService } from './noruser-benef-allocation.service';
import { NoruserBenefCharityService } from './noruser-benef-charity.service';

@Controller('charity')
@UseGuards(JwtAuthGuard)
export class NoruserBenefCharityController {
  constructor(
    private readonly noruserBenefCharityService: NoruserBenefCharityService,
    private readonly noruserBenefAllocationService: NoruserBenefAllocationService,
  ) {}

  @Get('campaigns/existing')
  async getExistingCampaigns(@Query() query: QueryCampaignsByStateDto) {
    if (!query.state) {
      throw new BadRequestException('state is required');
    }

    const data = await this.noruserBenefCharityService.listExistingCampaignsByState(
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
  @Get('campaigns/mine')
  async getMyCampaigns(
    @CurrentUser() user: any,
    @Query() query: QueryCampaignsByStateDto,
  ) {
    if (!query.state) {
      throw new BadRequestException('state is required');
    }

    const data = await this.noruserBenefCharityService.listMyCampaignsByState(
      user.userId,
      query.state,
    );

    return {
      success: true,
      message: 'My campaigns retrieved successfully',
      data,
    };
  }

  @Get('campaigns/distributing-locations')
  async getDistributingCampaignLocations() {
    const data =
      await this.noruserBenefCharityService.listDistributingCampaignLocations();

    return {
      success: true,
      message: 'Distributing campaign locations retrieved successfully',
      data,
    };
  }

  @Get('campaigns/:campaignId')
  async getCampaignDetail(@Param('campaignId') campaignId: string) {
    const data = await this.noruserBenefCharityService.getCampaignDetail(campaignId);

    return {
      success: true,
      message: 'Campaign detail retrieved successfully',
      data,
    };
  }

  @Get('campaigns/:campaignId/transactions')
  async getCampaignTransactions(
    @Param('campaignId') campaignId: string,
    @Query() query: QueryCampaignTransactionsDto,
  ) {
    const data = await this.noruserBenefCharityService.listCampaignTransactions(campaignId, query);

    return {
      success: true,
      message: 'Campaign transactions retrieved successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post('campaigns')
  async createCampaign(
    @CurrentUser() user: any,
    @Body() body: CreateCampaignDto,
  ) {
    const data = await this.noruserBenefCharityService.createCampaign(user.userId, body);

    return {
      success: true,
      message: 'Campaign draft created successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Put('campaigns/:campaignId')
  async updateCampaign(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: UpdateCampaignDto,
  ) {
    const data = await this.noruserBenefCharityService.updateCampaign(
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
  @Patch('campaigns/:campaignId/location')
  async updateCampaignLocation(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: UpdateCampaignLocationDto,
  ) {
    const data = await this.noruserBenefCharityService.updateCampaignLocation(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Campaign location check-in successful',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post('campaigns/:campaignId/send-request')
  async sendCampaignRequest(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
  ) {
    const data = await this.noruserBenefCharityService.sendCampaignRequest(
      user.userId,
      campaignId,
    );

    return {
      success: true,
      message: 'Campaign request sent successfully',
      data,
    };
  }

  @Get('campaigns/:campaignId/supplies') // Lấy danh sách supplies
  async getCampaignSupplies(@Param('campaignId') campaignId: string) {
    const data = await this.noruserBenefAllocationService.listSupplies(campaignId);

    return {
      success: true,
      message: 'Campaign supplies retrieved successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post('campaigns/:campaignId/supplies')
  async createCampaignSupply( // Tạo supply
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: CreateSupplyDto,
  ) {
    const data = await this.noruserBenefAllocationService.createSupply(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Supply created successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Put('campaigns/:campaignId/supplies/:supplyId')
  async updateCampaignSupply(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Param('supplyId') supplyId: string,
    @Body() body: UpdateSupplyDto,
  ) {
    const data = await this.noruserBenefAllocationService.updateSupply(
      user.userId,
      campaignId,
      supplyId,
      body,
    );

    return {
      success: true,
      message: 'Supply updated successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Delete('campaigns/:campaignId/supplies/:supplyId')
  async deleteCampaignSupply(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Param('supplyId') supplyId: string,
  ) {
    const data = await this.noruserBenefAllocationService.deleteSupply(
      user.userId,
      campaignId,
      supplyId,
    );

    return {
      success: true,
      message: 'Supply deleted successfully',
      data,
    };
  }

  @Get('campaigns/:campaignId/financial-supports')
  async getCampaignFinancialSupports(@Param('campaignId') campaignId: string) {
    const data = await this.noruserBenefAllocationService.listFinancialSupports(
      campaignId,
    );

    return {
      success: true,
      message: 'Campaign financial supports retrieved successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Post('campaigns/:campaignId/financial-supports')
  async createCampaignFinancialSupport(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: CreateFinancialSupportDto,
  ) {
    const data = await this.noruserBenefAllocationService.createFinancialSupport(
      user.userId,
      campaignId,
      body,
    );

    return {
      success: true,
      message: 'Financial support created successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Put('campaigns/:campaignId/financial-supports/:financialSupportId')
  async updateCampaignFinancialSupport(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Param('financialSupportId') financialSupportId: string,
    @Body() body: UpdateFinancialSupportDto,
  ) {
    const data = await this.noruserBenefAllocationService.updateFinancialSupport(
      user.userId,
      campaignId,
      financialSupportId,
      body,
    );

    return {
      success: true,
      message: 'Financial support updated successfully',
      data,
    };
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.BENEFACTOR)
  @Delete('campaigns/:campaignId/financial-supports/:financialSupportId')
  async deleteCampaignFinancialSupport(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Param('financialSupportId') financialSupportId: string,
  ) {
    const data = await this.noruserBenefAllocationService.deleteFinancialSupport(
      user.userId,
      campaignId,
      financialSupportId,
    );

    return {
      success: true,
      message: 'Financial support deleted successfully',
      data,
    };
  }

  @Post('campaigns/:campaignId/donate/qr')
  async createDonateQr(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: CreateDonateQrDto,
  ) {
    const data = await this.noruserBenefCharityService.createDonationQr(
      campaignId,
      body.amount,
      user.userId,
    );

    return {
      success: true,
      message: 'VietQR created successfully',
      data,
    };
  }

  @Post('transactions/:transactionId/test-callback')
  async testCallback(
    @CurrentUser() user: any,
    @Param('transactionId') transactionId: string,
  ) {
    const data = await this.noruserBenefCharityService.triggerTestCallback(
      transactionId,
      user.userId,
    );

    return {
      success: true,
      message: 'Transaction callback triggered successfully',
      data,
    };
  }

  @Post('internal/campaigns/:campaignId/donate/qr')
  async createDonateQrInternal(
    @CurrentUser() user: any,
    @Param('campaignId') campaignId: string,
    @Body() body: CreateDonateQrDto,
  ) {
    const data = await this.noruserBenefCharityService.createDonationQrInternal(
      campaignId,
      body.amount,
      user.userId,
    );

    return {
      success: true,
      message: 'Internal VietQR created successfully',
      data,
    };
  }

  @Post('internal/transactions/:transactionId/test-callback')
  async testCallbackInternal(
    @CurrentUser() user: any,
    @Param('transactionId') transactionId: string,
  ) {
    const data = await this.noruserBenefCharityService.triggerTestCallbackInternal(
      transactionId,
      user.userId,
    );

    return {
      success: true,
      message: 'Internal transaction callback simulated successfully',
      data,
    };
  }
}