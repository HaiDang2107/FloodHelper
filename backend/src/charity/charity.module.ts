import { Module } from '@nestjs/common';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AuthorityCharityController } from './authority-charity.controller';
import { CharityCampaignStateScheduler } from './charity-campaign-state.scheduler';
import { CharityController } from './charity.controller';
import { CharityService } from './charity.service';
import { VietQrService } from './vietqr/vietqr.service';

@Module({
  controllers: [CharityController, AuthorityCharityController],
  providers: [
    CharityService,
    CharityCampaignStateScheduler,
    VietQrService,
    RolesGuard,
  ],
  exports: [CharityService],
})
export class CharityModule {}