import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enum/userRole.enum';
import { SignalService } from './signal.service';
import {
  CreateSignalDto,
  HandleBroadcastingByUserDto,
  StopBroadcastingByUserDto,
  UpdateSignalInfoDto,
} from './dto';
import { ServiceTokenGuard } from './guards/service-token.guard';

@Controller('signal')
export class SignalController {
  constructor(private readonly signalService: SignalService) {}

  @UseGuards(ServiceTokenGuard)
  @Post()
  async create(@Body() dto: CreateSignalDto) {
    if (!dto.createdBy) {
      throw new BadRequestException('createdBy is required');
    }

    const data = await this.signalService.createSignal(dto.createdBy, dto);
    return {
      success: true,
      message: 'Distress signal created successfully',
      data,
    };
  }

//   @UseGuards(ServiceTokenGuard)
//   @Patch(':id/info')
//   async updateInfo(
//     @Param('id') signalId: string,
//     @Body() dto: UpdateSignalInfoDto,
//   ) {
//     const data = await this.signalService.updateSignalInfo(signalId, dto);
//     return {
//       success: true,
//       message: 'Distress signal updated successfully',
//       data,
//     };
//   }

  @UseGuards(ServiceTokenGuard)
  @Patch('info/update-by-user')
  async updateBroadcastingInfoByUser(@Body() dto: UpdateSignalInfoDto) {
    const data = await this.signalService.updateBroadcastingInfoByUser(dto);
    return {
      success: true,
      message: 'Distress signal updated successfully',
      data,
    };
  }

//   @UseGuards(ServiceTokenGuard)
//   @Delete(':id')
//   async remove(
//     @Param('id') signalId: string,
//     @Body('deletedBy') deletedBy: string,
//   ) {
//     await this.signalService.deleteSignalInternal(signalId, deletedBy);
//     return {
//       success: true,
//       message: 'Distress signal deleted successfully',
//     };
//   }

//   @UseGuards(ServiceTokenGuard)
//   @Patch(':id/state')
//   async changeState(
//     @Param('id') signalId: string,
//     @Body() dto: ChangeSignalStateDto,
//   ) {
//     const data = await this.signalService.changeStateInternal(signalId, dto);
//     return {
//       success: true,
//       message: 'Distress signal state updated successfully',
//       data,
//     };
//   }

  @UseGuards(ServiceTokenGuard)
  @Patch('state/stop-by-user')
  async stopBroadcastingByUser(@Body() dto: StopBroadcastingByUserDto) {
    const data = await this.signalService.stopBroadcastingByUser(dto.createdBy);
    return {
      success: true,
      message: 'Distress signal stopped successfully',
      data,
    };
  }

  @UseGuards(ServiceTokenGuard)
  @Patch('state/handle-by-user')
  async handleBroadcastingByUser(@Body() dto: HandleBroadcastingByUserDto) {
    const data = await this.signalService.handleBroadcastingByRescuer(
      dto.userId,
      dto.handledBy,
    );
    return {
      success: true,
      message: 'Distress signal handled successfully',
      data,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.RESCUER)
  @Get('rescuer/broadcasting')
  async listRescuerBroadcasting() {
    const data = await this.signalService.listBroadcastingSignals();

    return {
      success: true,
      message: 'Broadcasting distress signals retrieved successfully',
      data,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.RESCUER)
  @Get('rescuer/handled')
  async listRescuerHandled(@CurrentUser() user: any) {
    const data = await this.signalService.listHandledSignalsByRescuer(user.userId);

    return {
      success: true,
      message: 'Handled distress signals retrieved successfully',
      data,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('mine/latest')
  async getMyLatest(@CurrentUser() user: any) {
    const data = await this.signalService.getLatestSignalByUser(user.userId);

    return {
      success: true,
      message: 'Latest distress signal retrieved successfully',
      data,
    };
  }
}
