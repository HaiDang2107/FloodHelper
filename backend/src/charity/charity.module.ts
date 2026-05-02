import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CommonModule } from '../common/common.module';
import { AuthorityCharityController } from './authority/authority-charity.controller';
import { AuthorityCharityService } from './authority/authority-charity.service';
import { CharityCampaignStateScheduler } from './charity-campaign-state.scheduler';
import { CommonCharityService } from './common.service';
import { NoruserBenefCharityController } from './noruser_benef/noruser-benef-charity.controller';
import { NoruserBenefAllocationService } from './noruser_benef/noruser-benef-allocation.service';
import { NoruserBenefCharityService } from './noruser_benef/noruser-benef-charity.service';
import { VietQrInternalService } from './vietqr/vietqr-internal.service';
import { VietQrWebhookController } from './vietqr/vietqr-webhook.controller';
import { VietQrService } from './vietqr/vietqr.service';

@Module({
  imports: [
    CommonModule,
    JwtModule.register({
      secret:
        process.env.VIETQR_WEBHOOK_SECRET ??
        process.env.SECRET_KEY ??
        process.env.AT_SECRET ??
        'vietqr-webhook-secret',
      signOptions: {
        algorithm: 'HS512',
        expiresIn: '300s',
      },
    }),
  ],
  controllers: [
    NoruserBenefCharityController,
    AuthorityCharityController,
    VietQrWebhookController,
  ],
  providers: [
    CommonCharityService,
    AuthorityCharityService,
    NoruserBenefAllocationService,
    NoruserBenefCharityService,
    CharityCampaignStateScheduler,
    VietQrService,
    VietQrInternalService,
    RolesGuard,
  ],
  exports: [
    CommonCharityService,
    AuthorityCharityService,
    NoruserBenefAllocationService,
    NoruserBenefCharityService,
    VietQrService,
    VietQrInternalService,
  ],
})
export class CharityModule {}